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
import WatchConnectivity

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, WCSessionDelegate {
    
    
    
    var movieSelected = Items.movie(actors: [String](), cover: UIImage(), description: String(), idmb: String(), name: String(), nominatedFor: [String](), youtube: String())
    var nominationString = ""
    var movieCast = ""
    var imdbString = "http://www.imdb.com/title/"
    var actorImages = [UIImage]()
    var sending: WCSession?
    let receiving = WCSession.default
    
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
        
        let heightConstraint = NSLayoutConstraint(item: detailImage, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 1.45 * UIScreen.main.bounds.width)
        detailImage.addConstraints([heightConstraint])
        detailImage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1.45 * UIScreen.main.bounds.width)
        
        if WCSession.isSupported() {
            sending = WCSession.default
            sending?.delegate = self
            sending?.activate()
            receiving.delegate = self
            receiving.activate()
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
    
    func validateSession() {
        if let validSession = sending {
            let movieArray = NSMutableArray()
            for movie in Items.sharedInstance.movieArray {
                let movieInfo = NSMutableDictionary()
                movieInfo.setObject(movie.name, forKey: "Name" as NSCopying)
                movieInfo.setObject(movie.actors, forKey: "Actors" as NSCopying)
                movieInfo.setObject(movie.description, forKey: "Description" as NSCopying)
                movieInfo.setObject(movie.nominatedFor, forKey: "NominatedFor" as NSCopying)
                movieArray.add(movieInfo)
            }
            
            let seenArray = NSMutableArray()
            for movie in Items.sharedInstance.moviesSeenArray {
                let seenMovieInfo = NSMutableDictionary()
                seenMovieInfo.setObject(movie.name, forKey: "Name" as NSCopying)
                seenMovieInfo.setObject(movie.actors, forKey: "Actors" as NSCopying)
                seenMovieInfo.setObject(movie.description, forKey: "Description" as NSCopying)
                seenMovieInfo.setObject(movie.nominatedFor, forKey: "NominatedFor" as NSCopying)
                seenArray.add(seenMovieInfo)
            }
            
            let iphoneAppContext = ["Details": movieArray, "Seen": seenArray] as [String : Any]
            do {
                try validSession.updateApplicationContext(iphoneAppContext)
                print("Success")
            } catch {
                print("Something went wrong")
            }
        }
    }
    
    func processApplicationContext(){
        if let iPhoneContext = receiving.receivedApplicationContext as? [String : [String]] {
            let initialArray = iPhoneContext["Seen"]! as [String]
            var moviesSeen = [String]()
            for item in initialArray {
                if !moviesSeen.contains(item) {
                    moviesSeen.append(item)
                }
            }
            
            Items.sharedInstance.moviesSeenArray.removeAll()
            let downloading = DispatchGroup()
            for movie in moviesSeen {
                downloading.enter()
                for movie2 in Items.sharedInstance.movieArray {
                    if movie2.name == movie {
                        Items.sharedInstance.moviesSeenArray.append(movie2)
                        downloading.leave()
                    }
                }
            }
            downloading.notify(queue: .main) {
                self.updateSavedData()
                if Items.sharedInstance.moviesSeenArray.contains(self.movieSelected) {
                    self.haveWatched.setTitle("Seen", for: .normal)
                    self.haveWatched.backgroundColor = UIColor.green
                } else {
                    self.haveWatched.setTitle("Unseen", for: .normal)
                    self.haveWatched.backgroundColor = UIColor.red
                }
            }
        }
    }
    
    func updateSavedData() {
        var tempMovieArray = [String]()
        for seenMovie in Items.sharedInstance.moviesSeenArray {
            tempMovieArray.append(seenMovie.name)
        }
        
        if Items.sharedInstance.loggedIn == "Local" {
            let configModel = ConfigurationModel()
            configModel.savedMovies = tempMovieArray
        } else {
            let configModel = ConfigurationModel()
            configModel.savedMovies = tempMovieArray
            
            Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).updateData([
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
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.processApplicationContext()
        })
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
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
                    validateSession()
                    
                    var tempMovieArray = [String]()
                    for seenMovie in Items.sharedInstance.moviesSeenArray {
                        tempMovieArray.append(seenMovie.name)
                    }
                    
                    if Items.sharedInstance.loggedIn == "Local" {
                        let configModel = ConfigurationModel()
                        configModel.savedMovies = tempMovieArray
                    } else {
                        let configModel = ConfigurationModel()
                        configModel.savedMovies = tempMovieArray
                        Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).updateData([
                            "movies": tempMovieArray
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                    }
                } else {
                    haveWatched.setTitle("Unseen", for: .normal)
                    haveWatched.backgroundColor = UIColor.red
                    Items.sharedInstance.moviesSeenArray.remove(at: Items.sharedInstance.moviesSeenArray.index(of:movieSelected)!)
                    validateSession()
                    
                    var tempMovieArray = [String]()
                    for seenMovie in Items.sharedInstance.moviesSeenArray {
                        tempMovieArray.append(seenMovie.name)
                    }
                    
                    if Items.sharedInstance.loggedIn == "Local" {
                        let configModel = ConfigurationModel()
                        configModel.savedMovies = tempMovieArray
                    } else {
                        let configModel = ConfigurationModel()
                        configModel.savedMovies = tempMovieArray
                        Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).updateData([
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
            }
        } else {
            let alertController = UIAlertController(title: "Saving Data", message: "Would you like to save your data locally to this device or would you like to create an account to save your data across multiple devices?", preferredStyle: UIAlertControllerStyle.alert)
            
            let local = UIAlertAction(title: "Save to this device only", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                Items.sharedInstance.moviesSeenArray.append(self.movieSelected)
                self.validateSession()
                UserDefaults.standard.set("Local", forKey: "Storage")
                var tempArray = [String]()
                for item in Items.sharedInstance.moviesSeenArray {
                    tempArray.append(item.name)
                }
                let predictionsArray = String(repeating: "", count: 24)
                let configModel = ConfigurationModel()
                configModel.savedMovies = tempArray
                UserDefaults.standard.set(true, forKey: "offeredSignIn")
                UserDefaults.standard.set(predictionsArray, forKey: "Predictions")
                self.haveWatched.sendActions(for: .touchUpInside)
            }
            let account = UIAlertAction(title: "Create Account", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                Items.sharedInstance.moviesSeenArray.append(self.movieSelected)
                self.validateSession()
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
                cell.actorImage.image = UIImage(named: "NoPhotoAvailable.jpg")!
            } else {
                // Data for "images/island.jpg" is returned
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
