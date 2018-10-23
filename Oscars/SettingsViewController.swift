//
//  SettingsViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/18/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FacebookLogin
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var settingsArray = ["Name","Email","Clear Data"]
    var name = ""
    var email = ""
    var rowSelected = Int()
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {}
    @IBOutlet weak var settingsTable: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBAction func logoutClicked(_ sender: Any) {
        if Items.sharedInstance.loggedIn == "Local" {
            performSegue(withIdentifier: "loginSegue3", sender: self)
        } else {
            let alertController = UIAlertController(title: "Signing Out", message: "Are you sure you want to sign out? This will remove all saved movies and predictions from this device", preferredStyle: UIAlertControllerStyle.alert)
            
            let local = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            let account = UIAlertAction(title: "Sign Out", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                UserDefaults.standard.synchronize()
                Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                Items.sharedInstance.loggedIn = String()
                Items.sharedInstance.moviesSeenArray.removeAll()
                LoginManager().logOut()
                GIDSignIn.sharedInstance().signOut()
                Items.sharedInstance.loggedIn = "Local"
                self.logoutButton.setTitle("Log In", for: .normal)
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        versionLabel.text = "Version " + ((Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!)
        
        if Items.sharedInstance.loggedIn == "Local" {
            logoutButton.setTitle("Log In", for: .normal)
        } else {
            logoutButton.setTitle("Log Out", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        settingsTable.dataSource = nil
        if Items.sharedInstance.loggedIn == "Local" {
            self.settingsArray[0] = "Name: 'Login To Setup Name'"
            self.settingsArray[1] = "Email: 'Login To Setup Email'"
            settingsTable.dataSource = self
            self.settingsTable.reloadData()
            logoutButton.setTitle("Log In", for: .normal)
        } else {
            Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.settingsArray[0] = "Name: " + String(document.data()!["Name"] as! String)
                    self.settingsArray[1] = "Email: " + document.documentID
                    self.name = document.data()!["Name"] as! String
                    self.email = document.documentID
                    self.settingsTable.dataSource = self
                    self.settingsTable.reloadData()
                    self.logoutButton.setTitle("Log Out", for: .normal)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.textLabel!.text = settingsArray[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        
        if indexPath.row == 1 {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if Items.sharedInstance.loggedIn == "Local" {
                let alertController = UIAlertController(title: "Error", message: "You must be logged in to change your name", preferredStyle: UIAlertControllerStyle.alert)
                
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                }
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            } else {
                rowSelected = 0
                performSegue(withIdentifier: "editProfileSegue", sender: self)
            }
        case 1:
            print("Possibly setting up later")
            /*
            if Items.sharedInstance.loggedIn == "Local" {
                let alertController = UIAlertController(title: "Error", message: "You must be logged in to change your name", preferredStyle: UIAlertControllerStyle.alert)
                
                let ok = UIAlertAction(title: "Create Account", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                }
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            } else {
                rowSelected = 1
                performSegue(withIdentifier: "editProfileSegue", sender: self)
            }*/
        case 2:
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove all saved data? This is irreversible", preferredStyle: UIAlertControllerStyle.alert)
            
            let local = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            let account = UIAlertAction(title: "Remove", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                UserDefaults.standard.removeObject(forKey: "LocalStorage")
                UserDefaults.standard.removeObject(forKey: "Predictions")
                UserDefaults.standard.synchronize()
                Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                Items.sharedInstance.moviesSeenArray.removeAll()
                if Items.sharedInstance.loggedIn != "Local" {
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
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
            
        default:
            return
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "editProfileSegue" {
            let secondScene = segue.destination as! ChangeSettingsViewController
            secondScene.rowSelected = rowSelected
            secondScene.name = name
            secondScene.email = email
            
        } else {
            let secondScene = segue.destination as! LoginViewController
            secondScene.comingFrom = "C"
        }
    }
}
