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

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    
    @IBAction func loginPushed(_ sender: Any) {
        if (usernameField.text?.isEmpty)! || (passwordField.text?.isEmpty)! {
            let alertController = UIAlertController(title: "Error", message: "Please make sure all fields are filled out", preferredStyle: UIAlertControllerStyle.alert)
            
            
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().signIn(withEmail: usernameField.text!, password: passwordField.text!) { (user, error) in
                if let error = error {
                    print(error)
                    let alertController = UIAlertController(title: "Error", message: "The username/password combination is not correct. Please check your connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                    }
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    if !(Auth.auth().currentUser?.isEmailVerified)! {
                        let alertController = UIAlertController(title: "Error", message: "You must verify your email address before logging in. To resend the email, tap below.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                            do {
                                try Auth.auth().signOut()
                            } catch let signOutError as NSError {
                                print ("Error signing out: %@", signOutError)
                            }
                            return
                        }
                        
                        let resend = UIAlertAction(title: "Resend Email", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                            Auth.auth().currentUser?.sendEmailVerification { (error) in
                                // ...
                                if let error = error {
                                    print(error)
                                } else {
                                    let alertController = UIAlertController(title: "", message: "An email has been sent for verification. Please verify this email before you can login.", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    
                                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                        (result : UIAlertAction) -> Void in
                                        do {
                                            try Auth.auth().signOut()
                                        } catch let signOutError as NSError {
                                            print ("Error signing out: %@", signOutError)
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
                            if let document = document, document.exists {
                                self.performSegue(withIdentifier: "loggedIn1", sender: self)
                            } else {
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
                                    "Image URL": Auth.auth().currentUser!.photoURL?.absoluteString
                                ]) { err in
                                    if let err = err {
                                        print("Error writing document: \(err)")
                                    } else {
                                        print("Document successfully written!")
                                        self.performSegue(withIdentifier: "loggedIn1", sender: self)
                                    }
                                }
                            }
                        }
                        UserDefaults.standard.set(true, forKey: "offeredSignIn")
                        UserDefaults.standard.set(self.usernameField.text!, forKey: "loggedIn")
                    }
                }
            }
        }
    }
    
    
    @IBAction func facebookLogin(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ReadPermission.publicProfile, ReadPermission.email], viewController: self) {loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login")
            case .success:
                print("Logged in")
            }
        }
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        emailLabel.adjustsFontSizeToFitWidth = true
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
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
                        print("Logged In")
                        self.performSegue(withIdentifier: "loggedIn1", sender: self)
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
                            "Name": Auth.auth().currentUser!.displayName!,
                            "Image URL": Auth.auth().currentUser!.photoURL?.absoluteString
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                                self.performSegue(withIdentifier: "loggedIn1", sender: self)
                            }
                        }
                    }
                }
                UserDefaults.standard.set(true, forKey: "offeredSignIn")
                UserDefaults.standard.set(Auth.auth().currentUser?.email, forKey: "loggedIn")
                Items.sharedInstance.loggedIn = (Auth.auth().currentUser?.email)!
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AccessToken.current != nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
            var email = String()
            
            var graph = GraphRequest.init(graphPath: "me")
            graph.parameters = ["fields": "email"]
            graph.start({(connection, result) in
                switch result {
                case .failed(let error):
                    // Unable to get Facebook Information
                    print(error)
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
                            //Join Failed. Let user know why
                            
                            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            
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
                                print("Where we should be")
                                self.facebookSignIn(email: (Auth.auth().currentUser?.email)!)
                            }
                        }
                    }
                } else {
                    if Auth.auth().currentUser?.email == nil {
                        if email == "" {
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
        print(email)
        let docRef = Firestore.firestore().collection("UserMovieList").document(email)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("Found Document")
                self.performSegue(withIdentifier: "loggedIn1", sender: self)
            } else {
                print("Error finding document")
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
                    "Image URL": Auth.auth().currentUser!.photoURL?.absoluteString
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                        self.performSegue(withIdentifier: "loggedIn1", sender: self)
                    }
                }
            }
        }
        UserDefaults.standard.set(true, forKey: "offeredSignIn")
        UserDefaults.standard.set(email, forKey: "loggedIn")
    }
}
