//
//  LoginViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/10/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import MessageUI
import AuthenticationServices
import CryptoKit

class LoginViewController: UIViewController, GIDSignInDelegate, MFMailComposeViewControllerDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    @IBOutlet weak var loginStack: UIStackView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var orView: UIView!
    @IBOutlet weak var stackHeight: NSLayoutConstraint!
    
    fileprivate var currentNonce: String?
    let errorManager = ErrorManager()
    
    @IBAction func forgotPassword(_ sender: Any) {
        self.logError(logString: "Login VC - Forgot Password Clicked")
        
        let alert = UIAlertController(title: "Forgot Password?", message: "Enter the email address for your account.", preferredStyle: .alert)
        alert.addTextField { (textField) in
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.textFields![0].placeholder = "Email"
        }))
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            let email = textField.text!
            Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(email).getDocument { (document, error) in
                if let error = error {
                    self.logError(logString: "Login VC - Getting User Document Password Reset Error", logError: error)
                    self.callError(title: "Password Reset Error", message: "An unknown error has occured. Please try again.")
                } else {
                    if let document = document, document.exists {
                        Auth.auth().sendPasswordReset(withEmail: textField.text!) { (error) in
                            if let error = error {
                                self.logError(logString: "Login VC - Problem Sending Password Reset Email (To: \(email))", logError: error)
                                self.callError(title: "Error", message: "There was a problem sending the password reset email. Please try again")
                            } else {
                                self.logError(logString: "Login VC - Password Reset Email Sent (To: \(email))")
                                self.callError(title: "Reset Password", message: "An email has been sent to \(email). Please click on the link in the email to reset your password")
                            }
                        }
                    } else {
                        self.logError(logString: "Login VC - Attempted Login With Wrong Email (To: \(email))")
                        self.callError(title: "Error", message: "There is not an account with that email address. Please try again.")
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginPushed(_ sender: Any) {
        self.logError(logString: "Login VC - Attempting Login")
        UIApplication.shared.beginIgnoringInteractionEvents()
        if (usernameField.text?.isEmpty)! || (passwordField.text?.isEmpty)! {
            UIApplication.shared.endIgnoringInteractionEvents()
            self.logError(logString: "Login VC - Tried to login with blank email / password")
            self.callError(title: "Error", message: "One or more fields was left blank. Please try again")
        } else {
            Auth.auth().signIn(withEmail: usernameField.text!, password: passwordField.text!) { (user, error) in
                if let error = error {
                    self.logError(logString: "Login VC - Error Logging In (To: \(self.usernameField.text!))", logError: error)
                    self.signInError(error: error)
                } else {
                    if !(Auth.auth().currentUser?.isEmailVerified)! {
                        self.logError(logString: "Login VC - Email Not Verified")
                        UIApplication.shared.endIgnoringInteractionEvents()

                        let alertController = UIAlertController(title: "Error", message: "You must verify your email address before logging in. To resend the email, tap below.", preferredStyle: UIAlertController.Style.alert)
                        
                        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                            do {
                                try Auth.auth().signOut()
                            } catch let signOutError as NSError {
                                self.logError(logString: "Login VC - Error Signing Out (Email Verification)", logError: signOutError)
                            }
                            return
                        }
                        
                        let resend = UIAlertAction(title: "Resend Email", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                            UIApplication.shared.endIgnoringInteractionEvents()
                            Auth.auth().currentUser?.sendEmailVerification { (error) in
                                if let error = error {
                                    self.logError(logString: "Login VC - Error Re-Sending Verification Email (To: \(Auth.auth().currentUser?.email ?? "nil"))", logError: error)
                                    self.signInError(error: error)
                                } else {
                                    self.logError(logString: "Login VC - Verification Email Re-Sent (To: \(Auth.auth().currentUser?.email ?? "nil"))")
                                    do {
                                        try Auth.auth().signOut()
                                    } catch let signOutError as NSError {
                                        self.logError(logString: "Login VC - Error Signing Out (Resend Verification)", logError: signOutError)
                                        self.signInError(error: signOutError)
                                    }
                                    self.callError(title: "Success!", message: "An email has been sent for verification. Please verify this email before you attempt to login.")
                                }
                            }
                            return
                        }
                        
                        alertController.addAction(cancel)
                        alertController.addAction(resend)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let docRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document((self.usernameField.text)!)
                        docRef.getDocument { (document, error) in
                            if let error = error {
                                self.logError(logString: "Login VC - Creating Document Via Email", logError: error)
                                self.callError(title: "Error", message: "There was an issue accessing your account. Please try again.")
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
                                    Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document((self.usernameField.text)!).setData([
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
                                        "Name": Auth.auth().currentUser!.displayName ?? "No Name",
                                        "Image URL": Auth.auth().currentUser!.photoURL?.absoluteString ?? "nil"
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Login VC - Error Creating Document via Email", logError: err)
                                            self.callError(title: "Error", message: "There was a problem creating your account. Please quit the app and try again")
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
        loginManager.logIn(permissions: [.publicProfile, .email, .userFriends], viewController: self) {loginResult in
            switch loginResult {
            case .failed(let error):
                self.logError(logString: "Login VC - Facebook Login Failed", logError: error)
                self.callError(title: "Error", message: "We were unable to login via Facebook. Please try again")
                UIApplication.shared.endIgnoringInteractionEvents()
            case .cancelled:
                self.logError(logString: "Login VC - Facebook Login Cancelled")
                UIApplication.shared.endIgnoringInteractionEvents()
            case .success:
                self.logError(logString: "Login VC - Logged in via Facebook")
                self.checkFacebook()
            }
        }
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        self.logError(logString: "Logged in via Google")
        UIApplication.shared.beginIgnoringInteractionEvents()
        GIDSignIn.sharedInstance().signIn()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        facebookView.layer.shadowOffset = CGSize(width: 0, height: 3)
        facebookView.layer.shadowRadius = 2
        facebookView.layer.shadowOpacity = 0.5
        facebookView.layer.cornerRadius = 5
        googleView.layer.cornerRadius = 5
        googleView.layer.shadowOffset = CGSize(width: 0, height: 3)
        googleView.layer.shadowRadius = 2
        googleView.layer.shadowOpacity = 0.5
        
        if #available(iOS 13.0, *) {
            let appleButton = ASAuthorizationAppleIDButton()
            appleButton.layer.shadowOffset = CGSize(width: 0, height: 3)
            appleButton.layer.shadowRadius = 2
            appleButton.layer.shadowOpacity = 0.5
            appleButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            loginStack.insertArrangedSubview(appleButton, at: 0)
        } else {
            orView.isHidden = true
        }
        
        
        loginLabel.isUserInteractionEnabled = true
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap))
        loginLabel.addGestureRecognizer(longGesture)
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        self.logError(logString: "Login VC - Getting settings document to update data")
        Firestore.firestore().collection("Settings").document("AppInformation").getDocument { (document, error) in
            if let error = error {
                self.logError(logString: "Loading VC - Getting 'Is Updating'", logError: error)
                self.callError(title: "Error", message: "There was an issue loading the data required. Please quit the app and try again.")
            } else {
                if let document = document, document.exists {
                    Items.sharedInstance.userMovieListYear = document.data()!["listToUse"] as! String
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    @objc func handleAuthorizationAppleIDButtonPress() {
        self.logError(logString: "Login VC - Attempting Login via Apple")
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        self.currentNonce = randomNonceString()
        request.nonce = sha256(currentNonce!)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    @available(iOS 13.0, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
            guard let nonce = currentNonce else {
                self.logError(logString: "Login VC - Logging in via apple and no login request was sent, but a login callback was received")
                self.callError(title: "Error", message: "Unable to login via Apple. Please try again")
                return
            }

            guard let appleIDToken = appleIDCredential.identityToken else {
                self.logError(logString: "Login VC - Failed to fetch identity token")
                self.callError(title: "Error", message: "Unable to login via Apple. Please try again")
                return
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.logError(logString: "Login VC - Failed to decode identity token")
                self.callError(title: "Error", message: "Unable to login via Apple. Please try again")
                return
            }

            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
            
            Auth.auth().signIn(with: firebaseCredential) { [weak self] (authResult, error) in
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                let userDoc = Firestore.firestore().collection("Users").document((Auth.auth().currentUser?.email)!)
                userDoc.getDocument { (document, error) in
                    if let error = error {
                        self?.logError(logString: "Login VC - Error getting \(Auth.auth().currentUser?.email ?? "nil") document while logging into Apple", logError: error)
                        self?.callError(title: "Error", message: "Unable to login via Apple. Please try again")
                    } else {
                        if let document = document, document.exists {
                            changeRequest?.commitChanges { (error) in
                                self?.logError(logString: "Login VC - Logging in via Apple")
                                self!.signIn(Type: "Apple", email: (Auth.auth().currentUser?.email)!)
                            }
                        } else {
                            self?.logError(logString: "Login VC - Logging in via Apple for the first time")
                            let firstName = appleIDCredential.fullName?.givenName
                            let lastName = appleIDCredential.fullName?.familyName
                            changeRequest?.displayName = firstName! + " " + lastName!
                            changeRequest?.commitChanges { (error) in
                                self!.signIn(Type: "Apple", email: (Auth.auth().currentUser?.email)!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
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
                self.logError(logString: "Login VC - File Data Loaded")
                mail.addAttachmentData(fileData as Data, mimeType: "text/txt", fileName: "logFile.txt")
            }
            
            present(mail, animated: true)
        } else {
            self.logError(logString: "Settings VC - Unable to send email with Logs")
            self.callError(title: "Error", message: "The email is unable to automatically send. Please send an email to 'dtjohnsonapps@gmail.com' to file an issue report.")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            self.logError(logString: "Login VC - Problem Logging In Via Google", logError: error)
            let errorCode = (error as NSError).code
            if errorCode != -5 {
                self.errorManager.googleError(error: errorCode, completionBlock: {(title,showError,errorString) in
                    if showError {
                        self.callError(title: "Error", message: "We were unable to login via Google. Please try again")
                    }
                })
            }
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            self.logError(logString: "Login VC - Error Creating Account via Google", logError: error)
            self.signInError(error: error)
            GIDSignIn.sharedInstance()?.signOut()
          } else {
                self.signIn(Type: "Google", email: (Auth.auth().currentUser?.email)!)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkFacebook()
    }
    
    func checkFacebook() {
        if AccessToken.current != nil {
            UIApplication.shared.beginIgnoringInteractionEvents()
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            var email = ""
            
            let connection = GraphRequestConnection()
            connection.add(GraphRequest(graphPath: "/me", parameters: ["fields": "email"])) { httpResponse, result, error in
                
                if error != nil {
                    UIApplication.shared.endIgnoringInteractionEvents()

                    self.logError(logString: "Login VC - Graph Request Error", logError: error!)
                    self.callError(title: "Error", message: "There was a problem creating your account. Please quit the app and try again.")
                    LoginManager().logOut()
                } else {
                    if let result = result as? [String:String] {
                        email = result["email"]!
                    }
                }
            }
            connection.start()
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
              if let error = error {
                self.signInError(error: error)
                LoginManager().logOut()
              } else {
                if Auth.auth().currentUser?.email == nil {
                    if email == "" {
                        self.logError(logString: "Login VC - Not Email setup with Facebook")
                        self.callError(title: "Error", message: "You do not have an email setup with this facebook. Please sign in with a different account or add an email to your facebook settings.")
                        LoginManager().logOut()
                    } else {
                        Auth.auth().currentUser?.updateEmail(to: email) { (error) in
                        }
                        self.signIn(Type: "Facebook", email: email)
                    }
                } else {
                    self.signIn(Type: "Facebook", email: (Auth.auth().currentUser?.email)!)
                }
            }
        }
        }
    }
    
    func signIn(Type: String, email: String) {
        let docRef = Firestore.firestore().collection("Users").document(email)
        docRef.getDocument { (document, error) in
            if let error = error {
                self.logError(logString: "Login VC - Error Getting New Document via \(Type) in Users collection with email \(email)", logError: error)
            } else {
                if let document = document, document.exists {
                    self.logError(logString: "Login VC - Users document exists. Checking for movieList document")
                    let docRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(email)
                    docRef.getDocument { (document, error) in
                        if let error = error {
                            self.logError(logString: "Login VC - Error Getting movieList Document via \(Type)", logError: error)
                        } else {
                            if let document = document, document.exists {
                                self.logError(logString: "Login VC - Logging in with already created document via \(Type)")
                                UIApplication.shared.endIgnoringInteractionEvents()
                                UserDefaults.standard.set(true, forKey: "offeredSignIn")
                                UserDefaults.standard.set(email, forKey: "loggedIn")
                                Items.sharedInstance.loggedIn = email
                                self.performSegue(withIdentifier: "loggedIn1", sender: self)
                            } else {
                                self.logError(logString: "Login VC - User document exists, but movie document does not")
                                var tempMovieArray = [String]()
                                for seenMovie in Items.sharedInstance.moviesSeenArray {
                                    tempMovieArray.append(seenMovie.name)
                                }
                                Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                                self.uploadData(movieArray: tempMovieArray, email: email, type: Type)
                            }
                        }
                    }
                } else {
                    self.logError(logString: "Login VC - Users document doesn't exist. Creating Users and MovieList Documents")
                    Firestore.firestore().collection("Users").document(email).setData([
                        "FacebookID": AccessToken.current?.userID ?? "",
                        "Friends": [],
                        "Invitations": [],
                        "Name": Auth.auth().currentUser?.displayName ?? "No Name",
                        "imageURL": Auth.auth().currentUser!.photoURL?.absoluteString ?? "nil",
                        "notificationToken": Items.sharedInstance.notificationToken,
                        "pastLists": []
                    ]) { err in
                        if let err = err {
                            self.logError(logString: "LoginVC - Unable to create user account", logError: err)
                            self.callError(title: "Error", message: "We were unable to create your account via \(Type). Please try again")
                        } else {
                            self.logError(logString: "Login VC - User document created, creating movieList document")
                            var tempMovieArray = [String]()
                            for seenMovie in Items.sharedInstance.moviesSeenArray {
                                tempMovieArray.append(seenMovie.name)
                            }
                            Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                            self.uploadData(movieArray: tempMovieArray, email: email, type: Type)
                        }
                    }
                }
            }
        }
    }
    
    func uploadData(movieArray: [String], email: String, type: String){
        Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(email).setData([
            "movies": movieArray,
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
                self.logError(logString: "Login VC - Error Creating Account via \(type)", logError: err)
                self.callError(title: "Error", message: "We were unable to create your account via \(type). Please try again")
                
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
                UserDefaults.standard.set(true, forKey: "offeredSignIn")
                UserDefaults.standard.set(email, forKey: "loggedIn")
                Items.sharedInstance.loggedIn = email
                self.performSegue(withIdentifier: "loggedIn1", sender: self)
            }
        }
    }
    
    func logError(logString: String, logError: Error? = nil) {
        if logError != nil {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent("logFile.txt")
                try logString.appendLine(to: url as URL)
            }
            catch {
                print("Could not write to file")
            }
        } else {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent("logFile.txt")
                try logString.appendLine(to: url as URL)
                try String(describing: logError).appendLine(to: url as URL)
            }
            catch {
                print("Could not write to file")
            }
        }
    }
    
    func signInError(error: Error) {
        let errorCode = (error as NSError).userInfo["FIRAuthErrorUserInfoNameKey"] as! String

        if errorCode == "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL" {
            let errorEmail = (error as NSError).userInfo["FIRAuthErrorUserInfoEmailKey"] as! String
            Auth.auth().fetchSignInMethods(forEmail: errorEmail, completion: { (providers, error) in
                let myProviders = providers! as [String]
                let providerCount = myProviders.count
                if providerCount == 1 {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    let provider = myProviders[0].components(separatedBy: ".")[0]
                    let message = "You have previously signed in with \(provider). Please sign in with that provider."
                    self.callError(title: "Sign In Error", message: message)
                } else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    let provider1 = myProviders[0].components(separatedBy: ".")[0]
                    let provider2 = myProviders[1].components(separatedBy: ".")[0]
                    let message = "You have previously signed in with \(provider1) and \(provider2). Please sign in with one of those providers."
                    self.callError(title: "Sign In Error", message: message)
                }
            })
        } else {
            self.errorManager.firestoreError(error: errorCode, completionBlock: {(title,showError,errorString) in
                if showError {
                    self.callError(title: title, message: errorString)
                }
            })
        }
    }
    
    func callError(title: String, message: String) {
        UIApplication.shared.endIgnoringInteractionEvents()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
         (result : UIAlertAction) -> Void in
         return }

        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}




