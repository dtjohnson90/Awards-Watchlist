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
import MessageUI

//class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, GIDSignInDelegate, GIDSignInUIDelegate, MFMailComposeViewControllerDelegate {
class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, GIDSignInDelegate, MFMailComposeViewControllerDelegate {
    
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
        self.logError(logString: "Settings VC - Rate App Clicked")
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            rateApp(appId: "id1197448840")
        }
    }
    @IBAction func purchaseClicked(_ sender: Any) {
        self.logError(logString: "Settings VC - Purchase Pro Clicked")
        performSegue(withIdentifier: "purchaseSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        profilePic.image = Items.sharedInstance.profilePic
        versionLabel.text = "Version " + ((Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!)
        versionLabel.isUserInteractionEnabled = true
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap))
        versionLabel.addGestureRecognizer(longGesture)
        
        if Items.sharedInstance.purchased {
            self.proLabel.isHidden = false
            self.proButton.isHidden = true
        } else {
            self.proLabel.isHidden = true
            self.proButton.isHidden = false
        }
        
        GIDSignIn.sharedInstance()?.delegate = self
        
        if AccessToken.current != nil {
            accountArray[0] = "Log Out Of Facebook"
        } else {
            accountArray[0] = "Log Into Facebook"
        }
        
        if GIDSignIn.sharedInstance()?.currentUser == nil {
            accountArray[1] = "Log into Google"
        } else {
           accountArray[1] = "Log Out Of Google"
        }

        accountArray[2] = "Sign Out"
        
        let docRef = Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn)
        docRef.getDocument { (document, error) in
            if let error = error {
                self.logError(logString: "Settings VC - Error accessing User document", logError: error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    self.nameLabel.text = document.data()!["Name"] as? String
                    if document.documentID.contains("privaterelay.appleid.com") {
                        self.emailLabel.text = "Using Private Apple Email"
                    } else {
                        self.emailLabel.text = document.documentID
                    }
                } else {
                    self.logError(logString: "Settings VC - User Document Doesn't Exist")
                    let alertController = UIAlertController(title: "Error", message: "There was a problem accessing your information. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                    
                    
                    let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        Items.sharedInstance.loggedIn = ""
                        UserDefaults.standard.removeObject(forKey: "loggedIn")
                    }
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }
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
        self.logError(logString: "In Settings VC")
        if AccessToken.current != nil {
            self.logError(logString: "Settings VC - Facebook Login: True")
            accountArray[0] = "Log Out Of Facebook"
        } else {
            self.logError(logString: "Settings VC - Facebook Login: False")
            accountArray[0] = "Log Into Facebook"
        }
        
        if GIDSignIn.sharedInstance()?.currentUser == nil {
            self.logError(logString: "Settings VC - Google Login: False")
            accountArray[1] = "Log into Google"
        } else {
           self.logError(logString: "Settings VC - Google Login: True")
           accountArray[1] = "Log Out Of Google"
        }
        
        if Items.sharedInstance.purchased {
            self.proLabel.isHidden = false
            self.proButton.isHidden = true
        } else {
            self.proLabel.isHidden = true
            self.proButton.isHidden = false
        }
        
        let docRef2 = Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn)
        docRef2.getDocument { (document2, error) in
            if let error = error {
                self.logError(logString: "Settings VC - Error Accessing User Document", logError: error.localizedDescription)
            } else {
                if let document2 = document2, document2.exists {
                    self.nameLabel.text = document2.data()!["Name"] as? String
                } else {
                    self.logError(logString: "Settings VC - User Document Doesn't Exist")
                    let alertController = UIAlertController(title: "Error", message: "There was a problem accessing your information. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                    
                    
                    let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        Items.sharedInstance.loggedIn = ""
                        UserDefaults.standard.removeObject(forKey: "loggedIn")
                    }
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }
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
            if #available(iOS 13.0, *) {
                cell.textLabel?.textColor = UIColor.label
            } else {
                // Fallback on earlier versions
                cell.textLabel?.textColor = UIColor.white
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
            cell.textLabel?.text = dataArray[indexPath.row]
            if #available(iOS 13.0, *) {
                cell.textLabel?.textColor = UIColor.label
            } else {
                // Fallback on earlier versions
                cell.textLabel?.textColor = UIColor.white
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == accountTable {
            if indexPath.row == 0 {
                if AccessToken.current != nil {
                    self.logError(logString: "Settings VC - Logging Out Of Facebook")
                    LoginManager().logOut()
                    accountArray[0] = "Log Into Facebook"
                    accountTable.reloadData()
                } else {
                    let loginManager = LoginManager()
                    loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) {loginResult in
                        switch loginResult {
                        case .failed(let error):
                            self.logError(logString: "Settings VC - Facebook Login Failed", logError: error.localizedDescription)
                            let alertController = UIAlertController(title: "Error", message: "Unable to login to Facebook. Please try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                Items.sharedInstance.loggedIn = ""
                                UserDefaults.standard.removeObject(forKey: "loggedIn")
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        case .cancelled:
                            self.logError(logString: "Settings VC - Facebook Login Cancelled")
                        case .success:
                            self.logError(logString: "Settings VC - Facebook Login Succesfull")
                            self.accountArray[0] = "Log Out Of Facebook"
                            self.accountTable.reloadData()
                        }
                    }
                }
            } else if indexPath.row == 1 {
                if GIDSignIn.sharedInstance()?.currentUser == nil {
                    GIDSignIn.sharedInstance().signIn()
                } else {
                   self.logError(logString: "Settings VC - Logging Out Of Google")
                   GIDSignIn.sharedInstance()?.signOut()
                   accountArray[1] = "Log Into Google"
                   accountTable.reloadData()
                }
                /*
                if GIDSignIn.sharedInstance().hasAuthInKeychain() {
                    self.logError(logString: "Settings VC - Logging Out Of Google")
                    GIDSignIn.sharedInstance()?.signOut()
                    accountArray[1] = "Log Into Google"
                    accountTable.reloadData()
                } else {
                    GIDSignIn.sharedInstance().signIn()
                }*/
            } else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Signing Out", message: "Are you sure you want to sign out? This will remove all saved movies and predictions from this device", preferredStyle: UIAlertController.Style.alert)
                    
                    let local = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                    }
                    let account = UIAlertAction(title: "Sign Out", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        self.logError(logString: "Settings VC - Logging Out Of Application")
                        do {
                            try Auth.auth().signOut()
                        } catch let signOutError as NSError {
                            self.logError(logString: "Settings VC - Problem Logging Out of Auth", logError: signOutError.localizedDescription)
                            let alertController = UIAlertController(title: "Error", message: "There was a problem signing out. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                        UserDefaults.standard.synchronize()
                        Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                        Items.sharedInstance.loggedIn = String()
                        Items.sharedInstance.moviesSeenArray.removeAll()
                        Items.sharedInstance.movieArray.removeAll()
                        Items.sharedInstance.actorArray.removeAll()
                        LoginManager().logOut()
                        GIDSignIn.sharedInstance().signOut()
                        UserDefaults.standard.set(true, forKey: Items.sharedInstance.updateKey)
                        self.performSegue(withIdentifier: "signOutSegue", sender: self)
                    }
                    
                    alertController.addAction(local)
                    alertController.addAction(account)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.clearData(clear: indexPath.row)
            }
        }
    }
    
    @objc func longTap() {
        let alertController = UIAlertController(title: "Error Reporting", message: "Would you like to email the developer with an error?", preferredStyle: UIAlertController.Style.actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
        }
        let email = UIAlertAction(title: "Email Logs", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            self.logError(logString: "Settings VC - Sending Logs via Email")
            self.sendMail()
        }
        
        alertController.addAction(email)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["dtjohnsonapps@gmail.com"])
            mail.setSubject("\(Items.sharedInstance.loggedIn) Log Files: \(Date())")
            mail.setMessageBody("<p>Please describe the issue in as much detail as possible. Pictures are highly recommended if available.</p>", isHTML: true)
            
            let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
            let url = dir.appendingPathComponent("logFile.txt")
            if let fileData = NSData(contentsOf: url)
            {
                print("File data loaded.")
                mail.addAttachmentData(fileData as Data, mimeType: "text/txt", fileName: "logFile.txt")
            }
            
            present(mail, animated: true)
        } else {
            // show failure alert
            self.logError(logString: "Settings VC - Unable to send email with Logs")
            let alertController = UIAlertController(title: "Error", message: "The email is unable to automatically send. Please send an email to 'dtjohnsonapps@gmail.com' to file an issue report.", preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    fileprivate func rateApp(appId: String) {
        openUrl("itms-apps://itunes.apple.com/app/" + appId)
    }
    
    fileprivate func openUrl(_ urlString:String) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        if let error = error {
            self.logError(logString: "Settings VC - Google Login Failed", logError: error.localizedDescription)
            UIApplication.shared.endIgnoringInteractionEvents()
            let alertController = UIAlertController(title: "Error", message: "There was a problem signing into Google. Please try again.", preferredStyle: UIAlertController.Style.alert)
            
            
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                
            }
            
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            self.logError(logString: "Settings VC - Unable to Authenticate via Google", logError: error.localizedDescription)
            UIApplication.shared.endIgnoringInteractionEvents()
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            
            let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                GIDSignIn.sharedInstance().signOut()
                return
            }
            
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
          } else {
                self.logError(logString: "Settings VC - Logged in via Google succesfully")
                UIApplication.shared.endIgnoringInteractionEvents()
                self.accountArray[1] = "Log Out Of Google"
                self.accountTable.reloadData()
            }
        }
    }
    
    func clearData(clear: Int) {
        switch clear {
        case 0:
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove all your saved movies? This is irreversible", preferredStyle: UIAlertController.Style.alert)
            
            let local = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                
            }
            let account = UIAlertAction(title: "Remove", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                self.logError(logString: "Settings VC - Removing Saved Movies")
                
                UIApplication.shared.beginIgnoringInteractionEvents()
                UserDefaults.standard.removeObject(forKey: "LocalStorage")
                UserDefaults.standard.synchronize()
                Items.sharedInstance.moviesSeenArray.removeAll()
                
                let userRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                userRef.getDocument { (document, error) in
                    if let error = error {
                        self.logError(logString: "Settings VC - Unable to get User Document", logError: error.localizedDescription)
                    } else {
                        if let document = document, document.exists {
                            userRef.updateData([
                                "movies": [String]()
                            ]) { err in
                                UIApplication.shared.endIgnoringInteractionEvents()
                                if let err = err {
                                    self.logError(logString: "Settings VC - Unable to update saved movies to document", logError: err.localizedDescription)
                                    let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                                    
                                    let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                        (result : UIAlertAction) -> Void in
                                        GIDSignIn.sharedInstance().signOut()
                                        return
                                    }
                                    
                                    alertController.addAction(account)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        } else {
                            self.logError(logString: "Settings VC - User Document doesn't exist")
                            UIApplication.shared.endIgnoringInteractionEvents()
                            let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                GIDSignIn.sharedInstance().signOut()
                                return
                            }
                            
                            alertController.addAction(account)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
        case 1:
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove all your predictions? This is irreversible", preferredStyle: UIAlertController.Style.alert)
            
            let local = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            let account = UIAlertAction(title: "Remove", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                self.logError(logString: "Settings VC - Removing Saved Predictions")
                
                UIApplication.shared.beginIgnoringInteractionEvents()
                UserDefaults.standard.removeObject(forKey: "Predictions")
                UserDefaults.standard.synchronize()
                Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                Items.sharedInstance.dataCleared = true
                
                let userRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                userRef.getDocument { (document, error) in
                    if let error = error {
                        self.logError(logString: "Settings VC - Unable to access User document", logError: error.localizedDescription)
                    } else {
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
                                    self.logError(logString: "Settings VC - Unable to update User Predictions", logError: err.localizedDescription)
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                                    
                                    let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                        (result : UIAlertAction) -> Void in
                                        GIDSignIn.sharedInstance().signOut()
                                        return
                                    }
                                    
                                    alertController.addAction(account)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                        } else {
                            self.logError(logString: "Settings VC - User Document Doesn't Exist")
                            UIApplication.shared.endIgnoringInteractionEvents()
                            let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                GIDSignIn.sharedInstance().signOut()
                                return
                            }
                            
                            alertController.addAction(account)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
        default:
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove all saved data? This is irreversible", preferredStyle: UIAlertController.Style.alert)
            
            let local = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            let account = UIAlertAction(title: "Remove", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                self.logError(logString: "Settings VC - Removing All Data")
                
                UIApplication.shared.beginIgnoringInteractionEvents()
                UserDefaults.standard.removeObject(forKey: "LocalStorage")
                UserDefaults.standard.removeObject(forKey: "Predictions")
                UserDefaults.standard.synchronize()
                Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                Items.sharedInstance.moviesSeenArray.removeAll()
                Items.sharedInstance.dataCleared = true
                
                let userRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                userRef.getDocument { (document, error) in
                    if let error = error {
                        self.logError(logString: "Settings VC - Error Accessing User Document", logError: error.localizedDescription)
                    } else {
                        if let document = document, document.exists {
                            let friends = document.data()!["Friends"] as! [String]
                            
                            //Cycle through every friend and remove your name from their list
                            for item in friends {
                                let friendRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(item)
                                friendRef.getDocument { (document, error) in
                                    if let error = error {
                                        self.logError(logString: "Settings VC - Unable to get friend document. (Friend: \(item))", logError: error.localizedDescription)
                                    } else {
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
                                                    self.logError(logString: "Settings VC - Error Updating Friends Document. (Friend: \(item))", logError: err.localizedDescription)
                                                    UIApplication.shared.endIgnoringInteractionEvents()
                                                    let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                                                    
                                                    let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                                        (result : UIAlertAction) -> Void in
                                                        GIDSignIn.sharedInstance().signOut()
                                                        return
                                                    }
                                                    
                                                    alertController.addAction(account)
                                                    self.present(alertController, animated: true, completion: nil)
                                                }
                                                UIApplication.shared.endIgnoringInteractionEvents()
                                            }
                                        } else {
                                            self.logError(logString: "Settings VC - Friend Document Doesn't Exist (Friend: \(item))")
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
                                    self.logError(logString: "Settings VC - Error Updating User Document", logError: err.localizedDescription)
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                                    
                                    let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                        (result : UIAlertAction) -> Void in
                                        GIDSignIn.sharedInstance().signOut()
                                        return
                                    }
                                    
                                    alertController.addAction(account)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                            
                        } else {
                            self.logError(logString: "Settings VC - User Document Doesn't Exist")
                            UIApplication.shared.endIgnoringInteractionEvents()
                            let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                GIDSignIn.sharedInstance().signOut()
                                return
                            }
                            
                            alertController.addAction(account)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
        }
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
