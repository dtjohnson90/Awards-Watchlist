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
import FacebookLogin
import GoogleSignIn

class LoadingNewViewController: UIViewController {

    @IBOutlet weak var loadingImage: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var testArray = [Bool](repeating: false, count: 4)
    var checkTimer: Timer!
    var error = false
    var timeLoopCheck = 0
    var oldMoviesDownloaded = 0
    var moviesDownloaded = 0
    var movieCount = Int()
    var moviesSeen = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingImage.isHidden = true
                
        do {
            let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
            let url = dir.appendingPathComponent("logFile.txt")
            try "\n\n".appendLine(to: url as URL)
            try "Initial Loading \(Date())".appendLine(to: url as URL)
            
            if url.filesize! > 200000000 {
                let fileManager = FileManager.default
                do {
                    try fileManager.removeItem(at: url)
                    let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                    let url = dir.appendingPathComponent("logFile.txt")
                    try "\n\n".appendLine(to: url as URL)
                    try "Initial Loading \(Date())".appendLine(to: url as URL)
                    try "Version: \(Items.sharedInstance.updateKey)".appendLine(to: url as URL)
                } catch {
                    self.logError(logString: "Loading VC - Attempted to delete large file", logError: error)
                }
 
            }
        }
        catch {
            print("Could not write to file")
        }
        
