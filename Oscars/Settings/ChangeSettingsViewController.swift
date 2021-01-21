//
//  ChangeSettingsViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/23/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase

class ChangeSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var name = ""
    let imageUploadManager = ImageUploadManager()
    var memberImage = Items.sharedInstance.profilePic
    var imageUpdated = false
    
    @IBOutlet weak var changeTextField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBAction func changeClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Profile Picture", message: "Would you like to take a picture or upload one from your photo library?", preferredStyle: UIAlertController.Style.alert)
        
        let library = UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.logError(logString: "Change Settings VC - Editing Picture From Photo Library")
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let photo = UIAlertAction(title: "Take Picture", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.logError(logString: "Change Settings VC - Editing Picture From Camera")
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
        }
        alertController.addAction(library)
        alertController.addAction(photo)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        if (changeTextField.text?.isEmpty)!{
            let alertController = UIAlertController(title: "Error", message: "The text field cannot be blank.", preferredStyle: UIAlertController.Style.alert)
            
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        } else {
            UIApplication.shared.beginIgnoringInteractionEvents()
            let userRef = Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn)
            userRef.updateData([
                "Name": changeTextField.text!
            ]) { err in
                if let err = err {
                    self.logError(logString: "Change Settings VC - Problem Updating Name", logError: err.localizedDescription)
                    let alertController = UIAlertController(title: "Error", message: "There was a problem saving your name. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                    
                    
                    let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    if self.imageUpdated {
                        self.imageUploadManager.uploadImage(self.memberImage!, progressBlock: { [unowned self] (percentage) in
                            }, completionBlock: { [unowned self] (fileURL, errorMessage) in
                                if let fileURL = fileURL {
                                    userRef.updateData([
                                        "imageURL": fileURL.absoluteString
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Change Settings VC - Problem Updating Picture", logError: err.localizedDescription)
                                            let alertController = UIAlertController(title: "Error", message: "There was an error attempting to save picture", preferredStyle: UIAlertController.Style.alert)
                                            
                                            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                                                (result : UIAlertAction) -> Void in
                                                UIApplication.shared.endIgnoringInteractionEvents()
                                                self.performSegue(withIdentifier: "nameUpdatedSegue", sender: self)
                                            }
                                            alertController.addAction(okAction)
                                            self.present(alertController, animated: true, completion: nil)
                                        } else {
                                            Items.sharedInstance.profilePic = memberImage
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            self.performSegue(withIdentifier: "backToSettings", sender: self)
                                        }
                                    }
                                }
                        })
                    } else {
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.performSegue(withIdentifier: "backToSettings", sender: self)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
                
        Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn).getDocument { (document, error) in
            if let error = error {
                self.logError(logString: "Change Settings VC - Error Accessing User Document", logError: error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    self.changeTextField.text = document.data()!["Name"] as? String
                    self.profilePic.image = self.memberImage
                } else {
                    self.logError(logString: "Change Settings VC - User Document doesn't exist")
                    let alertController = UIAlertController(title: "Error", message: "There was a problem loading your information. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                    
                    
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
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let editedImage = info[.editedImage] as? UIImage
        let originalImage = info[.originalImage] as? UIImage
        
        if editedImage != nil {
            memberImage = editedImage
            profilePic.image = editedImage
            imageUpdated = true
        } else if originalImage != nil {
            memberImage = originalImage
            profilePic.image = originalImage
            imageUpdated = true
        }
            
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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

