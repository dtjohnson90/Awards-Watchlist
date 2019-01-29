//
//  LoadingNewViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/8/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase
import FirebaseFirestore
import FirebaseUI
import FacebookLogin
import GoogleSignIn

class LoadingNewViewController: UIViewController {

    @IBOutlet weak var myActivityView: NVActivityIndicatorView!
    
    let updateKey = "2.0-11"
    
    var testArray = [Bool](repeating: false, count: 3)
    var checkTimer: Timer!
    var error = false
    var timeLoopCheck = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        do {
            let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
            let url = dir.appendingPathComponent("logFile.txt")
            try "\n\n".appendLine(to: url as URL)
            try "Initial Loading \(Date())".appendLine(to: url as URL)
            //let result = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
            
            if url.filesize! > 200000000 {
                let fileManager = FileManager.default
                do {
                    try fileManager.removeItem(at: url)
                    let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                    let url = dir.appendingPathComponent("logFile.txt")
                    try "\n\n".appendLine(to: url as URL)
                    try "Initial Loading \(Date())".appendLine(to: url as URL)
                    //let result = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
                } catch {
                    self.logError(logString: "Loading VC - Attempted to delete large file", logError: error.localizedDescription)
                }
 
            }
        }
        catch {
            print("Could not write to file")
        }
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db.collection("Settings").document("AppInformation").getDocument { (document, error) in
            if let error = error {
                self.logError(logString: "Loading VC - Getting 'Is Updating'", logError: error.localizedDescription)
                self.showError(errorString: error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    let isUpdating = document.data()!["isUpdating"] as! Bool
                    if isUpdating {
                        self.logError(logString: "Loading VC - App is being updated")
                        let alert = UIAlertController(title: "Updating", message: "The data in this app is currently being updated. Please try again later to see what's new!", preferredStyle: .alert)
                        self.present(alert, animated: true)
                    } else {
                        self.logError(logString: "Loading VC - App is not being updated")
                        if !UserDefaults.standard.contains(key: self.updateKey) {
                            self.logError(logString: "Loading VC - Logging Out New Update")
                            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                            UserDefaults.standard.synchronize()
                            Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                            Items.sharedInstance.loggedIn = String()
                            Items.sharedInstance.moviesSeenArray.removeAll()
                            Items.sharedInstance.movieArray.removeAll()
                            LoginManager().logOut()
                            GIDSignIn.sharedInstance().signOut()
                            UserDefaults.standard.set(true, forKey: self.updateKey)
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "loginSegue", sender: self)
                            }
                        } else {
                            if UserDefaults.standard.contains(key: "loggedIn") {
                                Items.sharedInstance.loggedIn = UserDefaults.standard.string(forKey: "loggedIn")!
                                self.logError(logString: "Loading VC - Logged in with \(Items.sharedInstance.loggedIn)")
                                
                                
                                
                                self.myActivityView.startAnimating()
                                
                                self.checkTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(LoadingNewViewController.repeatCheck),userInfo: nil, repeats: true)
                                
                                
                                let userRef = db.collection("UserMovieList").document(Items.sharedInstance.loggedIn)
                                userRef.getDocument { (document, error) in
                                    if let error = error {
                                        self.logError(logString: "Loading VC - Getting User Predictions and Image URL", logError: error.localizedDescription)
                                        self.showError(errorString: error.localizedDescription)
                                    } else {
                                        if let document = document, document.exists {
                                            self.logError(logString: "Loading VC - Downloaded Predictions and Image URL")
                                            let nomList = ["Best Picture","Best Actor","Best Actress","Supporting Actor","Supporting Actress","Animated","Cinematography","Costume Design","Directing","Documentary Feature","Documentary Short","Film Editing","Foreign","Makeup","Music Score","Music Song","Production Design","Short Animated","Short Live","Sound Editing","Sound Mixing","Visual Effects","Writing Adapted","Writing Original"]
                                            for item in nomList {
                                                Items.sharedInstance.predictions.append(document.data()![item] as! String)
                                            }
                                            let photoURL = document.data()!["Image URL"] as! String
                                            if photoURL != "nil" {
                                                self.downloadImage(from: URL(string: photoURL)!)
                                            }
                                            
                                            self.testArray[1] = true
                                        } else {
                                            self.logError(logString: "Loading VC - Couldn't Find User Document")
                                            self.showError(errorString: "Loading VC - Couldn't Find User Document")
                                        }
                                    }
                                }
                                
                                if UserDefaults.standard.contains(key: "AWPRO") {
                                    Items.sharedInstance.purchased = UserDefaults.standard.bool(forKey: "AWPRO")
                                    self.logError(logString: "Pro Purchased: \(Items.sharedInstance.purchased)")
                                } else {
                                    Items.sharedInstance.purchased = false
                                    self.logError(logString: "Pro Purchased: False")
                                }
                                
                                Firestore.firestore().collection("Actors").getDocuments() { (querySnapshot, err) in
                                    if (err != nil) {
                                        self.logError(logString: "Loading VC - Accessing Actors", logError: (err?.localizedDescription)!)
                                        self.showError(errorString: (err?.localizedDescription)!)
                                    } else {
                                        let actorDownloading = DispatchGroup()
                                        for actorList in querySnapshot!.documents {
                                            actorDownloading.enter()
                                            let actorInfo = actorList.data()
                                            let gsReference = Storage.storage().reference(forURL: "gs://oscarswatchlist.appspot.com/Actors/\(actorList.documentID).jpg")
                                            gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                                if error != nil {
                                                    // Uh-oh, an error occurred!
                                                    self.logError(logString: "Loading VC - Accesing Actors Images", logError: (error?.localizedDescription)!)
                                                    self.showError(errorString: (error?.localizedDescription)!)
                                                } else {
                                                    // Data for "images/island.jpg" is returned
                                                    Items.sharedInstance.actorArray.append(Items.actors(name: actorList.documentID, image: UIImage(data: data!)!, nominatedFor: actorInfo["NominatedFor"] as! String, movie: actorInfo["Movie"] as! String, used: false))
                                                    actorDownloading.leave()
                                                }
                                            }
                                        }
                                        actorDownloading.notify(queue: .main) {
                                            self.logError(logString: "Loading VC - Actors Downloaded Succesfully")
                                            self.testArray[0] = true
                                        }
                                    }
                                }
                                
                                let downloading = DispatchGroup()
                                Firestore.firestore().collection("Movies").getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        self.logError(logString: "Loading VC - Accessing Movies", logError: err.localizedDescription)
                                        self.showError(errorString: err.localizedDescription)
                                    } else {
                                        for movie in querySnapshot!.documents {
                                            downloading.enter()
                                            let movieData = movie.data()
                                            let imageReference = Storage.storage().reference(forURL: movieData["Cover"] as! String)
                                            
                                            imageReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                                if let error = error {
                                                    // Uh-oh, an error occurred!
                                                    self.logError(logString: "Loading VC - Getting Cover Images", logError: error.localizedDescription)
                                                    self.showError(errorString: error.localizedDescription)
                                                } else {
                                                    // Data for "images/island.jpg" is returned
                                                    let image = UIImage(data: data!)
                                                    Items.sharedInstance.movieArray.append(Items.movie(actors: movieData["Actors"] as! [String], cover: image!, description: movieData["Description"] as! String, idmb: movieData["IMDB"] as! String, name: movie.documentID, nominatedFor: movieData["NominatedFor"] as! [String], youtube: movieData["Youtube"] as! String))
                                                    downloading.leave()
                                                }
                                            }
                                        }
                                        
                                        downloading.notify(queue: .main) {
                                            // All movies are done downloading
                                            self.logError(logString: "Loading VC - Movies Downloaded Succesfully")
                                            let hanlderBlock: (Bool) -> Void = { doneWork in
                                                if doneWork {
                                                    let sorting = DispatchGroup()
                                                    for _ in 0 ... 23 {
                                                        Items.sharedInstance.sortedMovieArray.append([Items.movie]())
                                                    }
                                                    for movie in Items.sharedInstance.movieArray {
                                                        sorting.enter()
                                                        for nomination in movie.nominatedFor {
                                                            switch nomination {
                                                            case "Best Picture":
                                                                Items.sharedInstance.sortedMovieArray[0].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 0, movie: movie)
                                                                }
                                                            case "Best Actor":
                                                                Items.sharedInstance.sortedMovieArray[1].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 1, movie: movie)
                                                                }
                                                                
                                                            case "Best Actress":
                                                                Items.sharedInstance.sortedMovieArray[2].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 2, movie: movie)
                                                                }
                                                            case "Supporting Actor":
                                                                Items.sharedInstance.sortedMovieArray[3].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 3, movie: movie)
                                                                }
                                                            case "Supporting Actress":
                                                                Items.sharedInstance.sortedMovieArray[4].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 4, movie: movie)
                                                                }
                                                            case "Animated":
                                                                Items.sharedInstance.sortedMovieArray[5].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 5, movie: movie)
                                                                }
                                                            case "Cinematography":
                                                                Items.sharedInstance.sortedMovieArray[6].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 6, movie: movie)
                                                                }
                                                            case "Costume Design":
                                                                Items.sharedInstance.sortedMovieArray[7].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 7, movie: movie)
                                                                }
                                                            case "Directing":
                                                                Items.sharedInstance.sortedMovieArray[8].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 8, movie: movie)
                                                                }
                                                            case "Documentary Feature":
                                                                Items.sharedInstance.sortedMovieArray[9].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 9, movie: movie)
                                                                }
                                                            case "Documentary Short":
                                                                Items.sharedInstance.sortedMovieArray[10].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 10, movie: movie)
                                                                }
                                                            case "Film Editing":
                                                                Items.sharedInstance.sortedMovieArray[11].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 11, movie: movie)
                                                                }
                                                            case "Foreign Film":
                                                                Items.sharedInstance.sortedMovieArray[12].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 12, movie: movie)
                                                                }
                                                            case "Makeup":
                                                                Items.sharedInstance.sortedMovieArray[13].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 13, movie: movie)
                                                                }
                                                            case "Music Score":
                                                                Items.sharedInstance.sortedMovieArray[14].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 14, movie: movie)
                                                                }
                                                            case "Music Song":
                                                                Items.sharedInstance.sortedMovieArray[15].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 15, movie: movie)
                                                                }
                                                            case "Production Design":
                                                                Items.sharedInstance.sortedMovieArray[16].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 16, movie: movie)
                                                                }
                                                            case "Animated Short":
                                                                Items.sharedInstance.sortedMovieArray[17].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 17, movie: movie)
                                                                }
                                                            case "Live Action Short":
                                                                Items.sharedInstance.sortedMovieArray[18].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 18, movie: movie)
                                                                }
                                                            case "Sound Editing":
                                                                Items.sharedInstance.sortedMovieArray[19].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 19, movie: movie)
                                                                }
                                                            case "Sound Mixing":
                                                                Items.sharedInstance.sortedMovieArray[20].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 20, movie: movie)
                                                                }
                                                            case "Visual Effects":
                                                                Items.sharedInstance.sortedMovieArray[21].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 21, movie: movie)
                                                                }
                                                            case "Writing Adapted":
                                                                Items.sharedInstance.sortedMovieArray[22].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 22, movie: movie)
                                                                }
                                                            case "Writing Original":
                                                                Items.sharedInstance.sortedMovieArray[23].append(movie)
                                                                if !Items.sharedInstance.moviesSeenArray.contains(movie) {
                                                                    self.sortMovies(column: 23, movie: movie)
                                                                }
                                                            default:
                                                                self.logError(logString: "Loading VC - Accessed Default While Sorting")
                                                                self.showError(errorString: "Loading VC - Accessed Default While Sorting")
                                                            }
                                                        }
                                                        sorting.leave()
                                                    }
                                                    sorting.notify(queue: .main) {
                                                        self.logError(logString: "Loading VC - Movies Sorted Succesfully")
                                                        self.testArray[2] = true
                                                    }
                                                }
                                            }
                                            
                                            Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).getDocument { (document, error) in
                                                if let error = error {
                                                    self.logError(logString: "Loading VC - Downloading User Document", logError: error.localizedDescription)
                                                    self.showError(errorString: error.localizedDescription)
                                                } else {
                                                    if let document = document, document.exists {
                                                        let moviesSeen = document.data()!["movies"] as! [String]
                                                        let downloading2 = DispatchGroup()
                                                        
                                                        for item in moviesSeen {
                                                            downloading2.enter()
                                                            for movie in Items.sharedInstance.movieArray {
                                                                if item == movie.name {
                                                                    Items.sharedInstance.moviesSeenArray.append(movie)
                                                                    downloading2.leave()
                                                                }
                                                            }
                                                        }
                                                        downloading2.notify(queue: .main) {
                                                            self.logError(logString: "Loading VC - Downloaded User Data Succesfully")
                                                            hanlderBlock(true)
                                                        }
                                                    } else {
                                                        self.logError(logString: "Loading VC - Couldn't Find User Document")
                                                        self.showError(errorString: "Loading VC - Couldn't Find User Document")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func repeatCheck() {
        if timeLoopCheck >= 20 {
            self.showError(errorString: "Time Error")
        }
        timeLoopCheck += 1
        for item in testArray {
            if item == false {
                return
            }
        }
        self.logError(logString: "Loading VC - Everything Downloaded Succesfully")
        myActivityView.stopAnimating()
        self.performSegue(withIdentifier: "loadingSegue", sender: self)
        checkTimer.invalidate()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            if let error = error {
                self.logError(logString: "Loading VC - Downloading Images", logError: error.localizedDescription)
                self.showError(errorString: error.localizedDescription)
            } else {
                guard let data = data, error == nil else {
                    Items.sharedInstance.profilePic = UIImage(named: "profilePic")
                    return }
                DispatchQueue.main.async() {
                    Items.sharedInstance.profilePic = UIImage(data: data)
                }
            }
        }
    }
    
    func sortMovies(column: Int, movie: Items.movie) {
        var movieCount = Items.sharedInstance.sortedMovieArray[column].count
        while movieCount > 0 {
            if movieCount == 1 {
                Items.sharedInstance.sortedMovieArray[column][0] = movie
                movieCount -= 1
            } else {
                Items.sharedInstance.sortedMovieArray[column][movieCount-1] = Items.sharedInstance.sortedMovieArray[column][movieCount-2]
                movieCount -= 1
            }
        }
    }
    
    func showError(errorString: String) {
        print(errorString)
        checkTimer.invalidate()
        let alert = UIAlertController(title: "Error", message: "There was a problem loading the application. Please quit the application and try again", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
            Items.sharedInstance.predictions = [String](repeating: "", count: 24)
            Items.sharedInstance.loggedIn = String()
            Items.sharedInstance.moviesSeenArray.removeAll()
            LoginManager().logOut()
            GIDSignIn.sharedInstance().signOut()
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                self.logError(logString: "Loading VC - Error Signing Out", logError: signOutError.localizedDescription)
            }
        }))
        
        self.present(alert, animated: true)
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

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension String {
    func appendLine(to url: URL) throws {
        try self.appending("\n").append(to: url)
    }
    func append(to url: URL) throws {
        let data = self.data(using: String.Encoding.utf8)
        try data?.append(to: url)
    }
}

extension Data {
    func append(to url: URL) throws {
        if let fileHandle = try? FileHandle(forWritingTo: url) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        } else {
            try write(to: url)
        }
    }
}

extension URL {
    var filesize: Int? {
        let set = Set.init([URLResourceKey.fileSizeKey])
        var filesize: Int?
        do {
            let values = try self.resourceValues(forKeys: set)
            if let theFileSize = values.fileSize {
                filesize = theFileSize
            }
        }
        catch {
            print(error.localizedDescription)
        }
        return filesize
    }
    
    var filesizeNicelyformatted: String? {
        guard let fileSize = self.filesize else {
            return nil
        }
        return ByteCountFormatter.init().string(fromByteCount: Int64(fileSize))
    }
}
