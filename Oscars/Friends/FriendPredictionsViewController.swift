//
//  FriendPredictionsViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/17/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore

class FriendPredictionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var predictionsTableView: UITableView!
    
    var friendChosen = String()
    var bestActorArray = [Items.actors]()
    var bestActressArray = [Items.actors]()
    var supportingActorArray = [Items.actors]()
    var supportingActressArray = [Items.actors]()
    var directorArray = [Items.actors]()
    let predictionsArray = ["Best Picture","Best Actor","Best Actress","Supporting Actor","Supporting Actress","Animated","Cinematography","Costume Design","Directing","Documentary Feature","Documentary Short","Film Editing","Foreign","Makeup","Music Score","Music Song","Production Design","Short Animated","Short Live","Sound Editing","Sound Mixing","Visual Effects","Writing Adapted","Writing Original"]
    var predictions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logError(logString: "Loading Friend Predictions for \(friendChosen)")

        // Do any additional setup after loading the view.
        predictionsTableView.dataSource = nil
        
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
        
        Firestore.firestore().collection("UserMovieList").document(friendChosen).getDocument { (document, error) in
            if let error = error {
                self.logError(logString: "Friends Predictions VC - Error Accessing Friend Document", logError: error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    let downloading = DispatchGroup()
                    for category in self.predictionsArray {
                        downloading.enter()
                        self.predictions.append(document.data()![category] as! String)
                        downloading.leave()
                    }
                    downloading.notify(queue: .main) {
                        self.predictionsTableView.dataSource = self
                        self.predictionsTableView.reloadData()
                    }
                } else {
                    self.logError(logString: "Friends Predictions VC - Friend Chosen document doesn't exist")
                    let alertController = UIAlertController(title: "Error", message: "Could not access your friends data. Please quit the app and try again.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                    }
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendPredictionCell", for: indexPath) as! FriendPredictionsTableViewCell
        
        cell.category.text = predictionsArray[indexPath.row]
        if predictions[indexPath.row] == "" {
            cell.hiddenView.isHidden = false
        } else {
            cell.hiddenView.isHidden = true
            switch indexPath.row {
            case 1:
                for item in bestActorArray {
                    if item.name == predictions[indexPath.row] {
                        cell.cover.image = item.image
                        cell.title.text = item.name
                        cell.starring.text = item.movie
                        break
                    }
                }
            case 2:
                for item in bestActressArray {
                    if item.name == predictions[indexPath.row] {
                        cell.cover.image = item.image
                        cell.title.text = item.name
                        cell.starring.text = item.movie
                        break
                    }
                }
            case 3:
                for item in supportingActorArray {
                    if item.name == predictions[indexPath.row] {
                        cell.cover.image = item.image
                        cell.title.text = item.name
                        cell.starring.text = item.movie
                        break
                    }
                }
            case 4:
                for item in supportingActressArray {
                    if item.name == predictions[indexPath.row] {
                        cell.cover.image = item.image
                        cell.title.text = item.name
                        cell.starring.text = item.movie
                        break
                    }
                }
            case 8:
                for item in directorArray {
                    if item.name == predictions[indexPath.row] {
                        cell.cover.image = item.image
                        cell.title.text = item.name
                        cell.starring.text = item.movie
                        break
                    }
                }
            default:
                for item in Items.sharedInstance.movieArray {
                    if item.name == predictions[indexPath.row] {
                        cell.cover.image = item.cover
                        cell.title.text = item.name
                        cell.starring.text = "Starring: " + item.actors[0]
                    }
                }
            }
        }
        cell.title.adjustsFontSizeToFitWidth = true
        cell.starring.adjustsFontSizeToFitWidth = true
        return cell
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
