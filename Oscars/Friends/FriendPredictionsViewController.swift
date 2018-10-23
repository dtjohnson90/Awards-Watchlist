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

        // Do any additional setup after loading the view.
        predictionsTableView.dataSource = nil
        
        for item in Items.sharedInstance.actorArray {
            switch item.nominatedFor {
            case "Best Actor":
                bestActorArray.append(item)
                print("1")
            case "Supporting Actor":
                supportingActorArray.append(item)
                print("2")
            case "Best Actress":
                bestActressArray.append(item)
                print("3")
            case "Supporting Actress":
                supportingActressArray.append(item)
                print("4")
            case "Directing":
                directorArray.append(item)
                print("5")
            default:
                return
            }
        }
        
        Firestore.firestore().collection("UserMovieList").document(friendChosen).getDocument { (document, error) in
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
                    print("Done")
                }
            } else {
                print("Document does not exist")
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