        if UserDefaults.standard.contains(key: "loggedIn") {
            Items.sharedInstance.loggedIn = UserDefaults.standard.string(forKey: "loggedIn")!
            Firestore.firestore().collection("Settings").document("AppInformation").getDocument { (document, error) in
                if let error = error {
                    self.logError(logString: "Loading VC - Getting 'Is Updating'", logError: error)
                    self.showError()
                } else {
                    if let document = document, document.exists {
                        Items.sharedInstance.userMovieListYear = document.data()!["listToUse"] as! String
                        Items.sharedInstance.winnerYear = document.data()!["winnerCollection"] as! String
                        Items.sharedInstance.movieList = document.data()!["movieListToUse"] as! String
                        let isUpdating = document.data()!["isUpdating"] as! Bool
                        if isUpdating {
                            self.logError(logString: "Loading VC - App is being updated")
                            let alert = UIAlertController(title: "Updating", message: document.data()!["updatingMovies"] as? String, preferredStyle: .alert)
                            let refreshAlert = UIAlertAction(title: "Refresh", style: .default, handler: { action in
                                self.restartApplication()
                            })
                            alert.addAction(refreshAlert)
                            self.present(alert, animated: true)
                        } else {
                            self.logError(logString: "Loading VC - App is not being updated")
                            if !UserDefaults.standard.contains(key: Items.sharedInstance.updateKey) {
                                self.logError(logString: "Loading VC - Logging Out New Update")
                                UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                                UserDefaults.standard.synchronize()
                                Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                                Items.sharedInstance.loggedIn = String()
                                Items.sharedInstance.moviesSeenArray.removeAll()
                                Items.sharedInstance.movieArray.removeAll()
                                LoginManager().logOut()
                                GIDSignIn.sharedInstance().signOut()
                                UserDefaults.standard.set(true, forKey: Items.sharedInstance.updateKey)
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                                }
                            } else {
                                self.getMovies()
                                self.getStarringActors()
                                self.logError(logString: "Loading VC - Logged in with \(Items.sharedInstance.loggedIn)")
                                self.loadingImage.isHidden = false
                                self.loadingImage.rotate()
                                
                                self.checkTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(LoadingNewViewController.repeatCheck),userInfo: nil, repeats: true)
                                
                                
                                let userRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                                userRef.getDocument { (document, error) in
                                    if let error = error {
                                        self.logError(logString: "Loading VC - Getting User Predictions and Image URL", logError: error)
                                        self.showError()
                                    } else {
                                        if let document = document, document.exists {
                                            self.logError(logString: "Loading VC - Downloaded Predictions and Image URL")
                                            let nomList = ["Best Picture","Best Actor","Best Actress","Supporting Actor","Supporting Actress","Animated","Cinematography","Costume Design","Directing","Documentary Feature","Documentary Short","Film Editing","Foreign","Makeup","Music Score","Music Song","Production Design","Short Animated","Short Live","Sound Editing","Sound Mixing","Visual Effects","Writing Adapted","Writing Original"]
                                            for item in nomList {
                                                Items.sharedInstance.predictions.append(document.data()![item] as! String)
                                            }
                                            let photoRef = Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn)
                                            photoRef.getDocument { (document, error) in
                                                if let error = error {
                                                    self.logError(logString: "Loading VC - Error getting users document for image URL", logError: error)
                                                    self.showError()
                                                } else {
                                                    if let document = document, document.exists {
                                                        self.logError(logString: "Loading VC - Loading photoURL to see if it should be downloaded")
                                                        let photoURL = document.data()!["imageURL"] as! String
                                                        if photoURL != "nil" {
                                                            self.downloadImage(from: URL(string: photoURL)!)
                                                        }
                                                        
                                                        self.testArray[1] = true
                                                    } else {
                                                        
                                                    }
                                                }
                                            }
                                            self.moviesSeen = document.data()!["movies"] as! [String]
                                        } else {
                                            self.logError(logString: "Loading VC - Couldn't Find User Document")
                                            self.showError()
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
                                
                                Firestore.firestore().collection("Winners").document(Items.sharedInstance.winnerYear).getDocument { (document, error) in
                                    if let error = error {
                                        self.logError(logString: "Loading VC - Getting 2020 Winners", logError: error)
                                    } else if let document = document, document.exists {
                                        self.logError(logString: "Loading VC - Getting 2020 Winners")
                                        let winners = document.data()
                                        let categories = ["Best Picture","Best Actor","Best Actress","Supporting Actor","Supporting Actress","Animated","Cinematography","Costume Design","Directing","Documentary Feature","Documentary Short","Film Editing","Foreign","Makeup","Music Score","Music Song","Production Design","Short Animated","Short Live","Sound Editing","Sound Mixing","Visual Effects","Writing Adapted","Writing Original"]
                                        for category in categories {
                                            Items.sharedInstance.winners.append(winners![category] as! String)
                                        }
                                        self.testArray[0] = true
                                    } else {
                                        self.logError(logString: "Loading VC - 2020 Document does not exist")
                                        for _ in 0...23 {
                                            Items.sharedInstance.winners.append("")
                                        }
                                        self.testArray[0] = true
                                    }
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
    
    func restartApplication () {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoadingVC") as! LoadingNewViewController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    func getStarringActors() {
        var actorCount = Int()
        let actorDoc = Firestore.firestore().collection("Actors")
        actorDoc.getDocuments() { (querySnapshot, err) in
            if let err = err {
                self.logError(logString: "Loading VC - Getting Starring Actors Error", logError: err)
                self.showError()
            } else {
                actorCount = querySnapshot!.count
                self.logError(logString: "Loading VC - Getting Starring Actors")
                for actor in querySnapshot!.documents {
                    let name = actor.documentID
                    let nominatedFor = actor.data()["NominatedFor"] as! String
                    let movie = actor.data()["Movie"] as! String
                    let actorID = actor.data()["actorID"] as! String
                    
                    let url = URL(string: "https://api.themoviedb.org/3/person/\(actorID)/images?api_key=25c47cc979a828bf884213fbe0dc7412")
                    guard let requestUrl = url else { fatalError() }
                    var request = URLRequest(url: requestUrl)
                    request.httpMethod = "GET"
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        if let error = error {
                            self.logError(logString: "Loading VC - Couldn't get error in task", logError: error)
                            return
                        }
                        
                        if let data = data {
                            do {
                                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                                    let videoArrayDict = convertedJsonIntoDict["profiles"] as! [NSDictionary]
                                    let shortFilePath = videoArrayDict[0]["file_path"] as! String
                                    let actorURL = "https://www.themoviedb.org/t/p/w200" + shortFilePath
                                    self.getData(from: URL(string: actorURL)!) { data, response, error in
                                        if let error = error {
                                            self.logError(logString: "Loading VC - Downloading Starring Actor Image for \(name)", logError: error)
                                            self.showError()
                                        } else {
                                            guard let data = data, error == nil else {
                                                self.logError(logString: "Loading VC - Error converting actor data for \(name)", logError: error)
                                                return }
                                            DispatchQueue.main.async() {
                                                Items.sharedInstance.actorArray.append(Items.actors(name: name, image: UIImage(data: data)!, nominatedFor: nominatedFor, movie: movie))
                                                if actorCount == Items.sharedInstance.actorArray.count {
                                                    self.logError(logString: "Loading VC - Done getting Starring Actors")
                                                    self.testArray[3] = true
                                                }
                                            }
                                        }
                                    }
                                }
                            } catch let error {
                                self.logError(logString: "Loading VC - Couldn't let data = data", logError: error)
                                self.showError()
                            }
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    func getMovies() {
        let movieDoc = Firestore.firestore().collection(Items.sharedInstance.movieList)
        movieDoc.getDocuments() { (querySnapshot, err) in
            if let err = err {
                self.logError(logString: "Loading VC - Accessing Movie Documents Error", logError: err)
                self.showError()
            } else {
                self.movieCount = querySnapshot!.count
                for movie in querySnapshot!.documents {
                    let movieID = movie.data()["movieID"] as! String
                    let movieNoms = movie.data()["NominatedFor"] as! [String]
                    self.getActors(movieID: movieID, nominations: movieNoms)
                }
            }
        }
    }
    
    func getActors(movieID: String, nominations: [String]) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)/credits?api_key=25c47cc979a828bf884213fbe0dc7412")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                self.logError(logString: "Loading VC - Error getting actor for \(movieID)", logError: error)
                self.showError()
                return
            }
            
            if let data = data {
                do {
                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        let castArrayDict = convertedJsonIntoDict["cast"] as! [NSDictionary]
                        var castArray = [Items.actorData]()
                        var actorCount = 0
                        if castArrayDict.count == 0 {
                            self.getYoutube(movieID: movieID, actorArray: [Items.actorData](), nominations: nominations)
                        } else {
                            for i in 0...castArrayDict.count - 1 {
                                if actorCount == 4 {
                                    break
                                }
                                let id = castArrayDict[i]["id"] as! Int
                                let name = castArrayDict[i]["name"] as! String
                                castArray.append(Items.actorData(name: name, id: String(id)))
                                actorCount += 1
                            }
                            self.getYoutube(movieID: movieID, actorArray: castArray, nominations: nominations)
                        }
                    }

                } catch let error {
                    self.logError(logString: "Loading VC - Error letting data = data for \(movieID)", logError: error)
                    self.showError()
                }
            }
            
        }
        task.resume()
    }
    
    func getYoutube(movieID: String, actorArray: [Items.actorData], nominations: [String]) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)/videos?api_key=25c47cc979a828bf884213fbe0dc7412")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                self.logError(logString: "Loading VC - Error getting Youtube for \(movieID)", logError: error)
                self.showError()
                return
            }
  
            if let data = data{
                do {
                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        let videoArrayDict = convertedJsonIntoDict["results"] as! [NSDictionary]
                        
                        struct videos {
                            let type: String
                            let id: String
                            let site: String
                        }
                        
                        var videoArray = [videos]()
                        var videoSelected = videos(type: String(), id: String(), site: String())
                        
                        for video in videoArrayDict {
                            if let type = video["type"] as? String {
                                if let site = video["site"] as? String {
                                    if let id = video["key"] as? String {
                                        videoArray.append(videos(type: type, id: id, site: site))
                                    }
                                }
                            }
                        }
                        
                        var hasTrailer = false
                        var hasClip = false
                        for vid in videoArray {
                            if vid.type == "Trailer" {
                                if vid.site == "YouTube" {
                                    videoSelected = vid
                                    hasTrailer = true
                                    break
                                }
                            }
                        }
                        
                        if !hasTrailer {
                            for vid in videoArray {
                                if vid.type == "Clip" {
                                    if vid.site == "YouTube" {
                                        videoSelected = vid
                                        hasClip = true
                                        break
                                    }
                                }
                            }
                        }
                        
                        if !hasTrailer && !hasClip {
                            for vid in videoArray {
                                if vid.site == "YouTube" {
                                    videoSelected = vid
                                    break
                                }
                            }
                        }
                        if !hasTrailer {
                            self.logError(logString: "Loading VC - \(movieID) has no trailer")
                        } else if videoSelected.id == "" {
                            self.logError(logString: "Loading VC = \(movieID) has no youtube video available")
                        }
                        self.getMovieData(movieID: movieID, actorArray: actorArray, nominations: nominations, youtube: videoSelected.id)
                    }

                } catch let error {
                    self.logError(logString: "Loading VC - Error letting youtube data = data", logError: error)
                    self.showError()
                }
            }
        }
        task.resume()
    }
    
    func getEnglishName(movieID: String, actorArray: [Items.actorData], nominations: [String], youtube: String, description: String, imdb: String, posterURL: String, originalName: String, OL: String, RD: String, RT: Int, Rev: Int, Bud: Int) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)/translations?api_key=25c47cc979a828bf884213fbe0dc7412")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                self.logError(logString: "Loading VC - Error getting English name for \(movieID)", logError: error)
                self.showError()
                return
            }
            
            if let data = data {
                do {
                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        let videoArrayDict = convertedJsonIntoDict["translations"] as! [NSDictionary]
                        var movieTitle = ""
                        for movie in videoArrayDict {
                            var englishName = ""
                            if let tryEnglish = movie["english_name"] as? String {
                                englishName = tryEnglish
                            }
                            if englishName == "English" {
                                let data = movie["data"] as! NSDictionary
                                if let tryTitle = data["title"] as? String {
                                    movieTitle = tryTitle
                                }
                                if movieTitle == "" {
                                    movieTitle = originalName
                                }
                                self.getData(from: URL(string: posterURL)!) { data, response, error in
                                    if let error = error {
                                        self.logError(logString: "Loading VC - Error getting movie image in English Name", logError: error)
                                        let tempImage = UIImage(named: "noActorImage.png")!
                                        DispatchQueue.main.async() {
                                            Items.sharedInstance.movieArray.append(Items.movie(actors: actorArray, cover: tempImage, description: description, idmb: imdb, name: movieTitle, nominatedFor: nominations, youtube: youtube, id: movieID, originalLanguage: OL, releaseDate: RD, runTime: RT, revenue: Rev, budget: Bud))
                                            if Items.sharedInstance.movieArray.count == self.movieCount {
                                                self.sortMovies()
                                            }
                                        }
                                    } else {
                                        guard let data = data, error == nil else {
                                            self.logError(logString: "Loading VC - Error letting data = data when downloading movie image (EnglishName)", logError: error)
                                            let tempImage = UIImage(named: "noActorImage.png")!
                                            DispatchQueue.main.async() {
                                                Items.sharedInstance.movieArray.append(Items.movie(actors: actorArray, cover: tempImage, description: description, idmb: imdb, name: movieTitle, nominatedFor: nominations, youtube: youtube, id: movieID, originalLanguage: OL, releaseDate: RD, runTime: RT, revenue: Rev, budget: Bud))
                                                if Items.sharedInstance.movieArray.count == self.movieCount {
                                                    self.sortMovies()
                                                }
                                            }
                                            return }
                                        DispatchQueue.main.async() {
                                            Items.sharedInstance.movieArray.append(Items.movie(actors: actorArray, cover: UIImage(data: data)!, description: description, idmb: imdb, name: movieTitle, nominatedFor: nominations, youtube: youtube, id: movieID, originalLanguage: OL, releaseDate: RD, runTime: RT, revenue: Rev, budget: Bud))
                                            if Items.sharedInstance.movieArray.count == self.movieCount {
                                                self.sortMovies()
                                            }
                                        }
                                    }
                                }
                                break
                            }
                        }
                                    
                    }
                } catch let error {
                    self.logError(logString: "Loading VC - Error letting data = data in English Name", logError: error)
                    self.showError()
                }
            }
        }
        task.resume()
    }
    
    func getMovieData(movieID: String, actorArray: [Items.actorData], nominations: [String], youtube: String) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)?api_key=25c47cc979a828bf884213fbe0dc7412")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            if let error = error {
                self.logError(logString: "Loading VC - Error getting movie data for \(movieID)", logError: error)
                self.showError()
                return
            }
            
            if let data = data {
                do {
                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        var description = "No Description Available"
                        if let tryDescription = convertedJsonIntoDict["overview"] as? String {
                            description = tryDescription
                        }
                        
                        var imdb = ""
                        if let tryIMDB = convertedJsonIntoDict["imdb_id"] as? String {
                            imdb = tryIMDB
                        }
                        
                        var posterURLShort = ""
                        if let tryPoster = convertedJsonIntoDict["poster_path"] as? String {
                            posterURLShort = tryPoster
                        }
                        let posterURL = "https://www.themoviedb.org/t/p/w300/" + posterURLShort
                        
                        var originalLanguage = ""
                        if let tryLanguage = convertedJsonIntoDict["original_language"] as? String {
                            originalLanguage = tryLanguage
                        }
                        
                        var name = ""
                        if let tryName = convertedJsonIntoDict["original_title"] as? String {
                            name = tryName
                        }
                        
                        var releaseDate = ""
                        if let tryRelease = convertedJsonIntoDict["release_date"] as? String {
                            releaseDate = tryRelease
                        }
                        
                        var runTime = 0
                        if let tryRun = convertedJsonIntoDict["runtime"] as? Int {
                            runTime = tryRun
                        }
                        
                        var revenue = 0
                        if let tryRev = convertedJsonIntoDict["revenue"] as? Int {
                            revenue = tryRev
                        }
                        
                        var budget = 0
                        if let tryBudget = convertedJsonIntoDict["budget"] as? Int {
                            budget = tryBudget
                        }
                        
                        if originalLanguage != "en" {
                            getEnglishName(movieID: movieID, actorArray: actorArray, nominations: nominations, youtube: youtube, description: description, imdb: imdb, posterURL: posterURL, originalName: name, OL: originalLanguage, RD: releaseDate, RT: runTime, Rev: revenue, Bud: budget)
                        } else {
                            self.getData(from: URL(string: posterURL)!) { data, response, error in
                                if let error = error {
                                    self.logError(logString: "Loading VC - Error downloading image in getMovieData ", logError: error)
                                    let tempImage = UIImage(named: "noActorImage.png")
                                    Items.sharedInstance.movieArray.append(Items.movie(actors: actorArray, cover: tempImage!, description: description, idmb: imdb, name: name, nominatedFor: nominations, youtube: youtube, id: movieID, originalLanguage: originalLanguage, releaseDate: releaseDate, runTime: runTime, revenue: revenue, budget: budget))
                                    if Items.sharedInstance.movieArray.count == self.movieCount {
                                        self.logError(logString: "Loading VC - Movies downloaded, starting sort")
                                        self.sortMovies()
                                    }
                                } else {
                                    guard let data = data, error == nil else {
                                        self.logError(logString: "Loading VC - Error letting data = data when downloading movie image", logError: error)
                                        let tempImage = UIImage(named: "noActorImage.png")
                                        Items.sharedInstance.movieArray.append(Items.movie(actors: actorArray, cover: tempImage!, description: description, idmb: imdb, name: name, nominatedFor: nominations, youtube: youtube, id: movieID, originalLanguage: originalLanguage, releaseDate: releaseDate, runTime: runTime, revenue: revenue, budget: budget))
                                        if Items.sharedInstance.movieArray.count == self.movieCount {
                                            self.logError(logString: "Loading VC - Movies downloaded, starting sort")
                                            self.sortMovies()
                                        }
                                        return }
                                    DispatchQueue.main.async() {
                                        Items.sharedInstance.movieArray.append(Items.movie(actors: actorArray, cover: UIImage(data: data)!, description: description, idmb: imdb, name: name, nominatedFor: nominations, youtube: youtube, id: movieID, originalLanguage: originalLanguage, releaseDate: releaseDate, runTime: runTime, revenue: revenue, budget: budget))
                                        if Items.sharedInstance.movieArray.count == self.movieCount {
                                            self.logError(logString: "Loading VC - Movies downloaded, starting sort")
                                            self.sortMovies()
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch let error {
                    self.logError(logString: "Loading VC - Error letting data = data in getMovieData", logError: error)
                    self.showError()
                }
            }
        }
        task.resume()
    }
    
    func sortMovies() {
        self.logError(logString: "Loading VC - Sorting Movies")
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
                    self.showError()
                }
            }
            sorting.leave()
        }
        sorting.notify(queue: .main) {
            self.logError(logString: "Loading VC - Movies Sorted Succesfully")
            self.testArray[2] = true
        }
    }
    
    func updateActors(){
        let actorDoc = Firestore.firestore().collection("Actors")
        actorDoc.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err)
            } else {
                for movie in querySnapshot!.documents {
                    var actorString = "https://api.themoviedb.org/3/search/person?api_key=25c47cc979a828bf884213fbe0dc7412&query="
                    var name = movie.documentID
                    name = name.replacingOccurrences(of: " ", with: "%20")
                    actorString.append(name + "&page=1")
            
                    let url = URL(string: actorString)
                    guard let requestUrl = url else { fatalError() }
                    var request = URLRequest(url: requestUrl)
                    request.httpMethod = "GET"
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        
                        if let error = error {
                            print(error)
                            return
                        }

                        if let data = data {
                            do {
                                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                                    let userId = convertedJsonIntoDict["results"] as! [NSDictionary]
                                    let resultCount = convertedJsonIntoDict["total_results"] as! Int
                                    if resultCount > 0 {
                                        let id = userId[0]["id"] as! Int
                                        actorDoc.document(movie.documentID).updateData([
                                            "actorID": String(id)
                                        ]) { err in
                                            if let err = err {
                                                print("Error updating document: \(err)")
                                            }
                                        }
                                    }
                                }
                            } catch let error {
                                print(error)
                            }
                        }
                        
                    }
                    task.resume()
                }
            }
        }
    }
    
    func updateMovies() {
        let movieDoc = Firestore.firestore().collection("Movies_2020")
        movieDoc.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                for movie in querySnapshot!.documents {
                    var movieString = "https://api.themoviedb.org/3/search/movie?api_key=25c47cc979a828bf884213fbe0dc7412&query="
                    var title = movie.documentID
                    title = title.replacingOccurrences(of: " ", with: "%20")
                    movieString.append(title + "&page=1")
            
                    let url = URL(string: movieString)
                    guard let requestUrl = url else { fatalError() }
                    var request = URLRequest(url: requestUrl)
                    request.httpMethod = "GET"
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        
                        if let error = error {
                            print("Error took place \(error)")
                            return
                        }
     
                        if let data = data{
                            do {
                                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                                    let userId = convertedJsonIntoDict["results"] as! [NSDictionary]
                                    let resultCount = convertedJsonIntoDict["total_results"] as! Int
                                    if resultCount > 0 {
                                        let id = userId[0]["id"] as! Int
                                        movieDoc.document(movie.documentID).updateData([
                                            "movieID": String(id)
                                        ]) { err in
                                            if let err = err {
                                                print("Error updating document: \(err)")
                                            }
                                        }
                                    }
                                }
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    @objc func repeatCheck() {
        moviesDownloaded = Items.sharedInstance.movieArray.count
        if timeLoopCheck == 5 {
            if moviesDownloaded > oldMoviesDownloaded {
                loadingLabel.text = "Everything is downloading!"
            } else {
                loadingLabel.text = "A slow connection might be causing issues"
            }
        } else if timeLoopCheck == 10 {
            if moviesDownloaded > oldMoviesDownloaded {
                loadingLabel.text = "They're still downloading, but very very slowly"
            } else {
                loadingLabel.text = "There's been no activity for a while..."
            }
        } else if timeLoopCheck == 15 {
            if moviesDownloaded > oldMoviesDownloaded {
                loadingLabel.text = "The internet connection might be too slow..."
            } else {
                loadingLabel.text = "I'm losing all hope that this will work..."
            }
        } else if timeLoopCheck >= 20 {
            self.showError()
        }

        timeLoopCheck += 1
        for item in testArray {
            if item == false {
                oldMoviesDownloaded = moviesDownloaded
                return
            }
        }
        
        self.logError(logString: "Loading VC - Loading Movie Seen Array")
        for item in self.moviesSeen {
            for movie in Items.sharedInstance.movieArray {
                if item == movie.name {
                    Items.sharedInstance.moviesSeenArray.append(movie)
                }
            }
        }
        
        self.logError(logString: "Loading VC - Everything Downloaded Succesfully")
        self.loadingImage.layer.removeAllAnimations()
        self.performSegue(withIdentifier: "loadingSegue", sender: self)
        checkTimer.invalidate()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            if let error = error {
                self.logError(logString: "Loading VC - Downloading Images", logError: error)
                self.showError()
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
    
    func showError() {
        checkTimer.invalidate()
        let alert = UIAlertController(title: "Error", message: "There was a problem loading the application. Please quit the app, check your internet connection, and try again", preferredStyle: .alert)
        
        let okAlert = UIAlertAction(title: "Ok", style: .default, handler: { action in
        })
        
        let logoutAlert = UIAlertAction(title: "Logout", style: .default, handler: { action in
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
                self.logError(logString: "Loading VC - Error Signing Out", logError: signOutError)
            }
        })
        
        alert.addAction(logoutAlert)
        alert.addAction(okAlert)
        self.present(alert, animated: true)
    }
    
    func logError(logString: String, logError: Error? = nil) {
        if logError == nil {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent("logFile.txt")
                try logString.appendLine(to: url as URL)
            }
            catch {
                print("Could not write to file")
            }
        } else {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent("logFile.txt")
                try logString.appendLine(to: url as URL)
                try String(describing: logError).appendLine(to: url as URL)
            }
            catch {
                print("Could not write to file")
            }
        }
    }
    
    func callError(title: String, message: String) {
        UIApplication.shared.endIgnoringInteractionEvents()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
         (result : UIAlertAction) -> Void in
         return }

        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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

extension UIView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}
