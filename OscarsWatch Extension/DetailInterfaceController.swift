//
//  DetailInterfaceController.swift
//  OscarsWatch Extension
//
//  Created by Dustin Johnson on 1/31/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class DetailInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    let session = WCSession.default
    var session2: WCSession?
    var movieChanging = String()
    
    @IBOutlet var nominationsLabel: WKInterfaceLabel!
    @IBOutlet var castLabel: WKInterfaceLabel!
    @IBOutlet var descriptionLabel: WKInterfaceLabel!
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var seenButton: WKInterfaceButton!
    
    var movie = Items2.movie(actors: [String](), description: String(), name: String(), nominatedFor: [String]())
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
                
        // Configure interface objects here.
        movie = context as! Items2.movie
        var actorString = ""
        var nominationString = ""
        
        for actor in movie.actors {
            actorString.append(actor + "\n")
        }
        
        for nomination in movie.nominatedFor {
            nominationString.append(nomination + "\n")
        }
        
        nameLabel.setText(movie.name)
        descriptionLabel.setText(movie.description)
        castLabel.setText(actorString)
        nominationsLabel.setText(nominationString)
        if Items2.sharedInstance.moviesSeenArray.contains(movie) {
            seenButton.setTitle("Seen")
            seenButton.setBackgroundColor(UIColor.green)
        }else {
            seenButton.setTitle("Unseen")
            seenButton.setBackgroundColor(UIColor.red)
        }
        
        if WCSession.isSupported() {
            session2 = WCSession.default
            session2?.delegate = self
            session2?.activate()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func validateSession() {
        if let validSession = session2 {
            
            var seenArray = [String]()
            for movie in Items2.sharedInstance.moviesSeenArray {
                seenArray.append(movie.name)
            }
            
            let iphoneAppContext = ["Seen": seenArray] as [String : [String]]
            do {
                try validSession.updateApplicationContext(iphoneAppContext)
                print("Success")
            } catch {
                print("Something went wrong")
            }
        }
    }
    
    func processApplicationContext(){
        print("Test")
        if let iPhoneContext = session.receivedApplicationContext as? [String : Any] {
            print("Test 2")
            let moviesSeen = iPhoneContext["Seen"] as! NSArray
            print(moviesSeen)
            
            Items2.sharedInstance.moviesSeenArray.removeAll()
            let downloading = DispatchGroup()
            for movie in moviesSeen {
                downloading.enter()
                let seen = movie as! NSDictionary
                Items2.sharedInstance.moviesSeenArray.append(Items2.movie(actors: seen.object(forKey: "Actors") as! [String], description: seen.object(forKey: "Description") as! String, name: seen.object(forKey: "Name") as! String, nominatedFor: seen.object(forKey: "NominatedFor") as! [String]))
                downloading.leave()
            }
            downloading.notify(queue: .main) {
                print("Changing")
                if !Items2.sharedInstance.moviesSeenArray.contains(self.movie) {
                    self.seenButton.setTitle("Unseen")
                    self.seenButton.setBackgroundColor(UIColor.red)
                } else {
                    self.seenButton.setTitle("Seen")
                    self.seenButton.setBackgroundColor(UIColor.green)
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.processApplicationContext()
        })
    }
    
    @IBAction func seenButtonClicked() {
        if Items2.sharedInstance.moviesSeenArray.contains(movie) {
            for (index,movie2) in Items2.sharedInstance.moviesSeenArray.enumerated() {
                if movie2 == movie {
                    Items2.sharedInstance.moviesSeenArray.remove(at: index)
                    self.validateSession()
                }
            }
            seenButton.setTitle("Unseen")
            seenButton.setBackgroundColor(UIColor.red)
        } else {
            Items2.sharedInstance.moviesSeenArray.append(movie)
            self.validateSession()
            seenButton.setTitle("Seen")
            seenButton.setBackgroundColor(UIColor.green)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
