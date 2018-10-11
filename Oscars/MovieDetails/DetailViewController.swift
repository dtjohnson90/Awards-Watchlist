//
//  DetailViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 1/10/17.
//  Copyright © 2017 Dustin Johnson. All rights reserved.
//

import UIKit
import SystemConfiguration
import FirebaseStorage
import FirebaseUI

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var movieSelected = Items.movie(actors: [String](), cover: UIImage(), description: String(), idmb: String(), name: String(), nominatedFor: [String](), youtube: String())
    var nominationString = ""
    var movieCast = ""
    var imdbString = "http://www.imdb.com/title/"
    var actorImages = [UIImage]()
    
    @IBAction func unwindToMovie(segue: UIStoryboardSegue) {}
    @IBOutlet weak var actorCollectionView: UICollectionView!
    @IBOutlet var detailImage: UIImageView!
    @IBOutlet var haveWatched: UIButton!
    @IBOutlet var detailInfo: UIScrollView!
    @IBOutlet var wv: UIWebView!
    @IBOutlet var nominations: UILabel!
    @IBOutlet var detailDescriptionLabel: UILabel! = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    @IBAction func imdbButtonClick(_ sender: UIButton) {
        print(imdbString)
        guard let url = URL(string: imdbString) else {
            return //be safe
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBOutlet var imdbButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailInfo.addSubview(detailDescriptionLabel)        
        
        let nomDis = DispatchGroup()
        for nomination in movieSelected.nominatedFor {
            nomDis.enter()
            nominationString.append(nomination + "\n")
            nomDis.leave()
        }
        nomDis.notify(queue: .main) {
            self.nominations.text = self.nominationString
        }
        
        detailDescriptionLabel.text = movieSelected.description
        detailImage.image = movieSelected.cover
        loadYoutube(videoID: movieSelected.youtube)
        imdbString.append(movieSelected.idmb)
        
        haveWatched.layer.cornerRadius = haveWatched.frame.height / 2
        imdbButton.layer.cornerRadius = imdbButton.frame.height / 2
        imdbButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        if Items.sharedInstance.moviesSeenArray.contains(movieSelected) {
            haveWatched.setTitle("Seen", for: .normal)
            haveWatched.backgroundColor = UIColor.green
        }
        else {
            haveWatched.setTitle("Unseen", for: .normal)
            haveWatched.backgroundColor = UIColor.red
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Items.sharedInstance.moviesSeenArray.contains(movieSelected) {
            haveWatched.setTitle("Seen", for: .normal)
            haveWatched.backgroundColor = UIColor.green
        }
        else {
            haveWatched.setTitle("Unseen", for: .normal)
            haveWatched.backgroundColor = UIColor.red
        }
    }
    
    func loadYoutube(videoID:String) {
        guard
            let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)")
            else { return }
        wv.loadRequest( URLRequest(url: youtubeURL) )
    }
    
    @IBAction func haveWatchedClick(_ sender: UIButton) {
        if UserDefaults.standard.contains(key: "offeredSignIn") {
            if let buttonTitle = sender.title(for: .normal) {
                if buttonTitle == "Unseen" {
                    haveWatched.setTitle("Seen", for: .normal)
                    haveWatched.backgroundColor = UIColor.green
                    Items.sharedInstance.moviesSeenArray.append(movieSelected)
                    
                    var tempMovieArray = [String]()
                    for seenMovie in Items.sharedInstance.moviesSeenArray {
                        tempMovieArray.append(seenMovie.name)
                    }
                    Firestore.firestore().collection("UserMovieList").document((Auth.auth().currentUser?.email)!).setData([
                        "movies": tempMovieArray
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                } else {
                    haveWatched.setTitle("Unseen", for: .normal)
                    haveWatched.backgroundColor = UIColor.red
                    Items.sharedInstance.moviesSeenArray.remove(at: Items.sharedInstance.moviesSeenArray.index(of:movieSelected)!)
                    
                    var tempMovieArray = [String]()
                    for seenMovie in Items.sharedInstance.moviesSeenArray {
                        tempMovieArray.append(seenMovie.name)
                    }
                    Firestore.firestore().collection("UserMovieList").document((Auth.auth().currentUser?.email)!).setData([
                        "movies": tempMovieArray
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "Saving Data", message: "Would you like to save your data locally to this device or would you like to create an account to save your data across multiple devices?", preferredStyle: UIAlertControllerStyle.alert)
            
            let local = UIAlertAction(title: "Save to this device only", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            let account = UIAlertAction(title: "Create Account", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                Items.sharedInstance.moviesSeenArray.append(self.movieSelected)
                self.performSegue(withIdentifier: "LogInSegue", sender: self)
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieSelected.actors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actorCell",
                                                      for: indexPath) as! ActorsCollectionViewCell
        
        let gsReference = Storage.storage().reference(forURL: "gs://oscarswatchlist.appspot.com/Actors/\(movieSelected.actors[indexPath.item]).jpg")
        gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
                print("Error")
                cell.actorImage.image = UIImage(named: "NoPhotoAvailable.jpg")!
            } else {
                // Data for "images/island.jpg" is returned
                print("Added image")
                cell.actorImage.image = UIImage(data: data!)!
            }
        }
        
        cell.actorName.text = movieSelected.actors[indexPath.item]
        cell.actorName.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 200)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UserDefaults {
    func contains(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
