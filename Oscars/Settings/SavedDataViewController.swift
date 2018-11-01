//
//  SavedDataViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/26/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SavedDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableRows = ["Clear Movies Seen", "Clear Predictions","Clear All Data"]
    var images = [UIImage(named: "Unseen"), UIImage(named: "Predictions"), UIImage(named: "Delete")]
    
    @IBOutlet weak var dataTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)

            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            clearData(clear: 0)
        case 1:
            clearData(clear: 1)
        default:
            clearData(clear: 2)
        }
    }
    
    func clearData(clear: Int) {
        switch clear {
        case 0:
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove all your saved movies? This is irreversible", preferredStyle: UIAlertControllerStyle.alert)
            
            let local = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            let account = UIAlertAction(title: "Remove", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
    
                UserDefaults.standard.removeObject(forKey: "LocalStorage")
                UserDefaults.standard.synchronize()
                Items.sharedInstance.moviesSeenArray.removeAll()
                
                let userRef = Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn)
                userRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        
                        //Edit your document to be empty
                        userRef.updateData([
                            "movies": [String]()
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                        
                    } else {
                        print("Document does not exist")
                    }
                }
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
        case 1:
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove all your predictions? This is irreversible", preferredStyle: UIAlertControllerStyle.alert)
            
            let local = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            let account = UIAlertAction(title: "Remove", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
                UserDefaults.standard.removeObject(forKey: "Predictions")
                UserDefaults.standard.synchronize()
                Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                Items.sharedInstance.dataCleared = true
                
                let userRef = Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn)
                userRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        //Edit your document to be empty
                        userRef.updateData([
                            "Best Picture": "",
                            "Best Actor": "",
                            "Best Actress": "",
                            "Supporting Actor": "",
                            "Supporting Actress": "",
                            "Animated": "",
                            "Cinematography": "",
                            "Costume Design": "",
                            "Directing": "",
                            "Documentary Feature": "",
                            "Documentary Short": "",
                            "Film Editing": "",
                            "Foreign": "",
                            "Makeup": "",
                            "Music Song": "",
                            "Music Score": "",
                            "Production Design": "",
                            "Short Animated": "",
                            "Short Live": "",
                            "Sound Editing": "",
                            "Sound Mixing": "",
                            "Visual Effects": "",
                            "Writing Adapted": "",
                            "Writing Original": ""
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                        
                    } else {
                        print("Document does not exist")
                    }
                }
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
        default:
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove all saved data? This is irreversible", preferredStyle: UIAlertControllerStyle.alert)
            
            let local = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            let account = UIAlertAction(title: "Remove", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in

                UserDefaults.standard.removeObject(forKey: "LocalStorage")
                UserDefaults.standard.removeObject(forKey: "Predictions")
                UserDefaults.standard.synchronize()
                Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                Items.sharedInstance.moviesSeenArray.removeAll()
                Items.sharedInstance.dataCleared = true
                
                let userRef = Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn)
                userRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let friends = document.data()!["Friends"] as! [String]
                        
                        //Cycle through every friend and remove your name from their list
                        for item in friends {
                            let friendRef = Firestore.firestore().collection("UserMovieList").document(item)
                            friendRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    var theirFreinds = document.data()!["Friends"] as! [String]
                                    for (index,friend) in theirFreinds.enumerated() {
                                        if friend == Items.sharedInstance.loggedIn {
                                            theirFreinds.remove(at: index)
                                        }
                                    }
                                    friendRef.updateData([
                                        "Friends": theirFreinds
                                    ]) { err in
                                        if let err = err {
                                            print("Error updating document: \(err)")
                                        } else {
                                            print("Document successfully updated")
                                        }
                                    }
                                }
                            }
                        }
                        
                        //Edit your document to be empty
                        userRef.updateData([
                            "movies": [String](),
                            "Best Picture": "",
                            "Best Actor": "",
                            "Best Actress": "",
                            "Supporting Actor": "",
                            "Supporting Actress": "",
                            "Animated": "",
                            "Cinematography": "",
                            "Costume Design": "",
                            "Directing": "",
                            "Documentary Feature": "",
                            "Documentary Short": "",
                            "Film Editing": "",
                            "Foreign": "",
                            "Makeup": "",
                            "Music Song": "",
                            "Music Score": "",
                            "Production Design": "",
                            "Short Animated": "",
                            "Short Live": "",
                            "Sound Editing": "",
                            "Sound Mixing": "",
                            "Visual Effects": "",
                            "Writing Adapted": "",
                            "Writing Original": "",
                            "Invitations": [String](),
                            "Friends": [String]()
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                        
                    } else {
                        print("Document does not exist")
                    }
                }
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
