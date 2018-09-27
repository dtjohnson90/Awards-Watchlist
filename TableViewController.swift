//
//  TableViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 1/10/17.
//  Copyright © 2017 Dustin Johnson. All rights reserved.
//

import UIKit
import Foundation
import MessageUI
import CloudKit
import WatchConnectivity

class TableViewController: UITableViewController, MFMessageComposeViewControllerDelegate, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    
    var supportingActor = ["All the Money in the World","The Florida Project","The Shape of Water","Three Billboards Outside Ebbing, Missouri","Three Billboards Outside Ebbing, Missouri"]
    var bestActor2 = ["Timothée Chalamet","Gary Oldman","Daniel Kaluuya","Daniel Day-Lewis","Denzel Washington"]
    var bestActress2 = ["Margot Robbie","Saoirse Ronan","Meryl Streep","Sally Hawkins","Frances McDormand"]
    var supportingActor2 = ["Christopher Plummer", "Willem Dafoe", "Richard Jenkins", "Woody Harrelson", "Sam Rockwell"]
    var supportingActress2 = ["Allison Janney", "Laurie Metcalf","Mary J. Blige","Lesley Manville","Octavia Spencer"]
    var directing2 = ["Christopher Nolan","Jordan Peele","Greta Gerwig","Paul Thomas Anderson","Guillermo del Toro"]
    var musicSong2 = ["Mystery of Love", "Remember Me","Stand Up For Something","Mighty River","This Is Me"]
    var timer = Timer()
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBAction func unwindToList(segue: UIStoryboardSegue) {}
    @IBAction func unwindFromFriends(segue: UIStoryboardSegue) {}
    @IBOutlet var countdownTimerLabel: UILabel!
    let defaults = UserDefaults.standard
    var session: WCSession?
    
    @IBAction func shareButtonClicked(_ sender: UIBarButtonItem) {
        
        var movieString = String()
        var moviesLeftString = String()
        var moviesLeftArray = Items.sharedInstance.allMovieList
        let mCount = String(Items.sharedInstance.allMovieList.count)
        let gCount = String(Items.sharedInstance.userMovieList.count)
        
        if Items.sharedInstance.userMovieList.count > 0 {
            for item in 0...Items.sharedInstance.userMovieList.count-1 {
                movieString += (Items.sharedInstance.userMovieList[item] + "\n")
                while moviesLeftArray.contains(Items.sharedInstance.userMovieList[item]) {
                    if let itemToRemoveIndex = moviesLeftArray.index(of: Items.sharedInstance.userMovieList[item]) {
                        moviesLeftArray.remove(at: itemToRemoveIndex)
                    }
                }
            }
        }
        
        for item2 in moviesLeftArray {
            moviesLeftString += (item2 + "\n")
        }
        
        let firstString = "Seen " + gCount + " of " + mCount
        let secondString = "\n\nSeen:\n " + movieString + "\n\nUnseen:\n" + moviesLeftString
        
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        messageVC.body = firstString + secondString
        messageVC.recipients = []
        present(messageVC, animated: true, completion: nil)
    }
    @IBAction func friendsButtonClicked(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "friendSegue", sender: self)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.validateSession()
        })
    }
    
    func validateSession() {
        if let validSession = session {
            //let bestPicture = defaults.array(forKey: "BestPicture") as! [String]
            let nomCombo = [Items.sharedInstance.bestPicture,Items.sharedInstance.bestActor,Items.sharedInstance.bestActress,Items.sharedInstance.supportingActor,Items.sharedInstance.supportingActress,Items.sharedInstance.animated,Items.sharedInstance.cinematography,Items.sharedInstance.costumeDesign,Items.sharedInstance.directing,Items.sharedInstance.documentaryFeature,Items.sharedInstance.documentaryShort,Items.sharedInstance.filmEditing,Items.sharedInstance.foreignFilm,Items.sharedInstance.makeup,Items.sharedInstance.musicScore,Items.sharedInstance.musicSong,Items.sharedInstance.productionDesign,Items.sharedInstance.shortAnimated,Items.sharedInstance.shortLive,Items.sharedInstance.soundEditing,Items.sharedInstance.soundMixing,Items.sharedInstance.visualEffects,Items.sharedInstance.writingAdapted,Items.sharedInstance.writingOriginal,Items.sharedInstance.allMovieList]
            
            let iphoneAppContext = ["Nominations": nomCombo, "Details": Items.sharedInstance.allMovieDetails]
            do {
                try validSession.updateApplicationContext(iphoneAppContext)
            } catch {
                print("Something went wrong")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        
        //setDefaults()

        let dateRangeStart = Date()
        let dateRangeEnd = DateComponents(calendar: .current, year: 2018, month: 3, day: 4, hour: 17, minute: 0).date!
        let components = Calendar.current.dateComponents([.weekOfYear, .month, .day, .hour, .minute], from: dateRangeStart, to: dateRangeEnd)
        var days = 0
        
        if components.month == 1 {
            days = components.day! + 30
        } else {
            days = components.day!
        }
        
        let weeks = (components.weekOfYear ?? 0)
        days = days + (weeks * 7)
        
        /*
        if components.month == 0 && components.day == 0 {
            countdownTimerLabel.text = "\(components.hour ?? 0) hours and \(components.minute ?? 0) minutes until Ceremony"
        } else if components.month == 0 && components.day == 1 {
            countdownTimerLabel.text = "\(days) day until the Ceremony"
        }
        else {
            countdownTimerLabel.text = "\(days) days until the Ceremony"
        } */
        countdownTimerLabel.text = "Ceremony Has Commenced"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 24
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return Items.sharedInstance.bestPicture.count
        } else if (section == 1) {
            return Items.sharedInstance.bestActor.count
        } else if (section == 2) {
            return Items.sharedInstance.bestActress.count
        } else if (section == 3) {
            return supportingActor.count
        } else if (section == 4) {
            return Items.sharedInstance.supportingActress.count
        } else if (section == 5) {
            return Items.sharedInstance.animated.count
        } else if (section == 6) {
            return Items.sharedInstance.cinematography.count
        } else if (section == 7) {
            return Items.sharedInstance.costumeDesign.count
        } else if (section == 8) {
            return Items.sharedInstance.directing.count
        } else if (section == 9) {
            return Items.sharedInstance.documentaryFeature.count
        } else if (section == 10) {
            return Items.sharedInstance.documentaryShort.count
        } else if (section == 11) {
            return Items.sharedInstance.filmEditing.count
        } else if (section == 12) {
            return Items.sharedInstance.foreignFilm.count
        } else if (section == 13) {
            return Items.sharedInstance.makeup.count
        } else if (section == 14) {
            return Items.sharedInstance.musicScore.count
        } else if (section == 15) {
            return Items.sharedInstance.musicSong.count
        } else if (section == 16) {
            return Items.sharedInstance.productionDesign.count
        } else if (section == 17) {
            return Items.sharedInstance.shortAnimated.count
        } else if (section == 18) {
            return Items.sharedInstance.shortLive.count
        } else if (section == 19) {
            return Items.sharedInstance.soundEditing.count
        } else if (section == 20) {
            return Items.sharedInstance.soundMixing.count
        } else if (section == 21) {
            return Items.sharedInstance.visualEffects.count
        } else if (section == 22) {
            return Items.sharedInstance.writingAdapted.count
        } else if (section == 23) {
            return Items.sharedInstance.writingOriginal.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let gold = UIColor(hexString: "#ffe700ff")
        
        if indexPath.section == 0 && indexPath.row == 7 {
            cell.contentView.backgroundColor = gold
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        if (indexPath.section == 0){
            cell.textLabel?.text = Items.sharedInstance.bestPicture[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.bestPicture[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }

            if indexPath.row == 7 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 1){
            cell.textLabel?.text = Items.sharedInstance.bestActor[indexPath.row] + " (" + self.bestActor2[indexPath.row] + ")"
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.bestActor[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 1 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
            
        }
        if (indexPath.section == 2){
            cell.textLabel?.text = Items.sharedInstance.bestActress[indexPath.row] + " (" + self.bestActress2[indexPath.row] + ")"
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.bestActress[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 4 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 3){
            cell.textLabel?.text = supportingActor[indexPath.row] + " (" + self.supportingActor2[indexPath.row] + ")"
            if Items.sharedInstance.userMovieList.contains(supportingActor[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 4 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 4){
            cell.textLabel?.text = Items.sharedInstance.supportingActress[indexPath.row] + " (" + self.supportingActress2[indexPath.row] + ")"
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.supportingActress[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 0 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 5){
            cell.textLabel?.text = Items.sharedInstance.animated[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.animated[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 0 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 6){
            cell.textLabel?.text = Items.sharedInstance.cinematography[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.cinematography[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 0 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 7){
            cell.textLabel?.text = Items.sharedInstance.costumeDesign[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.costumeDesign[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 2 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 8){
            cell.textLabel?.text = Items.sharedInstance.directing[indexPath.row] + " (" + self.directing2[indexPath.row] + ")"
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.directing[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 4 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 9){
            cell.textLabel?.text = Items.sharedInstance.documentaryFeature[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.documentaryFeature[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 2 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 10){
            cell.textLabel?.text = Items.sharedInstance.documentaryShort[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.documentaryShort[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 1 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 11){
            cell.textLabel?.text = Items.sharedInstance.filmEditing[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.filmEditing[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 1 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 12){
            cell.textLabel?.text = Items.sharedInstance.foreignFilm[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.foreignFilm[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 0 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 13){
            cell.textLabel?.text = Items.sharedInstance.makeup[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.makeup[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 0 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 14){
            cell.textLabel?.text = Items.sharedInstance.musicScore[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.musicScore[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 3 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 15){
            cell.textLabel?.text = Items.sharedInstance.musicSong[indexPath.row] + " (" + self.musicSong2[indexPath.row] + ")"
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.musicSong[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 1 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 16){
            cell.textLabel?.text = Items.sharedInstance.productionDesign[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.productionDesign[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            if indexPath.row == 4 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 17){
            cell.textLabel?.text = Items.sharedInstance.shortAnimated[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.shortAnimated[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 0 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 18){
            cell.textLabel?.text = Items.sharedInstance.shortLive[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.shortLive[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 3 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 19){
            cell.textLabel?.text = Items.sharedInstance.soundEditing[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.soundEditing[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 2 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 20){
            cell.textLabel?.text = Items.sharedInstance.soundMixing[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.soundMixing[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 2 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 21){
            cell.textLabel?.text = Items.sharedInstance.visualEffects[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.visualEffects[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 0 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 22){
            cell.textLabel?.text = Items.sharedInstance.writingAdapted[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.writingAdapted[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 0 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        if (indexPath.section == 23){
            cell.textLabel?.text = Items.sharedInstance.writingOriginal[indexPath.row]
            if Items.sharedInstance.userMovieList.contains(Items.sharedInstance.writingOriginal[indexPath.row]){
                cell.textLabel?.textColor = UIColor.green
            }
            else {
                cell.textLabel?.textColor = UIColor.white
            }
            
            if indexPath.row == 0 {
                cell.textLabel?.textColor = UIColor(red: (207/255.0), green: (166/255.0), blue: (19/255.0), alpha: 1.0)
            }
        }
        return cell
        }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
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
        return "Null"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.black
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.brown
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let movieArray = [Items.sharedInstance.bestPicture,Items.sharedInstance.bestActor,Items.sharedInstance.bestActress,Items.sharedInstance.supportingActor,Items.sharedInstance.supportingActress,Items.sharedInstance.animated,Items.sharedInstance.cinematography,Items.sharedInstance.costumeDesign,Items.sharedInstance.directing,Items.sharedInstance.documentaryFeature,Items.sharedInstance.documentaryShort,Items.sharedInstance.filmEditing,Items.sharedInstance.foreignFilm,Items.sharedInstance.makeup,Items.sharedInstance.musicScore,Items.sharedInstance.musicSong,Items.sharedInstance.productionDesign,Items.sharedInstance.shortAnimated,Items.sharedInstance.shortLive,Items.sharedInstance.soundEditing,Items.sharedInstance.soundMixing,Items.sharedInstance.visualEffects,Items.sharedInstance.writingAdapted,Items.sharedInstance.writingOriginal]
        
        if segue.identifier == "movieSegueIdentifier" {
            let secondScene = segue.destination as! DetailViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let currentMovie = movieArray[indexPath.section][indexPath.row]
                secondScene.movieTitle = currentMovie
            }
            secondScene.viewControllerTest = "A"
        }
    }
    
    func setDefaults() {
        var imageArray = [Data]()
        var imageMovieArray = [String]()
        for item in Items.sharedInstance.movieImageList {
            let imageData = UIImageJPEGRepresentation(item[0] as! UIImage, 1.0)
            imageArray.append(imageData!)
            imageMovieArray.append(item[1] as! String)
        }
        
        defaults.set(Items.sharedInstance.bestPicture, forKey: "BestPicture")
        defaults.set(Items.sharedInstance.bestActor, forKey: "BestActor")
        defaults.set(Items.sharedInstance.bestActress, forKey: "BestActress")
        defaults.set(Items.sharedInstance.supportingActor, forKey: "SupportingActor")
        defaults.set(Items.sharedInstance.supportingActress, forKey: "SupportingActress")
        defaults.set(Items.sharedInstance.animated, forKey: "Animated")
        defaults.set(Items.sharedInstance.cinematography, forKey: "Cinematography")
        defaults.set(Items.sharedInstance.costumeDesign, forKey: "CostumeDesign")
        defaults.set(Items.sharedInstance.directing , forKey: "Directing")
        defaults.set(Items.sharedInstance.documentaryFeature, forKey: "DocumentaryFeature")
        defaults.set(Items.sharedInstance.documentaryShort, forKey: "DocumentaryShort")
        defaults.set(Items.sharedInstance.filmEditing, forKey: "FilmeEditing")
        defaults.set(Items.sharedInstance.foreignFilm, forKey: "Foreign")
        defaults.set(Items.sharedInstance.makeup, forKey: "Makeup")
        defaults.set(Items.sharedInstance.musicScore, forKey: "MusicScore")
        defaults.set(Items.sharedInstance.musicSong, forKey: "MusicSong")
        defaults.set(Items.sharedInstance.productionDesign, forKey: "ProductionDesign")
        defaults.set(Items.sharedInstance.shortAnimated, forKey: "ShortAnimated")
        defaults.set(Items.sharedInstance.shortLive, forKey: "ShortLive")
        defaults.set(Items.sharedInstance.soundEditing, forKey: "SoundEditing")
        defaults.set(Items.sharedInstance.soundMixing, forKey: "SoundMixing")
        defaults.set(Items.sharedInstance.visualEffects, forKey: "VisualEffects")
        defaults.set(Items.sharedInstance.writingAdapted, forKey: "WritingAdapted")
        defaults.set(Items.sharedInstance.writingOriginal, forKey: "WritingOriginal")
        defaults.set(Items.sharedInstance.userMovieList, forKey: "UserMovieList")
        defaults.set(Items.sharedInstance.allMovieList, forKey: "allMovieList")
        defaults.set(imageArray, forKey: "movieImagelist")
        defaults.set(imageMovieArray, forKey: "imageMovieArray")
        defaults.set(Items.sharedInstance.actorList, forKey: "actorList")
        defaults.set(Items.sharedInstance.detailList, forKey: "detailList")
        defaults.set(Items.sharedInstance.youtubeList, forKey: "youtubeList")
        defaults.set(Items.sharedInstance.imdbList, forKey: "imdbList")
        defaults.set(Items.sharedInstance.nominatedForList, forKey: "nominatedForList")
        defaults.set(Items.sharedInstance.nominations, forKey: "nominations")
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
