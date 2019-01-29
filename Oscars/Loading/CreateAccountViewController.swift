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
    
    var screenSize = CGRect()
    var screenHeight = CGFloat()
    
    @IBAction func saveClicked(_ sender: Any) {
        if (firstNameField.text?.isEmpty)! || (lastNameField.text?.isEmpty)! || (emailField.text?.isEmpty)! || (passwordField.text?.isEmpty)! || (password2Field.text?.isEmpty)! {
            let alertController = UIAlertController(title: "Error", message: "Please make sure all fields are filled out", preferredStyle: UIAlertControllerStyle.alert)
            

            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if passwordField.text != password2Field.text {
                let alertController = UIAlertController(title: "Error", message: "The password fields do not match", preferredStyle: UIAlertControllerStyle.alert)
                
                
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                }
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            } else if (passwordField.text?.count)! < 6 {
                let alertController = UIAlertController(title: "Error", message: "The password must be atleast 6 characters", preferredStyle: UIAlertControllerStyle.alert)
                
                
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                }
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            } else {
                Firestore.firestore().collection("UserMovieList").document(emailField.text!).getDocument { (document, error) in
                    if let error = error {
                        self.logError(logString: "Create Account VC - Getting Document To Test Create", logError: error.localizedDescription)
                    } else {
                        if let document = document, document.exists {
                            let alertController = UIAlertController(title: "Error", message: "There is already an account with this email address. Please use a different email or login to your account.", preferredStyle: UIAlertControllerStyle.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                (result : UIAlertAction) -> Void in
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!) { (authResult, error) in
                                if let error = error {
                                    self.logError(logString: "Create Account VC - Problem Creating User", logError: error.localizedDescription)
                                    let alertController = UIAlertController(title: "Error", message: "There was a problem creating this account. Check your network connection and try again. If you think you already have an account, then attempt to sign in on the previous page", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    
                                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
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
                                            self.logError(logString: "Create Account VC - Error Updating Name", logError: error.localizedDescription)
                                        }
                                    }
                                    
                                    let docRef = Firestore.firestore().collection("UserMovieList").document((self.emailField.text)!)
                                    docRef.getDocument { (document, error) in
                                        if let error = error {
                                            self.logError(logString: "Create Account VC - Error Initially Creating Document", logError: error.localizedDescription)
                                        } else {
                                            var tempMovieArray = [String]()
                                            for seenMovie in Items.sharedInstance.moviesSeenArray {
                                                tempMovieArray.append(seenMovie.name)
                                            }
                                            Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                                            Firestore.firestore().collection("UserMovieList").document((self.emailField.text)!).setData([
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
                                                "Name": fullName,
                                                "Image URL": "nil"
                                            ]) { err in
                                                if let err = err {
                                                    self.logError(logString: "Create Account VC - Error Creating Document", logError: err.localizedDescription)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                                        // ...
                                        if let error = error {
                                            self.logError(logString: "Create Account VC - Problem Sending Verification Email", logError: error.localizedDescription)
                                            let alertController = UIAlertController(title: "Error", message: "There was a problem sending the email for verification. Please make sure it is a good email and try again", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            
                                            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                                (result : UIAlertAction) -> Void in
                                                self.performSegue(withIdentifier: "toLoginSegue", sender: self)
                                            }
                                            
                                            alertController.addAction(ok)
                                            self.present(alertController, animated: true, completion: nil)
                                        } else {
                                            self.logError(logString: "Create Account VC - Verification email sent to \(Auth.auth().currentUser?.email ?? "nil")")
                                            let alertController = UIAlertController(title: "", message: "An email has been sent for verification. Please verify this email before you can login.", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            
                                            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
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
        
        hideKeyboardWhenTappedAround()
        passwordField.delegate = self
        password2Field.delegate = self
        screenSize = UIScreen.main.bounds
        screenHeight = screenSize.height
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if screenHeight < 600 {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y - 200, width:self.view.frame.size.width, height:self.view.frame.size.height);
                
            })
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if screenHeight < 600 {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y + 200, width:self.view.frame.size.width, height:self.view.frame.size.height);
                
            })
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
