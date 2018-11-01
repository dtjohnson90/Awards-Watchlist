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
        let alertController = UIAlertController(title: "Profile Picture", message: "Would you like to take a picture or upload one from your photo library?", preferredStyle: UIAlertControllerStyle.alert)
        
        let library = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let photo = UIAlertAction(title: "Take Picture", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
        }
        alertController.addAction(library)
        alertController.addAction(photo)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        if (changeTextField.text?.isEmpty)!{
            let alertController = UIAlertController(title: "Error", message: "The text field cannot be blank.", preferredStyle: UIAlertControllerStyle.alert)
            
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let userRef = Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn)
            userRef.updateData([
                "Name": changeTextField.text!
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    if self.imageUpdated {
                        self.imageUploadManager.uploadImage(self.memberImage!, progressBlock: { [unowned self] (percentage) in
                            }, completionBlock: { [unowned self] (fileURL, errorMessage) in
                                print(errorMessage)
                                if let fileURL = fileURL {
                                    userRef.updateData([
                                        "Image URL": fileURL.absoluteString
                                    ]) { err in
                                        if let err = err {
                                            print("Error updating document: \(err)")
                                            let alertController = UIAlertController(title: "Error", message: "There was an error attempting to save picture \nError 1", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                                                (result : UIAlertAction) -> Void in
                                                self.performSegue(withIdentifier: "nameUpdatedSegue", sender: self)
                                            }
                                            alertController.addAction(okAction)
                                            self.present(alertController, animated: true, completion: nil)
                                        } else {
                                            print("Image successfully updated")
                                            self.performSegue(withIdentifier: "backToSettings", sender: self)
                                        }
                                    }
                                }
                        })
                    } else {
                        self.performSegue(withIdentifier: "backToSettings", sender: self)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).getDocument { (document, error) in
            if let document = document, document.exists {
                self.changeTextField.text = document.data()!["Name"] as? String
                self.profilePic.image = self.memberImage
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image : UIImage!
        
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = img
        }
        else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = img
        }
        
        Items.sharedInstance.profilePic = image
        memberImage = image
        profilePic.image = image
        imageUpdated = true
        picker.dismiss(animated: true,completion: nil)
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
}
