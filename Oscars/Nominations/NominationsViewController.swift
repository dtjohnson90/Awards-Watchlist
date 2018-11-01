//
//  NominationsViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/8/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import WatchConnectivity
import FirebaseUI
//import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn

class NominationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WCSessionDelegate, UIPopoverPresentationControllerDelegate {

    var movieSelected = Items.movie(actors: [String](), cover: UIImage(), description: String(), idmb: String(), name: String(), nominatedFor: [String](), youtube: String())
    var sending: WCSession?
    let receiving = WCSession.default
    
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var viewSwitch: UISegmentedControl!
    @IBAction func indexChanged(_ sender: Any) {
        switch viewSwitch.selectedSegmentIndex {
        case 0:
            detailTableView.isHidden = false
            listTableView.isHidden = true
            detailTableView.reloadData()
        case 1:
            detailTableView.isHidden = true
            listTableView.isHidden = false
            listTableView.reloadData()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listTableView.isHidden = true
        detailTableView.isHidden = false
        
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.year = 2019
        dateComponents.month = 2
        dateComponents.day = 25
        dateComponents.timeZone = TimeZone(abbreviation: "CST") // Japan Standard Time
        dateComponents.hour = 0
        dateComponents.minute = 0
        
        var dateComponents2 = DateComponents()
        dateComponents2.year = 2019
        dateComponents2.month = 2
        dateComponents2.day = 24
        dateComponents2.timeZone = TimeZone(abbreviation: "CST") // Japan Standard Time
        dateComponents2.hour = 19
        dateComponents2.minute = 0
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = Date()
        let date2 = calendar.date(from: dateComponents)!
        let date3 = calendar.date(from: dateComponents2)!
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        let components2 = calendar.dateComponents([.hour,.minute], from: date1, to: date3)
        
        if components.day == 0 {
            daysLeftLabel.text = "\(components2.hour!) Hours and \(components2.minute!) Minutes Until Ceremony"
        } else if components.day == 1 {
            daysLeftLabel.text = "\(components.day!) Day Until Ceremony"
        } else if components.day! < 0 {
            daysLeftLabel.text = "Ceremony Has Commenced"
        } else {
            daysLeftLabel.text = "\(components.day!) Days Until Ceremony"
        }
        daysLeftLabel.adjustsFontSizeToFitWidth = true
        
        if WCSession.isSupported() {
            sending = WCSession.default
            sending?.delegate = self
            sending?.activate()
            receiving.delegate = self
            receiving.activate()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.validateSession()
        })
        
        Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            let invitationsList = data["Invitations"] as! [String]
            if invitationsList.isEmpty {
                if let tabItems = self.tabBarController?.tabBar.items {
                    // In this case we want to modify the badge number of the third tab:
                    let tabItem = tabItems[3]
                    tabItem.badgeValue = nil
                }
            } else {
                if let tabItems = self.tabBarController?.tabBar.items {
                    // In this case we want to modify the badge number of the third tab:
                    let tabItem = tabItems[3]
                    tabItem.badgeValue = String(invitationsList.count)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.listTableView.reloadData()
            self.detailTableView.reloadData()
        }
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
                self.detailTableView.reloadData()
                self.listTableView.reloadData()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if tableView == self.detailTableView {
            return 1
        } else {
            return 24
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.detailTableView {
            return 24
        } else {
            return Items.sharedInstance.sortedMovieArray[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.detailTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NominationsTableViewCell
            
            // Configure the cell...
            switch indexPath.row {
            case 0 :
                cell.sectionLabel.text = "Best Picture"
            case 1 :
                cell.sectionLabel.text = "Actor in a Leading Role"
            case 2 :
                cell.sectionLabel.text = "Actress in a Leading Role"
            case 3 :
                cell.sectionLabel.text = "Actor in a Supporting Role"
            case 4 :
                cell.sectionLabel.text = "Actress in a Supporting Role"
            case 5 :
                cell.sectionLabel.text = "Animated Feature Film"
            case 6 :
                cell.sectionLabel.text = "Cinematography"
            case 7 :
                cell.sectionLabel.text = "Costume Design"
            case 8 :
                cell.sectionLabel.text = "Directing"
            case 9 :
                cell.sectionLabel.text = "Documentary (Feature)"
            case 10 :
                cell.sectionLabel.text = "Documentary (Short Subject)"
            case 11 :
                cell.sectionLabel.text = "Film Editing"
            case 12 :
                cell.sectionLabel.text = "Foreign Language Film"
            case 13 :
                cell.sectionLabel.text = "Makeup and Hairstyling"
            case 14 :
                cell.sectionLabel.text = "Music (Original Score)"
            case 15 :
                cell.sectionLabel.text = "Music (Original Song)"
            case 16 :
                cell.sectionLabel.text = "Production Design"
            case 17 :
                cell.sectionLabel.text = "Short Film (Animated)"
            case 18 :
                cell.sectionLabel.text = "Short Film (Live Action)"
            case 19 :
                cell.sectionLabel.text = "Sound Editing"
            case 20 :
                cell.sectionLabel.text = "Sound Mixing"
            case 21 :
                cell.sectionLabel.text = "Visual Effects"
            case 22 :
                cell.sectionLabel.text = "Writing (Adapated Screenplay)"
            case 23 :
                cell.sectionLabel.text = "Writing (Original Screenplay)"
            default :
                print("There was an error")
            }
            
            cell.sectionLabel.adjustsFontSizeToFitWidth = true
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ListTableViewCell
            let currentMovie = Items.sharedInstance.sortedMovieArray[indexPath.section][indexPath.row]
            
            cell.titleLabel.adjustsFontSizeToFitWidth = true
            cell.starringLabel.adjustsFontSizeToFitWidth = true
            
            if indexPath.section == 1 {
                for (index,actor) in Items.sharedInstance.actorArray.enumerated() {
                    if actor.nominatedFor == "Best Actor" && actor.movie == currentMovie.name {
                        cell.coverImage.image = actor.image
                        cell.titleLabel.text = actor.name
                        cell.starringLabel.text = currentMovie.name
                        var tempCount = index
                        while tempCount < Items.sharedInstance.actorArray.count {
                            if tempCount == Items.sharedInstance.actorArray.count-1 {
                                Items.sharedInstance.actorArray[tempCount] = actor
                                tempCount += 1
                            } else {
                                Items.sharedInstance.actorArray[tempCount] = Items.sharedInstance.actorArray[tempCount + 1]
                                tempCount += 1
                            }
                        }
                        break
                    }
                }
            } else if indexPath.section == 2 {
                for (index,actor) in Items.sharedInstance.actorArray.enumerated() {
                    if actor.nominatedFor == "Best Actress" && actor.movie == currentMovie.name {
                        cell.coverImage.image = actor.image
                        cell.titleLabel.text = actor.name
                        cell.starringLabel.text = currentMovie.name
                        var tempCount = index
                        while tempCount < Items.sharedInstance.actorArray.count {
                            if tempCount == Items.sharedInstance.actorArray.count-1 {
                                Items.sharedInstance.actorArray[tempCount] = actor
                                tempCount += 1
                            } else {
                                Items.sharedInstance.actorArray[tempCount] = Items.sharedInstance.actorArray[tempCount + 1]
                                tempCount += 1
                            }
                        }
                        break
                    }
                }
            } else if indexPath.section == 3 {
                for (index,actor) in Items.sharedInstance.actorArray.enumerated() {
                    if actor.nominatedFor == "Supporting Actor" && actor.movie == currentMovie.name {
                        cell.coverImage.image = actor.image
                        cell.titleLabel.text = actor.name
                        cell.starringLabel.text = currentMovie.name
                        var tempCount = index
                        while tempCount < Items.sharedInstance.actorArray.count {
                            if tempCount == Items.sharedInstance.actorArray.count-1 {
                                Items.sharedInstance.actorArray[tempCount] = actor
                                tempCount += 1
                            } else {
                                Items.sharedInstance.actorArray[tempCount] = Items.sharedInstance.actorArray[tempCount + 1]
                                tempCount += 1
                            }
                        }
                        break
                    }
                }
            } else if indexPath.section == 4 {
                for (index,actor) in Items.sharedInstance.actorArray.enumerated() {
                    if actor.nominatedFor == "Supporting Actress" && actor.movie == currentMovie.name {
                        cell.coverImage.image = actor.image
                        cell.titleLabel.text = actor.name
                        cell.starringLabel.text = currentMovie.name
                        var tempCount = index
                        while tempCount < Items.sharedInstance.actorArray.count {
                            if tempCount == Items.sharedInstance.actorArray.count-1 {
                                Items.sharedInstance.actorArray[tempCount] = actor
                                tempCount += 1
                            } else {
                                Items.sharedInstance.actorArray[tempCount] = Items.sharedInstance.actorArray[tempCount + 1]
                                tempCount += 1
                            }
                        }
                        break
                    }
                }
            } else if indexPath.section == 8 {
                for (index,actor) in Items.sharedInstance.actorArray.enumerated() {
                    if actor.nominatedFor == "Directing" && actor.movie == currentMovie.name {
                        cell.coverImage.image = actor.image
                        cell.titleLabel.text = actor.name
                        cell.starringLabel.text = currentMovie.name
                        var tempCount = index
                        while tempCount < Items.sharedInstance.actorArray.count {
                            if tempCount == Items.sharedInstance.actorArray.count-1 {
                                Items.sharedInstance.actorArray[tempCount] = actor
                                tempCount += 1
                            } else {
                                Items.sharedInstance.actorArray[tempCount] = Items.sharedInstance.actorArray[tempCount + 1]
                                tempCount += 1
                            }
                        }
                        break
                    }
                }
            }
            else {
                cell.coverImage.image = currentMovie.cover
                cell.titleLabel.text = currentMovie.name
                cell.starringLabel.text = "Starring: " + currentMovie.actors[0]
            }
            
            if Items.sharedInstance.moviesSeenArray.contains(currentMovie) {
                cell.hiddenView.isHidden = false
            } else {
                cell.hiddenView.isHidden = true
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == detailTableView {
            guard let tableViewCell = cell as? NominationsTableViewCell else { return }
        
            tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == detailTableView {
            return 220;//Choose your custom row height
        } else {
            return 75
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if tableView == listTableView {
            if (section == 0){
                return "Best Picture"
            }
            if (section == 1){
                return "Actor in a Leading Role"
            }
            if (section == 2){
                return "Actress in a Leading Role"
            }
            if (section == 3){
                return "Actor in a Supporting Role"
            }
            if (section == 4){
                return "Actress in a Supporting Role"
            }
            if (section == 5){
                return "Animated Feature Film"
            }
            if (section == 6){
                return "Cinematography"
            }
            if (section == 7){
                return "Costume Design"
            }
            if (section == 8){
                return "Directing"
            }
            if (section == 9){
                return "Documentary (Feature)"
            }
            if (section == 10){
                return "Documentary (Short Subject)"
            }
            if (section == 11){
                return "Film Editing"
            }
            if (section == 12){
                return "Foreign Language Film"
            }
            if (section == 13){
                return "Makeup and Hairstyling"
            }
            if (section == 14){
                return "Music (Original Score)"
            }
            if (section == 15){
                return "Music (Original Song)"
            }
            if (section == 16){
                return "Production Design"
            }
            if (section == 17){
                return "Short Film (Animated)"
            }
            if (section == 18){
                return "Short Film (Live Action)"
            }
            if (section == 19){
                return "Sound Editing"
            }
            if (section == 20){
                return "Sound Mixing"
            }
            if (section == 21){
                return "Visual Effects"
            }
            if (section == 22){
                return "Writing (Adapted Screenplay)"
            }
            if (section == 23){
                return "Writing (Original Screenplay)"
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        if tableView == listTableView {
            view.tintColor = UIColor.black
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.brown
            header.textLabel?.textAlignment = NSTextAlignment.center
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == listTableView {
            movieSelected = Items.sharedInstance.sortedMovieArray[indexPath.section][indexPath.row]
            performSegue(withIdentifier: "newDetail", sender: self)
        }
    }
}

extension NominationsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return Items.sharedInstance.sortedMovieArray[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NominationsCollectionViewCell
        let movieSeen = Items.sharedInstance.sortedMovieArray[collectionView.tag][indexPath.item]
        
        //if collectionView.tag == 1 || collectionView.tag == 2 || collectionView.tag == 3 || collectionView.tag == 4
        if collectionView.tag == 1 {
            for (index,actor) in Items.sharedInstance.actorArray.enumerated() {
                if actor.nominatedFor == "Best Actor" && actor.movie == movieSeen.name {
                    cell.movieImage.image = actor.image
                    cell.ActorName.text = actor.name
                    cell.ActorName.isHidden = false
                    var tempCount = index
                    while tempCount < Items.sharedInstance.actorArray.count {
                        if tempCount == Items.sharedInstance.actorArray.count-1 {
                            Items.sharedInstance.actorArray[tempCount] = actor
                            tempCount += 1
                        } else {
                            Items.sharedInstance.actorArray[tempCount] = Items.sharedInstance.actorArray[tempCount + 1]
                            tempCount += 1
                        }
                    }
                    break
                }
            }
        } else if collectionView.tag == 2 {
            for (index,actor) in Items.sharedInstance.actorArray.enumerated() {
                if actor.nominatedFor == "Best Actress" && actor.movie == movieSeen.name {
                    cell.movieImage.image = actor.image
                    cell.ActorName.text = actor.name
                    cell.ActorName.isHidden = false
                    var tempCount = index
                    while tempCount < Items.sharedInstance.actorArray.count {
                        if tempCount == Items.sharedInstance.actorArray.count-1 {
                            Items.sharedInstance.actorArray[tempCount] = actor
                            tempCount += 1
                        } else {
                            Items.sharedInstance.actorArray[tempCount] = Items.sharedInstance.actorArray[tempCount + 1]
                            tempCount += 1
                        }
                    }
                    break
                }
            }
        } else if collectionView.tag == 3 {
            for (index,actor) in Items.sharedInstance.actorArray.enumerated() {
                if actor.nominatedFor == "Supporting Actor" && actor.movie == movieSeen.name {
                    cell.movieImage.image = actor.image
                    cell.ActorName.text = actor.name
                    cell.ActorName.isHidden = false
                    var tempCount = index
                    while tempCount < Items.sharedInstance.actorArray.count {
                        if tempCount == Items.sharedInstance.actorArray.count-1 {
                            Items.sharedInstance.actorArray[tempCount] = actor
                            tempCount += 1
                        } else {
                            Items.sharedInstance.actorArray[tempCount] = Items.sharedInstance.actorArray[tempCount + 1]
                            tempCount += 1
                        }
                    }
                    break
                }
            }
        } else if collectionView.tag == 4 {
            for (index,actor) in Items.sharedInstance.actorArray.enumerated() {
                if actor.nominatedFor == "Supporting Actress" && actor.movie == movieSeen.name {
                    cell.movieImage.image = actor.image
                    cell.ActorName.text = actor.name
                    cell.ActorName.isHidden = false
                    var tempCount = index
                    while tempCount < Items.sharedInstance.actorArray.count {
                        if tempCount == Items.sharedInstance.actorArray.count-1 {
                            Items.sharedInstance.actorArray[tempCount] = actor
                            tempCount += 1
                        } else {
                            Items.sharedInstance.actorArray[tempCount] = Items.sharedInstance.actorArray[tempCount + 1]
                            tempCount += 1
                        }
                    }
                    break
                }
            }
        } else if collectionView.tag == 8 {
            for (index,actor) in Items.sharedInstance.actorArray.enumerated() {
                if actor.nominatedFor == "Directing" && actor.movie == movieSeen.name {
                    cell.movieImage.image = actor.image
                    cell.ActorName.text = actor.name
                    cell.ActorName.isHidden = false
                    var tempCount = index
                    while tempCount < Items.sharedInstance.actorArray.count {
                        if tempCount == Items.sharedInstance.actorArray.count-1 {
                            Items.sharedInstance.actorArray[tempCount] = actor
                            tempCount += 1
                        } else {
                            Items.sharedInstance.actorArray[tempCount] = Items.sharedInstance.actorArray[tempCount + 1]
                            tempCount += 1
                        }
                    }
                    break
                }
            }
        } else {
            cell.movieImage.image = movieSeen.cover
            cell.ActorName.isHidden = true
        }
        
        if Items.sharedInstance.moviesSeenArray.contains(movieSeen) {
            cell.hiddenView.isHidden = false
        } else {
            cell.hiddenView.isHidden = true
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieSelected = Items.sharedInstance.sortedMovieArray[collectionView.tag][indexPath.row]
        performSegue(withIdentifier: "newDetail", sender: self)
    }
    
    func isImageEqual (image1: UIImage, image2: UIImage) -> Bool {
        
        let imageData = UIImageJPEGRepresentation(image1 , 1.0)
        let imageData2 = UIImageJPEGRepresentation(image2 , 1.0)
        
        return imageData == imageData2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newDetail" {
            let secondScene = segue.destination as! DetailViewController
            secondScene.movieSelected = movieSelected
        } 
        
        let backItem = UIBarButtonItem()
        backItem.title = "Nominations"
        navigationItem.backBarButtonItem = backItem
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension UIImage {
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        var newImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(cgImage, in: newRect)
            if let img = context.makeImage() {
                newImage = UIImage(cgImage: img)
            }
            UIGraphicsEndImageContext()
        }
        return newImage
    }
}
