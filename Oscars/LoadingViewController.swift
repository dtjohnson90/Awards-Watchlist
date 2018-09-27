//
//  LoadingViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 12/8/17.
//  Copyright © 2017 Dustin Johnson. All rights reserved.
//

import UIKit
import CloudKit
import Foundation

class LoadingViewController: UIViewController {
    
    var bestPicture = [String](repeating: "", count: 10), makeup = [String](repeating: "", count: 10), bestActor = [String](repeating: "", count: 10), bestActress = [String](repeating: "", count: 10), supportingActor = [String](repeating: "", count: 10), supportingActress = [String](repeating: "", count: 10),
    animated = [String](repeating: "", count: 10), cinematography = [String](repeating: "", count: 10), costumeDesign = [String](repeating: "", count: 10), directing = [String](repeating: "", count: 10), documentaryFeature = [String](repeating: "", count: 10), documentaryShort = [String](repeating: "", count: 10), filmEditing = [String](repeating: "", count: 10), foreignFilm = [String](repeating: "", count: 10), musicScore = [String](repeating: "", count: 10), musicSong = [String](repeating: "", count: 10), productionDesign = [String](repeating: "", count: 10), shortAnimated = [String](repeating: "", count: 10), shortLive = [String](repeating: "", count: 10), soundEditing = [String](repeating: "", count: 10), soundMixing = [String](repeating: "", count: 10), visualEffects = [String](repeating: "", count: 10), writingAdapted = [String](repeating: "", count: 10), writingOriginal = [String](repeating: "", count: 10)
    var testArray = [Bool](repeating: true, count: 24)
    var checkTimer: Timer!
    var timeLoopCheck = 0
    let defaults = UserDefaults.standard
    var userMovieList = [String]()
    var allMovieList = [String]()
    var iCloudError = false
    var queryCount = 0
    var bpImage = [[Any]](), baImage = [[Any]](), basImage = [[Any]](), bsaImage = [[Any]](), bsasImage = [[Any]](), aImage = [[Any]](), cImage = [[Any]](), cdImage = [[Any]](), dImage = [[Any]](), dfImage = [[Any]](), dsImage = [[Any]](), feImage = [[Any]](), fImage = [[Any]](), mscImage = [[Any]](), msoImage = [[Any]](), pdImage = [[Any]](), shaImage = [[Any]](), shlImage = [[Any]](), seImage = [[Any]](), smImage = [[Any]](), veImage = [[Any]](), waImage = [[Any]](), woImage = [[Any]](), mImage = [[Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let defaults = UserDefaults.standard
        //if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil{
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            DispatchQueue.main.async() {
                [unowned self] in
                self.performSegue(withIdentifier: "tutorialBegin", sender: self)
                print("In Segue")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase
        let privateDB = container.privateCloudDatabase
        
        let predicate = NSPredicate(value: true)
        let userMovieQuery = CKQuery(recordType: "userMovieArray", predicate: predicate)
        privateDB.perform(userMovieQuery, inZoneWith: nil) {(results:[CKRecord]?, error: Error?) in
            var count = 0
            if error != nil {
                print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                self.iCloudError = true
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                Items.sharedInstance.userMovieList.append(movie)
                count += 1
            }
        }
        
        let nominationQuery = CKQuery(recordType: "NominationsArray", predicate: predicate)
        privateDB.perform(nominationQuery, inZoneWith: nil) {(results:[CKRecord]?, error: Error?) in
            if error != nil {
                print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                self.iCloudError = true
                return
            }
            for record in results! {
                if record.recordID.recordName == "BestPictureNomination" {
                    let movie = record.object(forKey: "BestPicture") as! String
                    Items.sharedInstance.nominations[0] = movie
                } else if record.recordID.recordName == "BestActorNomination" {
                    let movie = record.object(forKey: "BestActor") as! String
                    Items.sharedInstance.nominations[1] = movie
                } else if record.recordID.recordName == "BestActressNomination" {
                    let movie = record.object(forKey: "BestActress") as! String
                    Items.sharedInstance.nominations[2] = movie
                } else if record.recordID.recordName == "SupportingActorNomination" {
                    let movie = record.object(forKey: "SupportingActor") as! String
                    Items.sharedInstance.nominations[3] = movie
                } else if record.recordID.recordName == "SupportingActressNomination" {
                    let movie = record.object(forKey: "SupportingActress") as! String
                    Items.sharedInstance.nominations[4] = movie
                } else if record.recordID.recordName == "AnimatedNomination" {
                    let movie = record.object(forKey: "Animated") as! String
                    Items.sharedInstance.nominations[5] = movie
                } else if record.recordID.recordName == "CinematographyNomination" {
                    let movie = record.object(forKey: "Cinematography") as! String
                    Items.sharedInstance.nominations[6] = movie
                } else if record.recordID.recordName == "CostumeDesignNomination" {
                    let movie = record.object(forKey: "CostumeDesign") as! String
                    Items.sharedInstance.nominations[7] = movie
                } else if record.recordID.recordName == "DirectingNomination" {
                    let movie = record.object(forKey: "Directing") as! String
                    Items.sharedInstance.nominations[8] = movie
                } else if record.recordID.recordName == "DocumentaryFeatureNomination" {
                    let movie = record.object(forKey: "DocumentaryFeature") as! String
                    Items.sharedInstance.nominations[9] = movie
                } else if record.recordID.recordName == "DocumentaryShortNomination" {
                    let movie = record.object(forKey: "DocumentaryShort") as! String
                    Items.sharedInstance.nominations[10] = movie
                } else if record.recordID.recordName == "FilmEditingNomination" {
                    let movie = record.object(forKey: "FilmEditing") as! String
                    Items.sharedInstance.nominations[11] = movie
                } else if record.recordID.recordName == "ForeignNomination" {
                    let movie = record.object(forKey: "Foreign") as! String
                    Items.sharedInstance.nominations[12] = movie
                } else if record.recordID.recordName == "MakeupNomination" {
                    let movie = record.object(forKey: "Makeup") as! String
                    Items.sharedInstance.nominations[13] = movie
                } else if record.recordID.recordName == "MusicOriginalScoreNomination" {
                    let movie = record.object(forKey: "MusicOriginalScore") as! String
                    Items.sharedInstance.nominations[14] = movie
                } else if record.recordID.recordName == "MusicOriginalSongNomination" {
                    let movie = record.object(forKey: "MusicOriginalSong") as! String
                    Items.sharedInstance.nominations[15] = movie
                } else if record.recordID.recordName == "ProductionDesignNomination" {
                    let movie = record.object(forKey: "ProductionDesign") as! String
                    Items.sharedInstance.nominations[16] = movie
                } else if record.recordID .recordName == "ShortAnimatedNomination" {
                    let movie = record.object(forKey: "ShortAnimated") as! String
                    Items.sharedInstance.nominations[17] = movie
                } else if record.recordID.recordName == "ShortLiveNomination" {
                    let movie = record.object(forKey: "ShortLive") as! String
                    Items.sharedInstance.nominations[18] = movie
                } else if record.recordID.recordName == "SoundEditingNomination" {
                    let movie = record.object(forKey: "SoundEditing") as! String
                    Items.sharedInstance.nominations[19] = movie
                } else if record.recordID.recordName == "SoundMixingNomination" {
                    let movie = record.object(forKey: "SoundMixing") as! String
                    Items.sharedInstance.nominations[20] = movie
                } else if record.recordID.recordName == "VisualEffectsNomination" {
                    let movie = record.object(forKey: "VisualEffects") as! String
                    Items.sharedInstance.nominations[21] = movie
                } else if record.recordID.recordName == "WritingAdaptedNomination" {
                    let movie = record.object(forKey: "WritingAdapted") as! String
                    Items.sharedInstance.nominations[22] = movie
                } else if record.recordID.recordName == "WritingOriginalNomination" {
                    let movie = record.object(forKey: "WritingOriginal") as! String
                    Items.sharedInstance.nominations[23] = movie
                }
            }
        }
        
        let allMovieQuery = CKQuery(recordType: "movieArray", predicate: predicate)
        publicDB.perform(allMovieQuery, inZoneWith: nil) {(results:[CKRecord]?, error: Error?) in
            var count = 0
            if error != nil {
                print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                self.iCloudError = true
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                
                let line = record.object(forKey: "Actors") as! [String]
                var actorString = ""
                for item in line {
                    actorString.append(item + " \n")
                }
                var linesArray: [String] = []
                actorString.enumerateLines { line, _ in linesArray.append(line) }
                actorString = linesArray.filter{!$0.isEmpty}.joined(separator: "\n")
                
                let nominated = record.object(forKey: "nominatedFor") as! [String]
                var nominatedString = ""
                for item in nominated {
                    nominatedString.append(item + " \n")
                }
                var linesArray2: [String] = []
                nominatedString.enumerateLines { line, _ in linesArray2.append(line) }
                nominatedString = linesArray2.filter{!$0.isEmpty}.joined(separator: "\n")
                
                let detailInfo = record.object(forKey: "Description") as? String
                let youLink = record.object(forKey: "youtubeTag") as! String
                let imdbLink = record.object(forKey: "imdbTag") as! String
                
                var seenString = "Unseen"
                for item in Items.sharedInstance.userMovieList{
                    if item == movie {
                        seenString = "Seen"
                    }
                }
                
                self.allMovieList.append(movie)
                Items.sharedInstance.movieImageList.append([image!,movie as AnyObject])
                Items.sharedInstance.actorList.append([actorString,movie])
                Items.sharedInstance.detailList.append([detailInfo!,movie])
                Items.sharedInstance.youtubeList.append([youLink,movie])
                Items.sharedInstance.imdbList.append([imdbLink,movie])
                Items.sharedInstance.nominatedForList.append([nominatedString,movie])
                Items.sharedInstance.allMovieDetails.append([movie, detailInfo,actorString,nominatedString,seenString] as! [String])
                count += 1
            }
            Items.sharedInstance.allMovieList = self.allMovieList
        }
        
        loadDataFromCloudKit()
        
        let query1 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Best Picture'", argumentArray: nil))
        publicDB.perform(query1, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.bestPicture[count] = movie
                self.bpImage.append([image!,movie])
                count += 1
            }
            self.bestPicture = self.bestPicture.filter{$0 != ""}
            self.bestPicture = self.bestPicture.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.bestPicture = self.bestPicture
            Items.sharedInstance.bpImage = self.bpImage
            Items.sharedInstance.testArray[0] = false
        }
        let query2 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Best Actor'", argumentArray: nil))
        publicDB.perform(query2, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.baImage.append([image!,movie])
                self.bestActor[count] = movie
                count += 1
            }
            self.bestActor = self.bestActor.filter{$0 != ""}
            self.bestActor = self.bestActor.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.bestActor = self.bestActor
            Items.sharedInstance.baImage = self.baImage
            Items.sharedInstance.testArray[1] = false
        }
        let query3 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Best Actress'", argumentArray: nil))
        publicDB.perform(query3, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.basImage.append([image!,movie])
                self.bestActress[count] = movie
                count += 1
            }
            self.bestActress = self.bestActress.filter{$0 != ""}
            self.bestActress = self.bestActress.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.bestActress = self.bestActress
            Items.sharedInstance.basImage = self.basImage
            Items.sharedInstance.testArray[2] = false
        }
        let query4 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Supporting Actor'", argumentArray: nil))
        publicDB.perform(query4, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            var image = UIImage()
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                image = UIImage(data: data! as Data)!
                self.bsaImage.append([image,movie])
                self.supportingActor[count] = movie
                count += 1
            }
            self.supportingActor = self.supportingActor.filter{$0 != ""}
            self.supportingActor = self.supportingActor.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.supportingActor = self.supportingActor
            Items.sharedInstance.supportingActor.append("Three Billboards Outside Ebbing, Missouri")
            Items.sharedInstance.bsaImage = self.bsaImage
            Items.sharedInstance.testArray[3] = false
        }
        let query5 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Supporting Actress'", argumentArray: nil))
        publicDB.perform(query5, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.bsasImage.append([image!,movie])
                self.supportingActress[count] = movie
                count += 1
            }
            self.supportingActress = self.supportingActress.filter{$0 != ""}
            self.supportingActress = self.supportingActress.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.supportingActress = self.supportingActress
            Items.sharedInstance.bsasImage = self.bsasImage
            Items.sharedInstance.testArray[4] = false
        }
        let query6 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Animated'", argumentArray: nil))
        publicDB.perform(query6, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.aImage.append([image!,movie])
                self.animated[count] = movie
                count += 1
            }
            self.animated = self.animated.filter{$0 != ""}
            self.animated = self.animated.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.animated = self.animated
            Items.sharedInstance.aImage = self.aImage
            Items.sharedInstance.testArray[5] = false
        }
        let query7 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Cinematography'", argumentArray: nil))
        publicDB.perform(query7, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.cImage.append([image!,movie])
                self.cinematography[count] = movie
                count += 1
            }
            self.cinematography = self.cinematography.filter{$0 != ""}
            self.cinematography = self.cinematography.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.cinematography = self.cinematography
            Items.sharedInstance.cImage = self.cImage
            Items.sharedInstance.testArray[6] = false
        }
        let query8 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Costume Design'", argumentArray: nil))
        publicDB.perform(query8, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.cdImage.append([image!,movie])
                self.costumeDesign[count] = movie
                count += 1
            }
            self.costumeDesign = self.costumeDesign.filter{$0 != ""}
            self.costumeDesign = self.costumeDesign.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.costumeDesign = self.costumeDesign
            Items.sharedInstance.cdImage = self.cdImage
            Items.sharedInstance.testArray[7] = false
        }
        let query9 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Directing'", argumentArray: nil))
        publicDB.perform(query9, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.dImage.append([image!,movie])
                self.directing[count] = movie
                count += 1
            }
            self.directing = self.directing.filter{$0 != ""}
            self.directing = self.directing.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.directing = self.directing
            Items.sharedInstance.dImage = self.dImage
            Items.sharedInstance.testArray[8] = false
        }
        let query10 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Documentary Short'", argumentArray: nil))
        publicDB.perform(query10, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.dsImage.append([image!,movie])
                self.documentaryShort[count] = movie
                count += 1
            }
            self.documentaryShort = self.documentaryShort.filter{$0 != ""}
            self.documentaryShort = self.documentaryShort.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.documentaryShort = self.documentaryShort
            Items.sharedInstance.dsImage = self.dsImage
            Items.sharedInstance.testArray[9] = false
        }
        let query11 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Documentary Feature'", argumentArray: nil))
        publicDB.perform(query11, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.dfImage.append([image!,movie])
                self.documentaryFeature[count] = movie
                count += 1
            }
            self.documentaryFeature = self.documentaryFeature.filter{$0 != ""}
            self.documentaryFeature = self.documentaryFeature.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.documentaryFeature = self.documentaryFeature
            Items.sharedInstance.dfImage = self.dfImage
            Items.sharedInstance.testArray[10] = false
        }
        let query12 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Film Editing'", argumentArray: nil))
        publicDB.perform(query12, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.feImage.append([image!,movie])
                self.filmEditing[count] = movie
                count += 1
            }
            self.filmEditing = self.filmEditing.filter{$0 != ""}
            self.filmEditing = self.filmEditing.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.filmEditing = self.filmEditing
            Items.sharedInstance.feImage = self.feImage
            Items.sharedInstance.testArray[11] = false
        }
        let query13 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Foreign Film'", argumentArray: nil))
        publicDB.perform(query13, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.fImage.append([image!,movie])
                self.foreignFilm[count] = movie
                count += 1
            }
            self.foreignFilm = self.foreignFilm.filter{$0 != ""}
            self.foreignFilm = self.foreignFilm.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.foreignFilm = self.foreignFilm
            Items.sharedInstance.fImage = self.fImage
            Items.sharedInstance.testArray[12] = false
        }
        let query14 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Music Score'", argumentArray: nil))
        publicDB.perform(query14, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.mscImage.append([image!,movie])
                self.musicScore[count] = movie
                count += 1
            }
            self.musicScore = self.musicScore.filter{$0 != ""}
            self.musicScore = self.musicScore.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.musicScore = self.musicScore
            Items.sharedInstance.mscImage = self.mscImage
            Items.sharedInstance.testArray[13] = false
        }
        let query15 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Music Song'", argumentArray: nil))
        publicDB.perform(query15, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.msoImage.append([image!,movie])
                self.musicSong[count] = movie
                count += 1
            }
            self.musicSong = self.musicSong.filter{$0 != ""}
            self.musicSong = self.musicSong.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.musicSong = self.musicSong
            Items.sharedInstance.msoImage = self.msoImage
            Items.sharedInstance.testArray[14] = false
        }
        let query16 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Production Design'", argumentArray: nil))
        publicDB.perform(query16, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.pdImage.append([image!,movie])
                self.productionDesign[count] = movie
                count += 1
            }
            self.productionDesign = self.productionDesign.filter{$0 != ""}
            self.productionDesign = self.productionDesign.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.productionDesign = self.productionDesign
            Items.sharedInstance.pdImage = self.pdImage
            Items.sharedInstance.testArray[15] = false
        }
        let query17 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Animated Short'", argumentArray: nil))
        publicDB.perform(query17, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.shaImage.append([image!,movie])
                self.shortAnimated[count] = movie
                count += 1
            }
            self.shortAnimated = self.shortAnimated.filter{$0 != ""}
            self.shortAnimated = self.shortAnimated.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.shortAnimated = self.shortAnimated
            Items.sharedInstance.shaImage = self.shaImage
            Items.sharedInstance.testArray[16] = false
        }
        let query18 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Live Action Short'", argumentArray: nil))
        publicDB.perform(query18, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.shlImage.append([image!,movie])
                self.shortLive[count] = movie
                count += 1
            }
            self.shortLive = self.shortLive.filter{$0 != ""}
            self.shortLive = self.shortLive.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.shortLive = self.shortLive
            Items.sharedInstance.shlImage = self.shlImage
            Items.sharedInstance.testArray[17] = false
        }
        let query19 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Sound Editing'", argumentArray: nil))
        publicDB.perform(query19, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.seImage.append([image!,movie])
                self.soundEditing[count] = movie
                count += 1
            }
            self.soundEditing = self.soundEditing.filter{$0 != ""}
            self.soundEditing = self.soundEditing.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.soundEditing = self.soundEditing
            Items.sharedInstance.seImage = self.seImage
            Items.sharedInstance.testArray[18] = false
        }
        let query20 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Sound Mixing'", argumentArray: nil))
        publicDB.perform(query20, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.smImage.append([image!,movie])
                self.soundMixing[count] = movie
                count += 1
            }
            self.soundMixing = self.soundMixing.filter{$0 != ""}
            self.soundMixing = self.soundMixing.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.soundMixing = self.soundMixing
            Items.sharedInstance.smImage = self.smImage
            Items.sharedInstance.testArray[19] = false
        }
        let query21 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Visual Effects'", argumentArray: nil))
        publicDB.perform(query21, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.veImage.append([image!,movie])
                self.visualEffects[count] = movie
                count += 1
            }
            self.visualEffects = self.visualEffects.filter{$0 != ""}
            self.visualEffects = self.visualEffects.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.visualEffects = self.visualEffects
            Items.sharedInstance.veImage = self.veImage
            Items.sharedInstance.testArray[20] = false
        }
        let query22 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Writing Adapted'", argumentArray: nil))
        publicDB.perform(query22, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.waImage.append([image!,movie])
                self.writingAdapted[count] = movie
                count += 1
            }
            self.writingAdapted = self.writingAdapted.filter{$0 != ""}
            self.writingAdapted = self.writingAdapted.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.writingAdapted = self.writingAdapted
            Items.sharedInstance.waImage = self.waImage
            Items.sharedInstance.testArray[21] = false
        }
        let query23 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Writing Original'", argumentArray: nil))
        publicDB.perform(query23, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.woImage.append([image!,movie])
                self.writingOriginal[count] = movie
                count += 1
            }
            self.writingOriginal = self.writingOriginal.filter{$0 != ""}
            self.writingOriginal = self.writingOriginal.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.writingOriginal = self.writingOriginal
            Items.sharedInstance.woImage = self.woImage
            Items.sharedInstance.testArray[22] = false
        }
        let query24 = CKQuery(recordType: "movieArray", predicate: NSPredicate(format: "ANY nominatedFor = 'Makeup'", argumentArray: nil))
        publicDB.perform(query24, inZoneWith: nil) {(results:[CKRecord]?, error:Error?) in
            var count = 0
            if error != nil {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(String(describing: error))")
                    self.iCloudError = true
                }
                return
            }
            for record in results! {
                let movie = record.object(forKey: "Name") as! String
                let asset = record["movieImage"] as? CKAsset
                let data = NSData(contentsOf: (asset?.fileURL)!)
                let image = UIImage(data: data! as Data)
                self.mImage.append([image!,movie])
                self.makeup[count] = movie
                count += 1
            }
            self.makeup = self.makeup.filter{$0 != ""}
            self.makeup = self.makeup.sorted {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
            Items.sharedInstance.makeup = self.makeup
            Items.sharedInstance.mImage = self.mImage
            Items.sharedInstance.testArray[23] = false
        }
        
        checkTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(LoadingViewController.repeatCheck),userInfo: nil, repeats: true)
    }
    
    @objc func repeatCheck() {
        if timeLoopCheck > 30 || iCloudError {
            if isKeyPresentInUserDefaults(key: "BestPicture") {
                checkTimer.invalidate()
                Items.sharedInstance.bestPicture = defaults.array(forKey: "BestPicture") as! [String]
                Items.sharedInstance.bestActor = defaults.array(forKey: "BestActor") as! [String]
                Items.sharedInstance.bestActress = defaults.array(forKey: "BestActress") as! [String]
                Items.sharedInstance.supportingActor = defaults.array(forKey: "SupportingActor") as! [String]
                Items.sharedInstance.supportingActress = defaults.array(forKey: "SupportingActress") as! [String]
                Items.sharedInstance.animated = defaults.array(forKey: "Animated") as! [String]
                Items.sharedInstance.cinematography = defaults.array(forKey: "Cinematography") as! [String]
                Items.sharedInstance.costumeDesign = defaults.array(forKey: "CostumeDesign") as! [String]
                Items.sharedInstance.directing = defaults.array(forKey: "Directing") as! [String]
                Items.sharedInstance.documentaryFeature = defaults.array(forKey: "DocumentaryFeature") as! [String]
                Items.sharedInstance.documentaryShort = defaults.array(forKey: "DocumentaryShort") as! [String]
                Items.sharedInstance.filmEditing = defaults.array(forKey: "FilmeEditing") as! [String]
                Items.sharedInstance.foreignFilm = defaults.array(forKey: "Foreign") as! [String]
                Items.sharedInstance.makeup = defaults.array(forKey: "Makeup") as! [String]
                Items.sharedInstance.musicScore = defaults.array(forKey: "MusicScore") as! [String]
                Items.sharedInstance.musicSong = defaults.array(forKey: "MusicSong") as! [String]
                Items.sharedInstance.productionDesign = defaults.array(forKey: "ProductionDesign") as! [String]
                Items.sharedInstance.shortAnimated = defaults.array(forKey: "ShortAnimated") as! [String]
                Items.sharedInstance.shortLive = defaults.array(forKey: "ShortLive") as! [String]
                Items.sharedInstance.soundEditing = defaults.array(forKey: "SoundEditing") as! [String]
                Items.sharedInstance.soundMixing = defaults.array(forKey: "SoundMixing") as! [String]
                Items.sharedInstance.visualEffects = defaults.array(forKey: "VisualEffects") as! [String]
                Items.sharedInstance.writingAdapted = defaults.array(forKey: "WritingAdapted") as! [String]
                Items.sharedInstance.writingOriginal = defaults.array(forKey: "WritingOriginal") as! [String]
                Items.sharedInstance.userMovieList = defaults.array(forKey: "UserMovieList") as! [String]
                Items.sharedInstance.allMovieList = defaults.array(forKey: "allMovieList") as! [String]
                Items.sharedInstance.actorList = defaults.array(forKey: "actorList") as! [[String]]
                Items.sharedInstance.detailList = defaults.array(forKey: "detailList") as! [[String]]
                Items.sharedInstance.youtubeList = defaults.array(forKey: "youtubeList") as! [[String]]
                Items.sharedInstance.imdbList = defaults.array(forKey: "imdbList") as! [[String]]
                Items.sharedInstance.nominatedForList = defaults.array(forKey: "nominatedForList") as! [[String]]
                Items.sharedInstance.nominations = defaults.array(forKey: "nominations") as! [String]
                
                let dataArray = defaults.array(forKey: "movieImageList")
                let dataMovieArray = defaults.array(forKey: "imageMovieArray")
                var count = 0
                for item in dataArray! {
                    let imageData = UIImage(data: item as! Data)
                    let imageMovie = dataMovieArray![count]
                    Items.sharedInstance.movieImageList.append([imageData!,imageMovie as AnyObject])
                    count += 1
                }
                performSegue(withIdentifier: "loadingSegue", sender: self)
                
            } else {
                checkTimer.invalidate()
                let alertController = UIAlertController(title: "Error", message: "This app was unable to load. Please check network connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
            
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    exit(0)
    
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        timeLoopCheck += 1
        for item in Items.sharedInstance.testArray {
            if item == true {
                return
            }
        }
        performSegue(withIdentifier: "loadingSegue", sender: self)
        checkTimer.invalidate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func loadDataFromCloudKit() {
        var results: [CKRecord] = []
        let cloudContainer = CKContainer.default()
        let privateDatabase = cloudContainer.publicCloudDatabase
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "GlobalNominations", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["recordName","Count"]
        queryOperation.queuePriority = .veryHigh
        // Max limit is still 100
        queryOperation.resultsLimit = 100
        
        queryOperation.recordFetchedBlock = { (record:CKRecord!) -> Void in
            results.append(record)
        }
        
        queryOperation.queryCompletionBlock = { (cursor, error) in
            DispatchQueue.main.async() {
                if (error != nil) {
                    //print("Failed to get data from iCloud - \(error!.localizedDescription)")
                } else {
                    //print("Successfully retrieve the data form iCloud")
                    
                }
            }
            // see cursor here, if it is nil than you have no more records
            // if it has a value than you have more records to get
            if cursor != nil {
                //print("there is more data to fetch")
                let newOperation = CKQueryOperation(cursor: cursor!)
                newOperation.recordFetchedBlock = { (record:CKRecord!) -> Void in
                    results.append(record)
                }
                
                newOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                privateDatabase.add(newOperation)
            } else {
                // gets more then 100
                for record in results {
                    let nameID = record.recordID.recordName
                    let nameID2 = nameID.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890."))
                    let stripString = nameID.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted)
                    let stripInt = (stripString as NSString).integerValue - 1
                    if nameID2 == "BP" {
                        Items.sharedInstance.bpNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "BA" {
                        Items.sharedInstance.baNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "BA" {
                        Items.sharedInstance.baNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "BAS" {
                        Items.sharedInstance.basNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "BSA" {
                        Items.sharedInstance.bsaNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "BSAS" {
                        Items.sharedInstance.bsasNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "A" {
                        Items.sharedInstance.aNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "C" {
                        Items.sharedInstance.cNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "CD" {
                        Items.sharedInstance.cdNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "D" {
                        Items.sharedInstance.dNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "DF" {
                        Items.sharedInstance.dfNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "DS" {
                        Items.sharedInstance.dsNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "FE" {
                        Items.sharedInstance.feNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "F" {
                        Items.sharedInstance.fNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "M" {
                        Items.sharedInstance.mNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "MSC" {
                        Items.sharedInstance.mscNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "MSO" {
                        Items.sharedInstance.msoNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "PD" {
                        Items.sharedInstance.pdNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "SA" {
                        Items.sharedInstance.saNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "SL" {
                        Items.sharedInstance.slNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "SE" {
                        Items.sharedInstance.seNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "SM" {
                        Items.sharedInstance.smNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "VE" {
                        Items.sharedInstance.veNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "WA" {
                        Items.sharedInstance.waNominations[stripInt] = record.object(forKey: "Count") as! Int
                    } else if nameID2 == "WO" {
                        Items.sharedInstance.woNominations[stripInt] = record.object(forKey: "Count") as! Int
                    }
                }
            }
        }
        privateDatabase.add(queryOperation)
    }
}
