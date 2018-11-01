//
//  AccountViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/26/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FacebookLogin
import GoogleSignIn

class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableRows = [String](repeating: "", count: 3)
    let images = [UIImage(named: "Name"), UIImage(named: "Mail"), UIImage(named: "Logout")]
    var name = String()
    var email = String()
    
    @IBOutlet weak var accountTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        accountTable.dataSource = nil
        let docRef = Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.name = document.data()!["Name"] as! String
                self.email = document.documentID
                self.tableRows[0] = "Name: " + self.name
                self.tableRows[1] = "Email: " + self.email
                self.tableRows[2] = "Log Out"
                self.accountTable.dataSource = self
                self.accountTable.reloadData()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("Change Name")
        case 1:
            print("Maybe implementing later")
        default:
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
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
