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
        self.logError(logString: "Detail VC - IMDB Clicked")
        guard let url = URL(string: imdbString) else {
            self.logError(logString: "Detail VC - IMDB Click Failed")
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
        self.logError(logString: "In Detail VC")
        if Items.sharedInstance.moviesSeenArray.contains(movieSelected) {
            self.logError(logString: "Detail VC - Movie Seen")
            haveWatched.setTitle("Seen", for: .normal)
            haveWatched.backgroundColor = UIColor.green
        }
        else {
            self.logError(logString: "Detail VC - Movie Not Seen")
            haveWatched.setTitle("Unseen", for: .normal)
            haveWatched.backgroundColor = UIColor.red
        }
    }
    
    func validateSession() {
        if let validSession = sending {
            self.logError(logString: "Detail VC - Sending Data To Watch")
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
            } catch {
                self.logError(logString: "Detail VC - Error Sending Data To Watch", logError: error.localizedDescription)
            }
        }
    }
    
    func processApplicationContext(){
        if let iPhoneContext = receiving.receivedApplicationContext as? [String : [String]] {
            self.logError(logString: "Detail VC - Receiving Data From Watch")
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
        
        let configModel = ConfigurationModel()
        configModel.savedMovies = tempMovieArray
        
        Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).updateData([
            "movies": tempMovieArray
        ]) { err in
            if let err = err {
                self.logError(logString: "Detail VC - Couldn't update document with watch data", logError: err.localizedDescription)
            } else {
                self.logError(logString: "Detail VC - Document updated with watch data")
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
        guard let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)") else {
            self.logError(logString: "Detail VC - Unable to load youtube video")
            return
        }
        wv.loadRequest( URLRequest(url: youtubeURL) )
    }
    
    @IBAction func haveWatchedClick(_ sender: UIButton) {
        self.logError(logString: "Detail VC - Changed Seen/Unseen Button")
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
                
                let configModel = ConfigurationModel()
                configModel.savedMovies = tempMovieArray
                Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).updateData([
                    "movies": tempMovieArray
                ]) { err in
                    if let err = err {
                        self.logError(logString: "Detail VC - Unable to update document with data", logError: err.localizedDescription)
                        let alertController = UIAlertController(title: "Error", message: "There was a problem saving this information. Please quit the app and try again", preferredStyle: UIAlertControllerStyle.alert)
                        
                        
                        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                        }
                        
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
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
                
                let configModel = ConfigurationModel()
                configModel.savedMovies = tempMovieArray
                Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).updateData([
                    "movies": tempMovieArray
                ]) { err in
                    if let err = err {
                        self.logError(logString: "Detail VC - Unable to update document with data", logError: err.localizedDescription)
                        let alertController = UIAlertController(title: "Error", message: "There was a problem saving this information. Please quit the app and try again.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        
                        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                        }
                        
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
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
            if let error = error {
                // Uh-oh, an error occurred!
                self.logError(logString: "Detail VC - Unable to get Actor image. Setting No Photo Available", logError: error.localizedDescription)
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
    
    func logError(logString: String, logError: String = "") {
        if logError == "" {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent("logFile.txt")
                try logString.appendLine(to: url as URL)
                //let result = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
            }
            catch {
                print("Could not write to file")
            }
        } else {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent("logFile.txt")
                try logString.appendLine(to: url as URL)
                try logError.appendLine(to: url as URL)
                //let result = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
            }
            catch {
                print("Could not write to file")
            }
        }
    }
}

extension UserDefaults {
    func contains(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
