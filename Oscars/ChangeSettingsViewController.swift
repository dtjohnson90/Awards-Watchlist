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

class ChangeSettingsViewController: UIViewController {

    var rowSelected = Int()
    var name = ""
    var email = ""
    
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var changeTextField: UITextField!
    
    @IBAction func saveClicked(_ sender: Any) {
        if (changeTextField.text?.isEmpty)!{
            let alertController = UIAlertController(title: "Error", message: "The text field cannot be blank.", preferredStyle: UIAlertControllerStyle.alert)
            
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if rowSelected == 0 {
                Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).updateData([
                    "Name": changeTextField.text!
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        self.performSegue(withIdentifier: "backToSettings", sender: self)
                    }
                }
            } else {
                let oldDoc = Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn)
                oldDoc.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let newDoc = Firestore.firestore().collection("UserMovieList").document(self.changeTextField.text!)
                        newDoc.getDocument { (document2, error) in
                            if let document2 = document2, document2.exists {
                                let alertController = UIAlertController(title: "Error", message: "This email is already being used by another user.", preferredStyle: UIAlertControllerStyle.alert)
                                
                                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                    (result : UIAlertAction) -> Void in
                                }
                                
                                alertController.addAction(ok)
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                newDoc.setData([
                                    "movies": document.data()!["movies"]!,
                                    "Best Picture": document.data()!["Best Picture"]!,
                                    "Best Actor": document.data()!["Best Actor"]!,
                                    "Best Actress": document.data()!["Best Actress"]!,
                                    "Supporting Actor": document.data()!["Supporting Actor"]!,
                                    "Supporting Actress": document.data()!["Supporting Actress"]!,
                                    "Animated": document.data()!["Animated"]!,
                                    "Cinematography": document.data()!["Cinematography"]!,
                                    "Costume Design": document.data()!["Costume Design"]!,
                                    "Directing": document.data()!["Directing"]!,
                                    "Documentary Feature": document.data()!["Documentary Feature"]!,
                                    "Documentary Short": document.data()!["Documentary Short"]!,
                                    "Film Editing": document.data()!["Film Editing"]!,
                                    "Foreign": document.data()!["Foreign"]!,
                                    "Makeup": document.data()!["Makeup"]!,
                                    "Music Song": document.data()!["Music Song"]!,
                                    "Music Score": document.data()!["Music Score"]!,
                                    "Production Design": document.data()!["Production Design"]!,
                                    "Short Animated": document.data()!["Short Animated"]!,
                                    "Short Live": document.data()!["Short Live"]!,
                                    "Sound Editing": document.data()!["Sound Editing"]!,
                                    "Sound Mixing": document.data()!["Sound Mixing"]!,
                                    "Visual Effects": document.data()!["Visual Effects"]!,
                                    "Writing Adapted": document.data()!["Writing Adapted"]!,
                                    "Writing Original": document.data()!["Writing Original"]!,
                                    "Invitations": document.data()!["Invitations"]!,
                                    "Friends": document.data()!["Friends"]!,
                                    "Name": document.data()!["Name"]!
                                ]) { err in
                                    if let err = err {
                                        print("Error writing document: \(err)")
                                    } else {
                                        print("Document successfully written!")
                                        oldDoc.delete() { err in
                                            if let err = err {
                                                print("Error removing document: \(err)")
                                            } else {
                                                print("Document successfully removed!")
                                                Items.sharedInstance.loggedIn = self.changeTextField.text!
                                                UserDefaults.standard.set(Items.sharedInstance.loggedIn, forKey: "loggedIn")
                                                self.performSegue(withIdentifier: "backToSettings", sender: self)
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        switch rowSelected {
        case 0:
            changeLabel.text = "Edit Name Below"
            changeTextField.text = name
        case 1:
            changeLabel.text = "Edit Email Below"
            changeTextField.text = email
        default:
            return
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
