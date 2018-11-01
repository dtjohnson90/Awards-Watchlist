//
//  SettingsViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/18/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore
import StoreKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var accountArray = [String](repeating: "", count: 3)
    var dataArray = ["Clear Movies Seen", "Clear Predictions","Clear All Data"]
    
    var name = ""
    var email = ""
    var rowSelected = Int()
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {}
    @IBOutlet weak var settingsTable: UITableView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var settingsImage: UIImageView!
    @IBOutlet weak var accountTable: UITableView!
    @IBOutlet weak var dataTable: UITableView!
    @IBOutlet weak var proLabel: UILabel!
    @IBOutlet weak var proButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBAction func rateClicked(_ sender: Any) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            rateApp(appId: "id1197448840")
        }
    }
    @IBAction func purchaseClicked(_ sender: Any) {
        performSegue(withIdentifier: "purchaseSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loading")

        // Do any additional setup after loading the view
        profilePic.image = Items.sharedInstance.profilePic
        versionLabel.text = "Version " + ((Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!)
        
        if Items.sharedInstance.purchased {
            self.proLabel.isHidden = false
            self.proButton.isHidden = true
        } else {
            self.proLabel.isHidden = true
            self.proButton.isHidden = false
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        if AccessToken.current != nil {
            accountArray[0] = "Log Out Of Facebook"
        } else {
            accountArray[0] = "Log Into Facebook"
        }
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            accountArray[1] = "Log Out Of Google"
        } else {
            accountArray[1] = "Log into Google"
        }
        accountArray[2] = "Sign Out"
        
        let docRef = Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.nameLabel.text = document.data()!["Name"] as? String
                self.emailLabel.text = document.documentID
            } else {
                print("Document does not exist")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePurchased), name:NSNotification.Name(rawValue: "purchased"), object: nil)
    }
    
    @objc func updatePurchased(notification: NSNotification){
        if Items.sharedInstance.purchased {
            self.proLabel.isHidden = false
            self.proButton.isHidden = true
        } else {
            self.proLabel.isHidden = true
            self.proButton.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View Appeared")
        if AccessToken.current != nil {
            accountArray[0] = "Log Out Of Facebook"
        } else {
            accountArray[0] = "Log Into Facebook"
        }
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            accountArray[1] = "Log Out Of Google"
        } else {
            accountArray[1] = "Log into Google"
        }
        
        if Items.sharedInstance.purchased {
            self.proLabel.isHidden = false
            self.proButton.isHidden = true
        } else {
            self.proLabel.isHidden = true
            self.proButton.isHidden = false
        }
        
        let docRef2 = Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn)
        docRef2.getDocument { (document2, error) in
            if let document2 = document2, document2.exists {
                self.nameLabel.text = document2.data()!["Name"] as? String
            } else {
                print("Document does not exist")
            }
        }
        profilePic.image = Items.sharedInstance.profilePic
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == accountTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
            cell.textLabel?.text = accountArray[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
            cell.textLabel?.text = dataArray[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == accountTable {
            if indexPath.row == 0 {
                if AccessToken.current != nil {
                    LoginManager().logOut()
                    accountArray[0] = "Log Into Facebook"
                    accountTable.reloadData()
                } else {
                    let loginManager = LoginManager()
                    loginManager.logIn(readPermissions: [ReadPermission.publicProfile, ReadPermission.email], viewController: self) {loginResult in
                        switch loginResult {
                        case .failed(let error):
                            print(error)
                        case .cancelled:
                            print("User cancelled login")
                        case .success:
                            print("Logged in")
                            self.accountArray[0] = "Log Out Of Facebook"
                            self.accountTable.reloadData()
                        }
                    }
                }
            } else if indexPath.row == 1 {
                if GIDSignIn.sharedInstance().hasAuthInKeychain() {
                    GIDSignIn.sharedInstance()?.signOut()
                    accountArray[1] = "Log Into Google"
                    accountTable.reloadData()
                } else {
                    GIDSignIn.sharedInstance().signIn()
                }
            } else {
                DispatchQueue.main.async {
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
                        self.performSegue(withIdentifier: "signOutSegue", sender: self)
                    }
                    
                    alertController.addAction(local)
                    alertController.addAction(account)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            clearData(clear: indexPath.row)
        }
    }
    
    fileprivate func rateApp(appId: String) {
        openUrl("itms-apps://itunes.apple.com/app/" + appId)
    }
    
    fileprivate func openUrl(_ urlString:String) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            print(error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().currentUser?.linkAndRetrieveData(with: credential)  { (authResult, error) in
            // ...
        }
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // ...
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                
                let account = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    GIDSignIn.sharedInstance().signOut()
                    return
                }
                
                alertController.addAction(account)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let docRef = Firestore.firestore().collection("UserMovieList").document((Auth.auth().currentUser?.email)!)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        Items.sharedInstance.moviesSeenArray.removeAll()
                        Items.sharedInstance.predictions.removeAll()
                        
                        let nomList = ["Best Picture","Best Actor","Best Actress","Supporting Actor","Supporting Actress","Animated","Cinematography","Costume Design","Directing","Documentary Feature","Documentary Short","Film Editing","Foreign","Makeup","Music Score","Music Song","Production Design","Short Animated","Short Live","Sound Editing","Sound Mixing","Visual Effects","Writing Adapted","Writing Original"]
                        for item in nomList {
                            Items.sharedInstance.predictions.append(document.data()![item] as! String)
                        }
                        
                        let movies = document.data()!["movies"] as! [String]
                        for item in movies {
                            for movie in Items.sharedInstance.movieArray {
                                if item == movie.name {
                                    Items.sharedInstance.moviesSeenArray.append(movie)
                                }
                            }
                        }
                        self.accountArray[1] = "Log Out Of Google"
                        self.accountTable.reloadData()
                    } else {
                        var tempMovieArray = [String]()
                        for seenMovie in Items.sharedInstance.moviesSeenArray {
                            tempMovieArray.append(seenMovie.name)
                        }
                        Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                        Firestore.firestore().collection("UserMovieList").document((Auth.auth().currentUser?.email)!).setData([
                            "movies": tempMovieArray,
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
                            "Friends": [String](),
                            "Name": Auth.auth().currentUser!.displayName!
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                                self.accountArray[1] = "Log Out Of Google"
                                self.accountTable.reloadData()
                            }
                        }
                    }
                }
            }
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
