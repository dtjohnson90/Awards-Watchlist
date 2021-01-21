//
//  CreateAccountViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/24/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var password2Field: UITextField!
    @IBOutlet weak var animateView: UIView!
    @IBOutlet weak var loadingReel: UIImageView!
    
    var activeTextField = UITextField()
    var moved = false
    
    @IBAction func saveClicked(_ sender: Any) {
        if (firstNameField.text?.isEmpty)! || (lastNameField.text?.isEmpty)! || (emailField.text?.isEmpty)! || (passwordField.text?.isEmpty)! || (password2Field.text?.isEmpty)! {
            let alertController = UIAlertController(title: "Error", message: "Please make sure all fields are filled out", preferredStyle: UIAlertController.Style.alert)
            

            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if passwordField.text != password2Field.text {
                let alertController = UIAlertController(title: "Error", message: "The password fields do not match", preferredStyle: UIAlertController.Style.alert)
                
                
                let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                }
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            } else if (passwordField.text?.count)! < 6 {
                let alertController = UIAlertController(title: "Error", message: "The password must be atleast 6 characters", preferredStyle: UIAlertController.Style.alert)
                
                
                let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                }
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            } else {
                UIApplication.shared.beginIgnoringInteractionEvents()
                self.loadingReel.isHidden = false
                self.loadingReel.rotate()
                
                let userRef = Firestore.firestore().collection("Users").document(emailField.text!)
                let movieRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(emailField.text!)
                userRef.getDocument { (document, error) in
                    if let error = error {
                        self.logError(logString: "Create Account VC - Getting Document To Test Create", logError: error.localizedDescription)
                    } else {
                        if let document = document, document.exists {
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.loadingReel.layer.removeAllAnimations()
                            let alertController = UIAlertController(title: "Error", message: "There is already an account with this email address. Please use a different email or login to your account.", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!) { (authResult, error) in
                                if let error = error {
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    self.loadingReel.layer.removeAllAnimations()
                                    self.logError(logString: "Create Account VC - Problem Creating User", logError: error.localizedDescription)
                                    let alertController = UIAlertController(title: "Error", message: "There was a problem creating this account. Check your network connection and try again.", preferredStyle: UIAlertController.Style.alert)
                                    
                                    
                                    let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                        (result : UIAlertAction) -> Void in
                                    }
                                    
                                    alertController.addAction(ok)
                                    self.present(alertController, animated: true, completion: nil)
                                } else {
                                    self.logError(logString: "Create Account VC - Account Created Succesfully")
                                    guard (authResult?.user) != nil else { return }
                                    let fullName = self.firstNameField.text! + " " + self.lastNameField.text!
                                    
                                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                    changeRequest?.displayName = fullName
                                    changeRequest?.commitChanges { (error) in
                                        if let error = error {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            self.loadingReel.layer.removeAllAnimations()
                                            self.logError(logString: "Create Account VC - Error Updating Name", logError: error.localizedDescription)
                                        }
                                    }
                                    
                                    var tempMovieArray = [String]()
                                    for seenMovie in Items.sharedInstance.moviesSeenArray {
                                        tempMovieArray.append(seenMovie.name)
                                    }
                                    Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                                    movieRef.setData([
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
                                        "Writing Original": ""
                                    ]) { err in
                                        if let err = err {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            self.loadingReel.layer.removeAllAnimations()
                                            self.logError(logString: "Create Account VC - Error Creating Document", logError: err.localizedDescription)
                                        } else {
                                            let fullName = self.firstNameField.text! + " " + self.lastNameField.text!
                                            self.logError(logString: "Create Account VC - Creating document in 'Users'")
                                            Firestore.firestore().collection("Users").document(self.emailField.text!).setData([
                                                "FacebookID": "",
                                                "Friends": [],
                                                "Invitations": [],
                                                "Name": fullName,
                                                "imageURL": Auth.auth().currentUser!.photoURL?.absoluteString ?? "nil",
                                                "notificationToken": Items.sharedInstance.notificationToken,
                                                "pastLists": []
                                            ]) { err in
                                                if let err = err {
                                                    UIApplication.shared.endIgnoringInteractionEvents()
                                                    self.loadingReel.layer.removeAllAnimations()
                                                    self.logError(logString: "LoginVC - Unable to create user account", logError: err.localizedDescription)
                                                    let alertController = UIAlertController(title: "Error", message: "We were unable to create your account via email. Please try again", preferredStyle: UIAlertController.Style.alert)
                                                    
                                                    
                                                    let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                                        (result : UIAlertAction) -> Void in
                                                    }
                                                    
                                                    alertController.addAction(ok)
                                                    self.present(alertController, animated: true, completion: nil)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                                        // ...
                                        if let error = error {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            self.loadingReel.layer.removeAllAnimations()
                                            self.logError(logString: "Create Account VC - Problem Sending Verification Email", logError: error.localizedDescription)
                                            let alertController = UIAlertController(title: "Error", message: "There was a problem sending the email for verification. Please make sure it is a good email and try again", preferredStyle: UIAlertController.Style.alert)
                                            
                                            
                                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                                (result : UIAlertAction) -> Void in
                                                self.performSegue(withIdentifier: "toLoginSegue", sender: self)
                                            }
                                            
                                            alertController.addAction(ok)
                                            self.present(alertController, animated: true, completion: nil)
                                        } else {
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            self.loadingReel.layer.removeAllAnimations()
                                            self.logError(logString: "Create Account VC - Verification email sent to \(Auth.auth().currentUser?.email ?? "nil")")
                                            let alertController = UIAlertController(title: "", message: "An email has been sent for verification. You must verify this email before you can login.", preferredStyle: UIAlertController.Style.alert)
                                            
                                            
                                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                                (result : UIAlertAction) -> Void in
                                                self.performSegue(withIdentifier: "toLoginSegue", sender: self)
                                            }
                                            
                                            alertController.addAction(ok)
                                            self.present(alertController, animated: true, completion: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadingReel.isHidden = true
        
        hideKeyboardWhenTappedAround()
        passwordField.delegate = self
        password2Field.delegate = self
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
        
        if view.frame.height - activeTextField.frame.origin.y < keyboardSize.height + 100 {
            // move the root view up by the distance of keyboard height
            self.view.frame.origin.y = 0 - keyboardSize.height
            moved = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if moved {
            // move back the root view origin to zero
            self.view.frame.origin.y = 0
            moved = false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
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
