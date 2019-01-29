//
//  LoginViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/10/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import MessageUI

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    
    @IBAction func forgotPassword(_ sender: Any) {
        self.logError(logString: "Login VC - Forgot Password Clicked")
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Forgot Password", message: "Enter the email address for your account", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            //textField.text = "Some default text"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.textFields![0].placeholder = "Email"
        }))
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            let email = textField.text!
            Firestore.firestore().collection("UserMovieList").document(email).getDocument { (document, error) in
                if let error = error {
                    self.logError(logString: "Login VC - Getting User Document Password Reset", logError: error.localizedDescription)
                } else {
                    if let document = document, document.exists {
                        Auth.auth().sendPasswordReset(withEmail: textField.text!) { (error) in
                            if let error = error {
                                self.logError(logString: "Login VC - Problem Sending Password Reset Email (To: \(email))", logError: error.localizedDescription)
                                let alertController = UIAlertController(title: "Error", message: "There was a problem sending the password reset email. Please try again", preferredStyle: UIAlertControllerStyle.alert)
                                
                                
                                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                    (result : UIAlertAction) -> Void in
                                }
                                
                                alertController.addAction(ok)
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                let alertController = UIAlertController(title: "Reset Password", message: "An email has been sent to \(email). Please click on the link in the email to reset your password", preferredStyle: UIAlertControllerStyle.alert)
                                
                                
                                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                    (result : UIAlertAction) -> Void in
                                    self.logError(logString: "Login VC - Password Reset Email Sent (To: \(email))")
                                }
                                
                                alertController.addAction(ok)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    } else {
                        let alertController = UIAlertController(title: "Error", message: "There is no account with that email address. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        
                        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                            self.logError(logString: "Login VC - Attempted Login With Wrong Email (To: \(email))")
                        }
                        
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginPushed(_ sender: Any) {
        self.logError(logString: "Login VC - Attempting Login")
        UIApplication.shared.beginIgnoringInteractionEvents()
        if (usernameField.text?.isEmpty)! || (passwordField.text?.isEmpty)! {
            UIApplication.shared.endIgnoringInteractionEvents()
            let alertController = UIAlertController(title: "Error", message: "Please make sure all fields are filled out", preferredStyle: UIAlertControllerStyle.alert)
            
            
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().signIn(withEmail: usernameField.text!, password: passwordField.text!) { (user, error) in
                if let error = error {
                    self.logError(logString: "Login VC - Error Logging In (To: \(self.usernameField.text!))", logError: error.localizedDescription)
                    UIApplication.shared.endIgnoringInteractionEvents()
                    let alertController = UIAlertController(title: "Error", message: "The username/password combination is not correct. Please check your connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                    }
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    if !(Auth.auth().currentUser?.isEmailVerified)! {
                        self.logError(logString: "Login VC - Email Not Verified")
                        UIApplication.shared.endIgnoringInteractionEvents()

                        let alertController = UIAlertController(title: "Error", message: "You must verify your email address before logging in. To resend the email, tap below.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                            do {
                                try Auth.auth().signOut()
                            } catch let signOutError as NSError {
                                self.logError(logString: "Login VC - Error Signing Out (Email Verification)", logError: signOutError.localizedDescription)
                            }
                            return
                        }
                        
                        let resend = UIAlertAction(title: "Resend Email", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                            UIApplication.shared.endIgnoringInteractionEvents()
                            Auth.auth().currentUser?.sendEmailVerification { (error) in
                                // ...
                                if let error = error {
                                    self.logError(logString: "Login VC - Error Re-Sending Verification Email (To: \(Auth.auth().currentUser?.email ?? "nil"))", logError: error.localizedDescription)
                                } else {
                                    let alertController = UIAlertController(title: "", message: "An email has been sent for verification. Please verify this email before you can login.", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    
                                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                        (result : UIAlertAction) -> Void in
                                        self.logError(logString: "Login VC - Verification Email Re-Sent (To: \(Auth.auth().currentUser?.email ?? "nil"))")
                                        do {
                                            try Auth.auth().signOut()
                                        } catch let signOutError as NSError {
                                            self.logError(logString: "Login VC - Error Signing Out (Resend Verification)", logError: signOutError.localizedDescription)
                                        }
                                    }
                                    
                                    alertController.addAction(ok)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                            return
                        }
                        
                        alertController.addAction(cancel)
                        alertController.addAction(resend)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let docRef = Firestore.firestore().collection("UserMovieList").document((self.usernameField.text)!)
                        docRef.getDocument { (document, error) in
                            if let error = error {
                                self.logError(logString: "Login VC - Creating Document Via Email", logError: error.localizedDescription)
                            } else {
                                if let document = document, document.exists {
                                    self.logError(logString: "Login VC - Logging in with already created document via Email")
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    UserDefaults.standard.set(self.usernameField.text!, forKey: "loggedIn")
                                    self.performSegue(withIdentifier: "loggedIn1", sender: self)
                                } else {
                                    self.logError(logString: "Login VC - Loggin in by creating new document via Email")
                                    var tempMovieArray = [String]()
                                    for seenMovie in Items.sharedInstance.moviesSeenArray {
                                        tempMovieArray.append(seenMovie.name)
                                    }
                                    Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                                    Firestore.firestore().collection("UserMovieList").document((self.usernameField.text)!).setData([
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
                                        "Name": Auth.auth().currentUser!.displayName!,
                                        "Image URL": Auth.auth().currentUser!.photoURL?.absoluteString ?? "nil"
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Login VC - Error Creating Document via Email", logError: err.localizedDescription)
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            let alertController = UIAlertController(title: "Error", message: "There was a problem creating your account. Please quit the app and try again", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            
                                            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                                (result : UIAlertAction) -> Void in
                                                self.loginButton.isEnabled = true
                                            }
                                            
                                            alertController.addAction(ok)
                                            self.present(alertController, animated: true, completion: nil)
                                        } else {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            UserDefaults.standard.set(self.usernameField.text!, forKey: "loggedIn")
                                            self.performSegue(withIdentifier: "loggedIn1", sender: self)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func facebookLogin(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ReadPermission.publicProfile, ReadPermission.email, ReadPermission.userFriends], viewController: self) {loginResult in
            switch loginResult {
            case .failed(let error):
                self.logError(logString: "Login VC - Facebook Login Failed", logError: error.localizedDescription)
                UIApplication.shared.endIgnoringInteractionEvents()
                let alertController = UIAlertController(title: "Error", message: "We were unable to login via Facebook. Please try again", preferredStyle: UIAlertControllerStyle.alert)
                
                
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                }
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            case .cancelled:
                self.logError(logString: "Login VC - Facebook Login Cancelled")
                UIApplication.shared.endIgnoringInteractionEvents()
            case .success:
                self.logError(logString: "Login VC - Logged in via Facebook")
            }
        }
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        self.logError(logString: "Logged in via Google")
        UIApplication.shared.beginIgnoringInteractionEvents()
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loginLabel.isUserInteractionEnabled = true
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap))
        loginLabel.addGestureRecognizer(longGesture)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        emailLabel.adjustsFontSizeToFitWidth = true
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    @objc func longTap() {
        let alertController = UIAlertController(title: "Error Reporting", message: "Would you like to email the developer with an error?", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
        }
        let email = UIAlertAction(title: "Email Logs", style: UIAlertActionStyle.default) {
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
            let alertController = UIAlertController(title: "Error", message: "The email is unable to automatically send. Please send an email to 'dtjohnsonapps@gmail.com' to file an issue report.", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            UIApplication.shared.endIgnoringInteractionEvents()
            self.logError(logString: "Login VC - Problem Logging In Via Google", logError: error.localizedDescription)
            let alertController = UIAlertController(title: "Error", message: "We were unable to login via Google. Please try again", preferredStyle: UIAlertControllerStyle.alert)
            
            
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
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
                self.logError(logString: "Login VC - Error Creating Account via Google", logError: error.localizedDescription)
                UIApplication.shared.endIgnoringInteractionEvents()

                let alertController = UIAlertController(title: "Error", message: "There was a problem creating the account. Please quit the app and try again.", preferredStyle: UIAlertControllerStyle.alert)
                
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
                    if let error = error {
                        self.logError(logString: "Login VC - Error accessing current user document", logError: error.localizedDescription)
                    } else {
                        if let document = document, document.exists {
                            self.logError(logString: "Login VC - Logging in with already created document via Google")
                            UIApplication.shared.endIgnoringInteractionEvents()
                            UserDefaults.standard.set(true, forKey: "offeredSignIn")
                            UserDefaults.standard.set(Auth.auth().currentUser?.email, forKey: "loggedIn")
                            Items.sharedInstance.loggedIn = (Auth.auth().currentUser?.email)!
                            self.performSegue(withIdentifier: "loggedIn1", sender: self)
                        } else {
                            self.logError(logString: "Login VC - Logging in by creating new document via Google")
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
                                "Name": Auth.auth().currentUser!.displayName!,
                                "Image URL": Auth.auth().currentUser!.photoURL?.absoluteString ?? "nil",
                                "Facebook ID": ""
                            ]) { err in
                                if let err = err {
                                    self.logError(logString: "Login VC - Problem Creating Account Via Google", logError: err.localizedDescription)
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    let alertController = UIAlertController(title: "Error", message: "We were unable to create your account via Google. Please try again", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    
                                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                        (result : UIAlertAction) -> Void in
                                    }
                                    
                                    alertController.addAction(ok)
                                    self.present(alertController, animated: true, completion: nil)
                                } else {
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    UserDefaults.standard.set(true, forKey: "offeredSignIn")
                                    UserDefaults.standard.set(Auth.auth().currentUser?.email, forKey: "loggedIn")
                                    Items.sharedInstance.loggedIn = (Auth.auth().currentUser?.email)!
                                    self.performSegue(withIdentifier: "loggedIn1", sender: self)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AccessToken.current != nil {
            UIApplication.shared.beginIgnoringInteractionEvents()
            let credential = FacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
            var email = String()
            
            var graph = GraphRequest.init(graphPath: "me")
            graph.parameters = ["fields": "email"]
            graph.start({(connection, result) in
                switch result {
                case .failed(let error):
                    // Unable to get Facebook Information
                    self.logError(logString: "Login VC - Error Accessing Facebook Graph", logError: error.localizedDescription)
                    UIApplication.shared.endIgnoringInteractionEvents()
                case .success(let graphResponse):
                    // Succesfully received Facebook Information
                    if let responseDictionary = graphResponse.dictionaryValue {
                        // Setup local variables with Facebook Information
                        if let email2 = responseDictionary["email"] {
                            email = email2 as! String
                        } else {
                            email = ""
                        }
                    }
                }
            })
            
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if error != nil {
                    // There was an errror signing in. Attempt to join account
                    Auth.auth().currentUser?.linkAndRetrieveData(with: credential)  { (authResult, error) in
                        if let error = error {
                            UIApplication.shared.endIgnoringInteractionEvents()

                            //Join Failed. Let user know why
                            self.logError(logString: "Login VC - Error Creating Account via Facebook", logError: error.localizedDescription)
                            let alertController = UIAlertController(title: "Error", message: "There was a problem creating your account. Please quit the app and try again.", preferredStyle: UIAlertControllerStyle.alert)
                            
                            let account = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                (result : UIAlertAction) -> Void in
                                LoginManager().logOut()
                                return
                            }
                            
                            alertController.addAction(account)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            // Join succesfull. Check if email is available
                            if Auth.auth().currentUser?.email == nil {
                                //email not available through firestore
                                if email == "" {
                                    //no email available period
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    self.logError(logString: "Login VC - Not email setup with Facebook")
                                    let alertController = UIAlertController(title: "Error", message: "You do not have an email setup with this facebook. Please sign in with a different account or add an email to your facebook settings.", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    let account = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                        (result : UIAlertAction) -> Void in
                                        LoginManager().logOut()
                                        return
                                    }
                                    
                                    alertController.addAction(account)
                                    self.present(alertController, animated: true, completion: nil)
                                } else {
                                    //Facebook email available. Update Firestore email
                                    Auth.auth().currentUser?.updateEmail(to: email) { (error) in
                                    }
                                    self.facebookSignIn(email: email)
                                }
                            } else {
                                //Firestore email available
                                self.facebookSignIn(email: (Auth.auth().currentUser?.email)!)
                            }
                        }
                    }
                } else {
                    if Auth.auth().currentUser?.email == nil {
                        if email == "" {
                            self.logError(logString: "Login VC - Not Email setup with Facebook")
                            UIApplication.shared.endIgnoringInteractionEvents()
                            let alertController = UIAlertController(title: "Error", message: "You do not have an email setup with this facebook. Please sign in with a different account or add an email to your facebook settings.", preferredStyle: UIAlertControllerStyle.alert)
                            
                            let account = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                (result : UIAlertAction) -> Void in
                                LoginManager().logOut()
                                return
                            }
                            
                            alertController.addAction(account)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            Auth.auth().currentUser?.updateEmail(to: email) { (error) in
                            }
                            self.facebookSignIn(email: email)
                        }
                    } else {
                        self.facebookSignIn(email: (Auth.auth().currentUser?.email)!)
                    }
                }
            }
        }
    }
    
    func facebookSignIn(email: String) {
        let docRef = Firestore.firestore().collection("UserMovieList").document(email)
        docRef.getDocument { (document, error) in
            if let error = error {
                self.logError(logString: "Login VC - Error Getting Document via Facebook", logError: error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    self.logError(logString: "Login VC - Logging in with already created document via Facebook")
                    UIApplication.shared.endIgnoringInteractionEvents()
                    UserDefaults.standard.set(true, forKey: "offeredSignIn")
                    UserDefaults.standard.set(email, forKey: "loggedIn")
                    self.performSegue(withIdentifier: "loggedIn1", sender: self)
                } else {
                    self.logError(logString: "Login VC - Logging in by creating new document via Google")
                    var tempMovieArray = [String]()
                    for seenMovie in Items.sharedInstance.moviesSeenArray {
                        tempMovieArray.append(seenMovie.name)
                    }
                    Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                    Firestore.firestore().collection("UserMovieList").document(email).setData([
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
                        "Name": Auth.auth().currentUser?.displayName ?? "No Name",
                        "Image URL": Auth.auth().currentUser!.photoURL?.absoluteString ?? "nil",
                        "FacebookID": AccessToken.current?.userId ?? ""
                    ]) { err in
                        if let err = err {
                            self.logError(logString: "Login VC - Error Creating Account via Facebook", logError: err.localizedDescription)
                            UIApplication.shared.endIgnoringInteractionEvents()
                            
                            let alertController = UIAlertController(title: "Error", message: "We were unable to create your account via Facebook. Please try again", preferredStyle: UIAlertControllerStyle.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                (result : UIAlertAction) -> Void in
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            UIApplication.shared.endIgnoringInteractionEvents()
                            UserDefaults.standard.set(true, forKey: "offeredSignIn")
                            UserDefaults.standard.set(email, forKey: "loggedIn")
                            self.performSegue(withIdentifier: "loggedIn1", sender: self)
                        }
                    }
                }
            }
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


