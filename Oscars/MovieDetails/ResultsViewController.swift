//
//  ResultsViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/15/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct movieInfo {
        let image: UIImage
        let name: String
        let votes: Int
    }
    
    @IBOutlet weak var votedLabel: UILabel!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var resultsChosen = Int()
    var movieArray = [movieInfo]()
    var totalVotes = 0
    var bestActorArray = [Items.actors]()
    var bestActressArray = [Items.actors]()
    var supportingActorArray = [Items.actors]()
    var supportingActressArray = [Items.actors]()
    var directorArray = [Items.actors]()
    let categoryArray = ["Best Picture","Best Actor","Best Actress","Supporting Actor","Supporting Actress","Animated","Cinematography","Costume Design","Directing","Documentary Feature","Documentary Short","Film Editing","Foreign","Makeup","Music Score","Music Song","Production Design","Short Animated","Short Live","Sound Editing","Sound Mixing","Visual Effects","Writing Adapted","Writing Original"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.logError(logString: "Loading Results For \(categoryArray[resultsChosen])")
        
        resultsTableView.dataSource = nil
        
        let votedFor = Items.sharedInstance.predictions[resultsChosen]
        if votedFor == "" {
            votedLabel.text = "You haven't voted for this category"
        } else {
            votedLabel.text = "You voted for '" + Items.sharedInstance.predictions[resultsChosen] + "'"
        }
        votedLabel.adjustsFontSizeToFitWidth = true
        
        for item in Items.sharedInstance.actorArray {
            switch item.nominatedFor {
            case "Best Actor":
                bestActorArray.append(item)
            case "Supporting Actor":
                supportingActorArray.append(item)
            case "Best Actress":
                bestActressArray.append(item)
            case "Supporting Actress":
                supportingActressArray.append(item)
            case "Directing":
                directorArray.append(item)
            default:
                return
            }
        }
        
        if resultsChosen == 1 || resultsChosen == 2 || resultsChosen == 3 || resultsChosen == 4 || resultsChosen == 8 {
            Firestore.firestore().collection("Predictions").document(categoryArray[resultsChosen]).getDocument { (document, error) in
                if let error = error {
                    
                } else {
                    if let document = document, document.exists {
                        let addingVotes = DispatchGroup()
                        switch self.resultsChosen {
                        case 1:
                            for actor in self.bestActorArray {
                                addingVotes.enter()
                                self.totalVotes += document.data()![actor.name] as! Int
                                addingVotes.leave()
                            }
                        case 2:
                            for actor in self.bestActressArray {
                                addingVotes.enter()
                                self.totalVotes += document.data()![actor.name] as! Int
                                addingVotes.leave()
                            }
                        case 3:
                            for actor in self.supportingActorArray {
                                addingVotes.enter()
                                self.totalVotes += document.data()![actor.name] as! Int
                                addingVotes.leave()
                            }
                        case 4:
                            for actor in self.supportingActressArray {
                                addingVotes.enter()
                                self.totalVotes += document.data()![actor.name] as! Int
                                addingVotes.leave()
                            }
                        case 8:
                            for actor in self.directorArray {
                                addingVotes.enter()
                                self.totalVotes += document.data()![actor.name] as! Int
                                addingVotes.leave()
                            }
                        default:
                            return
                        }
                        addingVotes.notify(queue: .main) {
                            switch self.resultsChosen {
                            case 1:
                                for actor in self.bestActorArray {
                                    self.movieArray.append(movieInfo(image: actor.image, name: actor.name, votes: document.data()![actor.name] as! Int))
                                }
                            case 2:
                                for actor in self.bestActressArray {
                                    self.movieArray.append(movieInfo(image: actor.image, name: actor.name, votes: document.data()![actor.name] as! Int))
                                }
                            case 3:
                                for actor in self.supportingActorArray {
                                    self.movieArray.append(movieInfo(image: actor.image, name: actor.name, votes: document.data()![actor.name] as! Int))
                                }
                            case 4:
                                for actor in self.supportingActressArray {
                                    self.movieArray.append(movieInfo(image: actor.image, name: actor.name, votes: document.data()![actor.name] as! Int))
                                }
                            case 8:
                                for actor in self.directorArray {
                                    self.movieArray.append(movieInfo(image: actor.image, name: actor.name, votes: document.data()![actor.name] as! Int))
                                }
                            default:
                                return
                            }
                            self.logError(logString: "Results VC - All Results Loaded Succesfully")
                            self.resultsTableView.dataSource = self
                            self.resultsTableView.reloadData()
                        }
                    } else {
                        self.logError(logString: "Results VC - Results document does not exist")
                        let alertController = UIAlertController(title: "Error", message: "There was a problem accessing the results. Please quit the app and try again.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        
                        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                        }
                        
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            Firestore.firestore().collection("Predictions").document(categoryArray[resultsChosen]).getDocument { (document, error) in
                if let error = error {
                    self.logError(logString: "Results VC - Error Getting Predictions Document", logError: error.localizedDescription)
                } else {
                    if let document = document, document.exists {
                        let addingVotes = DispatchGroup()
                        for movie in Items.sharedInstance.sortedMovieArray[self.resultsChosen] {
                            addingVotes.enter()
                            self.totalVotes += document.data()![movie.name] as! Int
                            addingVotes.leave()
                        }
                        addingVotes.notify(queue: .main) {
                            for movie in Items.sharedInstance.sortedMovieArray[self.resultsChosen] {
                                self.movieArray.append(movieInfo(image: movie.cover, name: movie.name, votes: document.data()![movie.name] as! Int))
                            }
                            self.logError(logString: "Results VC - All Results Loaded Succesfully")
                            self.resultsTableView.dataSource = self
                            self.resultsTableView.reloadData()
                        }
                    } else {
                        self.logError(logString: "Results VC - Results document does not exist")
                        let alertController = UIAlertController(title: "Error", message: "There was a problem accessing the results. Please quit the app and try again.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Items.sharedInstance.sortedMovieArray[resultsChosen].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultsTableViewCell
        
        cell.movieImage.image = movieArray[indexPath.row].image
        cell.movieTitle.text = movieArray[indexPath.row].name
        cell.movieVotes.text = String(movieArray[indexPath.row].votes) + "/" + String(totalVotes) + " Votes"
        cell.movieTitle.adjustsFontSizeToFitWidth = true
        
        if totalVotes == 0 {
            cell.moviePercent.text = "0%"
        } else {
            let percent = round((Double(movieArray[indexPath.row].votes) / Double(totalVotes)) * 100)
            cell.moviePercent.text = String(forTrailingZero(temp: percent)) + "%"
        }
        
        return cell
    }
    
    func forTrailingZero(temp: Double) -> String {
        let tempVar = String(format: "%g", temp)
        return tempVar
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
