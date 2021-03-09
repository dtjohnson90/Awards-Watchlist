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
//import FirebaseUI
import youtube_ios_player_helper
import FirebaseFirestore
import WatchConnectivity
import HorizontalStickyHeaderLayout

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, WCSessionDelegate {
    
    var movieSelected = Items.movie(actors: [Items.actorData](), cover: UIImage(), description: String(), idmb: String(), name: String(), nominatedFor: [String](), youtube: String(), id: String(), originalLanguage: String(), releaseDate: String(), runTime: Int(), revenue: Int(), budget: Int())
    var nominationString = ""
    var winnerString = ""
    var movieCast = ""
    var imdbString = "http://www.imdb.com/title/"
    var actorImages = [UIImage]()
    var sending: WCSession?
    let receiving = WCSession.default
    var totalLinks = 0
    var linksSeperated = [[String]]()
    var winCount = 0
    var imdbArray = [String]()
    //var streamingCount = Int()
    //var rentCount = Int()
    //var buyCount = Int()
    var totalCount = Int()
    var streamingArray = [UIImage]()
    var rentArray = [UIImage]()
    var buyArray = [UIImage]()
    var streamLink = ""
    private var gradient: CAGradientLayer!
    
    @IBOutlet weak var noProviderView: UIView!
    @IBOutlet weak var noCastLabel: UILabel!
    @IBAction func unwindToMovie(segue: UIStoryboardSegue) {}
    @IBOutlet var mySegment: UISegmentedControl!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet var castLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var actorCollectionView: UICollectionView!
    @IBOutlet var detailImage: UIImageView!
    @IBOutlet var haveWatched: UIButton!
    @IBOutlet weak var linkCollection: UICollectionView! {
        didSet {
            if #available(iOS 11.0, *) {
                linkCollection.contentInsetAdjustmentBehavior = .never
            }
            let nib = UINib(nibName: HeaderView.reuseID, bundle: .main)
            linkCollection.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseID)
            linkCollection.dataSource = self
            linkCollection.delegate = self // automatically detected if it conforms to HorizontalStickyHeaderLayoutDelegate
            linkCollection.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    @IBOutlet var youtubeView: YTPlayerView!
    @IBOutlet var detailDescriptionLabel: UILabel! = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @IBAction func viewSelect(_ sender: Any) {
        switch mySegment.selectedSegmentIndex {
        case 0:
            castLabel.isHidden = true
            actorCollectionView.isHidden = true
            detailDescriptionLabel.text = "\n" + movieSelected.description + "\n"
            detailDescriptionLabel.setNeedsLayout()
            detailDescriptionLabel.layoutIfNeeded()
            detailDescriptionLabel.isHidden = false
            viewHeight.constant = detailDescriptionLabel.bounds.height
        case 1:
            if movieSelected.actors.count == 0 {
                castLabel.isHidden = false
                detailDescriptionLabel.isHidden = true
                viewHeight.constant = castLabel.bounds.height
            } else {
                castLabel.isHidden = true
                actorCollectionView.setNeedsLayout()
                actorCollectionView.layoutIfNeeded()
                actorCollectionView.isHidden = false
                detailDescriptionLabel.isHidden = true
                viewHeight.constant = 220
            }
        case 2:
            castLabel.isHidden = true
            self.detailDescriptionLabel.text = self.nominationString + "\n"
            detailDescriptionLabel.setNeedsLayout()
            detailDescriptionLabel.layoutIfNeeded()
            self.detailDescriptionLabel.isHidden = false
            self.actorCollectionView.isHidden = true
            self.viewHeight.constant = self.detailDescriptionLabel.bounds.height
        default:
            break
        }
    }
    
    @IBAction func imdbButtonClick(_ sender: UIButton) {
        self.logError(logString: "Detail VC - IMDB Clicked")
        guard let url = URL(string: imdbString) else {
            self.logError(logString: "Detail VC - IMDB Click Failed")
            return //be safe
        }
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    @IBAction func recommendedClicked(_ sender: Any) {
        self.logError(logString: "Detail VC - Making a suggestion")
        performSegue(withIdentifier: "recommendationSegue", sender: self)
    }
    
    @IBOutlet var imdbButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkCollection.dataSource = nil
        
        gradient = CAGradientLayer()
        gradient.frame = detailImage.bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.9,1]
        detailImage.layer.mask = gradient
        
        noCastLabel.text = "No Billable Cast\n\n"
                  
        actorCollectionView.isHidden = true
        castLabel.isHidden = true
        detailDescriptionLabel.text = "\n" + movieSelected.description + "\n"
        detailDescriptionLabel.setNeedsLayout()
        detailDescriptionLabel.layoutIfNeeded()
        var count = 0
        for nomination in movieSelected.nominatedFor {
            count += 1
            var stringToAppend = ""
            switch nomination {
            case "Best Actor":
                stringToAppend = "Actor in a Leading Role"
            case "Best Actress":
                stringToAppend = "Actress in a Leading Role"
            case "Supporting Actor":
                stringToAppend = "Actor in a Supporting Role"
            case "Supporting Actress":
                stringToAppend = "Actress in a Supporting Role"
            case "Animated":
                stringToAppend = "Animated Feature Film"
            case "Documentary Feature":
                stringToAppend = "Documentary (Feature)"
            case "Documentary Short":
                stringToAppend = "Documentary (Short)"
            case "Foreign Film":
                stringToAppend = "Foreign Language Film"
            case "Makeup":
                stringToAppend = "Makeup and Hairstyling"
            case "Music Song":
                stringToAppend = "Music (Original Song)"
            case "Music Score":
                stringToAppend = "Music (Original Score"
            case "Animated Short":
                stringToAppend = "Short Filme (Animated)"
            case "Live Action Short":
                stringToAppend = "Short Filme (Live Action)"
            case "Writing Adapted":
                stringToAppend = "Writing (Adapted Screenplay)"
            case "Writing Original":
                stringToAppend = "Writing (Original Screenplay)"
            default:
                stringToAppend = nomination
            }
            if count == movieSelected.nominatedFor.count {
                nominationString.append(stringToAppend)
            } else {
                nominationString.append(stringToAppend + "\n")
            }
        }
        
        viewHeight.constant = detailDescriptionLabel.bounds.height
        detailImage.image = movieSelected.cover
        youtubeView.load(withVideoId: movieSelected.youtube, playerVars: ["playsinline": "1"])
        imdbString.append(movieSelected.idmb)
        
        haveWatched.layer.cornerRadius = haveWatched.frame.height / 2
        imdbButton.layer.cornerRadius = imdbButton.frame.height / 2
        imdbButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        if #available(iOS 13.0, *) {
            self.navigationController?.navigationBar.tintColor = UIColor.label
        } else {
            // Fallback on earlier versions
            self.navigationController?.navigationBar.tintColor = UIColor.white
        }
        
        if Items.sharedInstance.moviesSeenArray.contains(movieSelected) {
            haveWatched.setTitle("Mark As Unseen", for: .normal)
            haveWatched.backgroundColor = UIColor.systemGreen
        }
        else {
            haveWatched.setTitle("Mark As Seen", for: .normal)
            haveWatched.backgroundColor = UIColor.systemRed
        }
        
        if WCSession.isSupported() {
            sending = WCSession.default
            sending?.delegate = self
            sending?.activate()
            receiving.delegate = self
            receiving.activate()
        }
        
        getProviders()
        getMovieDetails()
        getActorIMDB()
    }
    
    func getActorIMDB() {
        for actor in movieSelected.actors {
            let url = URL(string: "https://api.themoviedb.org/3/person/\(actor.id)?api_key=25c47cc979a828bf884213fbe0dc7412")
            guard let requestUrl = url else { fatalError() }
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                if let error = error {
                    //self.logError(logString: "Loading VC - Error getting actor for \(movieID)", logError: error)
                    //self.showError()
                    return
                }
                
                if let data = data {
                    do {
                        if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                            let imdbID = convertedJsonIntoDict["imdb_id"] as? String ?? ""
                            self.imdbArray.append(imdbID)
                        }

                    } catch let error {
                        //self.logError(logString: "Loading VC - Error letting data = data for \(movieID)", logError: error)
                        //self.showError()
                    }
                }
            }
            task.resume()
        }
    }
    
    func getMovieDetails() {
        let detailString = NSMutableAttributedString()
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        if movieSelected.releaseDate != "" {
            detailString.append(NSMutableAttributedString(string: "Release Date\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 20.0)!]))
            let tempString = NSMutableAttributedString(string: "\(movieSelected.releaseDate)\n\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 18.0)!])
            if #available(iOS 13.0, *) {
                tempString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray, range: NSRange(location: 0, length: tempString.string.count))
            } else {
                // Fallback on earlier versions
                tempString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location:10,length:5))
            }
            detailString.append(tempString)
        }
        
        if movieSelected.runTime != 0 {
            let hours = movieSelected.runTime / 60
            let minutes = movieSelected.runTime % 60
            detailString.append(NSMutableAttributedString(string: "Run Time\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 20.0)!]))
            let tempString = NSMutableAttributedString(string: "\(hours)h \(minutes)m\n\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 18.0)!])
            if #available(iOS 13.0, *) {
                tempString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray, range: NSRange(location: 0, length: tempString.string.count))
            } else {
                // Fallback on earlier versions
                tempString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location:10,length:5))
            }
            detailString.append(tempString)
        }
        
        if movieSelected.originalLanguage != "" {
            let language = Locale.current.localizedString(forLanguageCode: movieSelected.originalLanguage) ?? movieSelected.originalLanguage
            detailString.append(NSMutableAttributedString(string: "Original Language\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 20.0)!]))
            let tempString = NSMutableAttributedString(string: "\(language)\n\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 18.0)!])
            if #available(iOS 13.0, *) {
                tempString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray, range: NSRange(location: 0, length: tempString.string.count))
            } else {
                // Fallback on earlier versions
                tempString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location:10,length:5))
            }
            detailString.append(tempString)
        }
        if movieSelected.budget != 0 {
            let formattedBudget = numberFormatter.string(from: NSNumber(value:movieSelected.budget))!
            detailString.append(NSMutableAttributedString(string: "Budget\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 20.0)!]))
            let tempString = NSMutableAttributedString(string: "$\(formattedBudget)\n\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 18.0)!])
            if #available(iOS 13.0, *) {
                tempString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray, range: NSRange(location: 0, length: tempString.string.count))
            } else {
                // Fallback on earlier versions
                tempString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location:10,length:5))
            }
            detailString.append(tempString)
        }
        if movieSelected.revenue != 0 {
            let formattedRevenue = numberFormatter.string(from: NSNumber(value:movieSelected.revenue))!
            detailString.append(NSMutableAttributedString(string: "Revenue\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 20.0)!]))
            let tempString = NSMutableAttributedString(string: "$\(formattedRevenue)\n\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 18.0)!])
            if #available(iOS 13.0, *) {
                tempString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray, range: NSRange(location: 0, length: tempString.string.count))
            } else {
                // Fallback on earlier versions
                tempString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location:10,length:5))
            }
            detailString.append(tempString)
        }
        detailLabel.attributedText = detailString
        detailLabel.setNeedsLayout()
        detailLabel.layoutIfNeeded()
    }
    
    func getProviders() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieSelected.id)/watch/providers?api_key=25c47cc979a828bf884213fbe0dc7412")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                //self.logError(logString: "Loading VC - Error getting actor for \(movieID)", logError: error)
                //self.showError()
                return
            }
            
            if let data = data {
                do {
                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        let results = convertedJsonIntoDict["results"] as! NSDictionary
                        if let englishResults = results["US"] as? NSDictionary {
                            if let movieLink = englishResults["link"] as? String {
                                self.streamLink = movieLink
                            }
                            if let streamData = englishResults["flatrate"] as? [NSDictionary] {
                                DispatchQueue.main.async {
                                    self.noProviderView.isHidden = true
                                }
                                self.totalCount += streamData.count
                                for stream in streamData {
                                    self.getLinkImage(providerPath: stream["logo_path"] as! String, type: "stream")
                                }
                            }
                            if let rentData = englishResults["rent"] as? [NSDictionary] {
                                DispatchQueue.main.async {
                                    self.noProviderView.isHidden = true
                                }
                                self.totalCount += rentData.count
                                for rent in rentData {
                                    self.getLinkImage(providerPath: rent["logo_path"] as! String, type: "rent")
                                }
                            }
                            if let buyData = englishResults["buy"] as? [NSDictionary] {
                                DispatchQueue.main.async {
                                    self.noProviderView.isHidden = true
                                }
                                self.totalCount += buyData.count
                                for buy in buyData {
                                    self.getLinkImage(providerPath: buy["logo_path"] as! String, type: "buy")
                                }
                            }
                        }
                    }
                } catch let error {
                    //self.logError(logString: "Loading VC - Error letting data = data for \(movieID)", logError: error)
                    //self.showError()
                }
            }
        }
        task.resume()
    }
    
    func getLinkImage(providerPath: String, type: String) {
        // Create URL
        var urlString = "https://image.tmdb.org/t/p/w200"
        urlString.append(providerPath)
        let url = URL(string: urlString)!
        getData(from: url) { data, response, error in
            if let error = error {
                print(error)
                //self.logError(logString: "Loading VC - Downloading Images", logError: error)
                //self.showError()
            } else {
                guard let data = data, error == nil else {
                    //Items.sharedInstance.profilePic = UIImage(named: "profilePic")
                    print(error)
                    return }
                if type == "stream" {
                    self.streamingArray.append(UIImage(data: data)!)
                    if self.streamingArray.count + self.rentArray.count + self.buyArray.count == self.totalCount {
                        DispatchQueue.main.async {
                            self.linkCollection.delegate = self
                            self.linkCollection.dataSource = self
                            self.linkCollection.reloadData()
                        }
                    }
                } else if type == "rent" {
                    self.rentArray.append(UIImage(data: data)!)
                    if self.streamingArray.count + self.rentArray.count + self.buyArray.count == self.totalCount {
                        DispatchQueue.main.async {
                            self.linkCollection.delegate = self
                            self.linkCollection.dataSource = self
                            self.linkCollection.reloadData()
                        }
                    }
                } else {
                    self.buyArray.append(UIImage(data: data)!)
                    if self.streamingArray.count + self.rentArray.count + self.buyArray.count == self.totalCount {
                        DispatchQueue.main.async {
                            self.linkCollection.delegate = self
                            self.linkCollection.dataSource = self
                            self.linkCollection.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            gradient.frame = detailImage.bounds
        }
    
    override func viewDidAppear(_ animated: Bool) {
        self.logError(logString: "In Detail VC")
        if Items.sharedInstance.moviesSeenArray.contains(movieSelected) {
            self.logError(logString: "Detail VC - Movie Seen")
            haveWatched.setTitle("Mark As Unseen", for: .normal)
            haveWatched.backgroundColor = UIColor.systemGreen
        }
        else {
            self.logError(logString: "Detail VC - Movie Not Seen")
            haveWatched.setTitle("Mark As Seen", for: .normal)
            haveWatched.backgroundColor = UIColor.systemRed
        }
    }
    
    func validateSession() {
        if let validSession = sending {
            self.logError(logString: "Detail VC - Sending Data To Watch")
            var movieArray = [[String:Any]]()
            for movie in Items.sharedInstance.movieArray {
                var actorArray = [String]()
                for actor in movie.actors {
                    actorArray.append(actor.name)
                }
                let movieInfo:[String:Any] = ["Name":movie.name, "Actors":actorArray, "Description":movie.description, "NominatedFor":movie.nominatedFor]
                movieArray.append(movieInfo)
            }
            
            var seenArray = [[String:Any]]()
            for movie in Items.sharedInstance.moviesSeenArray {
                var actorArray = [String]()
                for actor in movie.actors {
                    actorArray.append(actor.name)
                }
                let seenMovieInfo:[String:Any] = ["Name":movie.name, "Actors":actorArray, "Description":movie.description, "NominatedFor":movie.nominatedFor]
                seenArray.append(seenMovieInfo)
            }
            
            let date = Date()
            let formatter2 = DateFormatter()
            formatter2.timeStyle = .medium
            let dateString = formatter2.string(from: date)
            
            //let iphoneAppContext = ["Details": movieArray, "Seen": seenArray] as [String : Any]
            let iphoneAppContext = ["Seen": seenArray, "Date":dateString] as [String : Any]
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
        
        Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn).updateData([
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
    
    
    @IBAction func haveWatchedClick(_ sender: UIButton) {
        self.logError(logString: "Detail VC - Changed Seen/Unseen Button")
        if let buttonTitle = sender.title(for: .normal) {
            if buttonTitle == "Mark As Seen" {
                haveWatched.setTitle("Mark As Unseen", for: .normal)
                haveWatched.backgroundColor = UIColor.systemGreen
                Items.sharedInstance.moviesSeenArray.append(movieSelected)
                validateSession()
                
                var tempMovieArray = [String]()
                for seenMovie in Items.sharedInstance.moviesSeenArray {
                    tempMovieArray.append(seenMovie.name)
                }
                
                let configModel = ConfigurationModel()
                configModel.savedMovies = tempMovieArray
                Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn).updateData([
                    "movies": tempMovieArray
                ]) { err in
                    if let err = err {
                        self.logError(logString: "Detail VC - Unable to update document with data", logError: err.localizedDescription)
                        let alertController = UIAlertController(title: "Error", message: "There was a problem saving this information. Please quit the app and try again", preferredStyle: UIAlertController.Style.alert)
                        
                        
                        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                        }
                        
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                haveWatched.setTitle("Mark As Seen", for: .normal)
                haveWatched.backgroundColor = UIColor.systemRed
                Items.sharedInstance.moviesSeenArray.remove(at: Items.sharedInstance.moviesSeenArray.firstIndex(of:movieSelected)!)
                validateSession()
                
                var tempMovieArray = [String]()
                for seenMovie in Items.sharedInstance.moviesSeenArray {
                    tempMovieArray.append(seenMovie.name)
                }
                
                let configModel = ConfigurationModel()
                configModel.savedMovies = tempMovieArray
                Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn).updateData([
                    "movies": tempMovieArray
                ]) { err in
                    if let err = err {
                        self.logError(logString: "Detail VC - Unable to update document with data", logError: err.localizedDescription)
                        let alertController = UIAlertController(title: "Error", message: "There was a problem saving this information. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                        
                        
                        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                        }
                        
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == linkCollection {
            var count = 0
            if streamingArray.count > 0 {
                count += 1
            }
            if rentArray.count > 0 {
                count += 1
            }
            if buyArray.count > 0 {
                count += 1
            }
            return count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == actorCollectionView {
            return movieSelected.actors.count
        } else {
            if section == 0 {
                if streamingArray.count > 0 {
                    return streamingArray.count
                } else if rentArray.count > 0 {
                    return rentArray.count
                } else {
                    return buyArray.count
                }
            } else if section == 1 {
                if streamingArray.count > 0 && rentArray.count > 0 {
                    return rentArray.count
                } else {
                    return buyArray.count
                }
            } else {
                return buyArray.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == actorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actorCell", for: indexPath) as! ActorsCollectionViewCell
            
            // Create URL
            let url = URL(string: "https://api.themoviedb.org/3/person/\(movieSelected.actors[indexPath.item].id)/images?api_key=25c47cc979a828bf884213fbe0dc7412")
            guard let requestUrl = url else { fatalError() }
            // Create URL Request
            var request = URLRequest(url: requestUrl)
            // Specify HTTP Method to use
            request.httpMethod = "GET"
            // Send HTTP Request
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                // Check if Error took place
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
                
                // Read HTTP Response Status code
                //if let response = response as? HTTPURLResponse {
                    //print("Response HTTP Status code: \(response.statusCode)")
                //}
                
                // Convert HTTP Response Data to a simple String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    do {
                        //print(dataString)
                        if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                                        
                            // Print out entire dictionary
                            //print(convertedJsonIntoDict)
                            // Get value by key
                            let videoArrayDict = convertedJsonIntoDict["profiles"] as! [NSDictionary]
                            if videoArrayDict.isEmpty {
                                self.logError(logString: "Detail VC - No actor image. Using default")
                                DispatchQueue.main.async {
                                    cell.actorImage.image = UIImage(named: "noActorImage.png")
                                }
                            } else {
                                let shortFilePath = videoArrayDict[0]["file_path"] as! String
                                let actorURL = "https://www.themoviedb.org/t/p/w200" + shortFilePath
                                self.getData(from: URL(string: actorURL)!) { data, response, error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                        self.logError(logString: "Loading VC - Downloading Images", logError: error.localizedDescription)
                                        //self.showError(errorString: error.localizedDescription)
                                    } else {
                                        guard let data = data, error == nil else {
                                            print("Didn't get image")
                                            return }
                                        DispatchQueue.main.async() {
                                            cell.actorImage.image = UIImage(data: data)!
                                        }
                                    }
                                }
                            }
                        }
                    } catch let error {
                        print(error)
                    }
                } else {
                    print("Error letting data = data")
                }
                
            }
            task.resume()
            
            cell.actorName.text = movieSelected.actors[indexPath.item].name
            cell.actorName.adjustsFontSizeToFitWidth = true
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LinkCell", for: indexPath) as! WatchLinkCollectionViewCell
            
            if indexPath.section == 0 {
                if streamingArray.count > 0 {
                    cell.linkImage.image = streamingArray[indexPath.row]
                } else if rentArray.count > 0 {
                    cell.linkImage.image = rentArray[indexPath.row]
                } else {
                    cell.linkImage.image = buyArray[indexPath.row]
                }
            } else if indexPath.section == 1 {
                if streamingArray.count > 0 && rentArray.count > 0 {
                    cell.linkImage.image = rentArray[indexPath.row]
                } else {
                    cell.linkImage.image = buyArray[indexPath.row]
                }
            } else {
                cell.linkImage.image = buyArray[indexPath.row]
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let v = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseID, for: indexPath)
        if let v = v as? HeaderView {
            if indexPath.section == 0 {
                if streamingArray.count > 0 {
                    v.label?.text = "Stream"
                } else if rentArray.count > 0 {
                    v.label?.text = "Rent"
                } else {
                    v.label?.text = "Buy"
                }
            } else if indexPath.section == 1 {
                if streamingArray.count > 0 && rentArray.count > 0 {
                    v.label?.text = "Rent"
                } else {
                    v.label?.text = "Buy"
                }
            } else {
                v.label?.text = "Buy"
            }
        }
        return v
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == actorCollectionView {
            return CGSize(width: 100, height: 150)
        } else {
            return CGSize(width: 75, height: 75)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == actorCollectionView {
            let imdb = imdbArray[indexPath.row]
            var imdbActorString = "http://www.imdb.com/name/"
            if imdb != "" {
                self.logError(logString: "Detail VC - IMDB Actor Clicked")
                imdbActorString.append(imdb)
                guard let url = URL(string: imdbActorString) else {
                    self.logError(logString: "Detail VC - IMDB Actor Click Failed")
                    return
                }
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        } else {
            if streamLink != "" {
                self.logError(logString: "Detail VC - Stream Link Clicked")
                guard let url = URL(string: streamLink) else {
                    self.logError(logString: "Detail VC - Stream Link Click Failed")
                    return
                }
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recommendationSegue" {
            let secondScene = segue.destination as! RecommendationViewController
            secondScene.movieSelected = movieSelected.name
            secondScene.nominationList = linksSeperated
        }
    }
}

extension UserDefaults {
    func contains(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

extension DetailViewController: HorizontalStickyHeaderLayoutDelegate {
    private enum Const {
        static let headerSize = CGSize(width: 75, height: 26)
        static let itemSize0  = CGSize(width: 75, height: 75)
        static let itemSize1  = CGSize(width: 80, height: 80)
        static let headerLeft: CGFloat = 0
    }
    func collectionView(_ collectionView: UICollectionView, hshlSizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if collectionView == linkCollection {
            return Const.itemSize0
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, hshlSizeForHeaderAtSection section: Int) -> CGSize {
        if collectionView == linkCollection {
            return Const.headerSize
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, hshlHeaderInsetsAtSection section: Int) -> UIEdgeInsets {
        if collectionView == linkCollection {
            return UIEdgeInsets(top: 0, left: Const.headerLeft, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, hshlMinSpacingForCellsAtSection section: Int) -> CGFloat {
        if collectionView == linkCollection {
            return 10
        } else {
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, hshlSectionInsetsAtSection section: Int) -> UIEdgeInsets {
        if collectionView == linkCollection {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: section == 2 ? 0 : 25)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
