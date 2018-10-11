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

class LoginViewController: UIViewController {

    @IBAction func facebookLogin(_ sender: Any) {
        let loginManager=LoginManager()
        loginManager.logIn(readPermissions: [ReadPermission.publicProfile], viewController : self) { loginResult in
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AccessToken.current != nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    // ...
                    let alertController = UIAlertController(title: "Error", message: "There was a problem creating your account. Please try again", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let account = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                        return
                    }
                    
                    alertController.addAction(account)
                    self.present(alertController, animated: true, completion: nil)
                }
                
                let docRef = Firestore.firestore().collection("UserMovieList").document((Auth.auth().currentUser?.email)!)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        Items.sharedInstance.moviesSeenArray.removeAll()
                        let movies = document.data()!["movies"] as! [String]
                        for item in movies {
                            for movie in Items.sharedInstance.movieArray {
                                if item == movie.name {
                                    Items.sharedInstance.moviesSeenArray.append(movie)
                                }
                            }
                        }
                    } else {
                        var tempMovieArray = [String]()
                        for seenMovie in Items.sharedInstance.moviesSeenArray {
                            tempMovieArray.append(seenMovie.name)
                        }
                        Firestore.firestore().collection("UserMovieList").document((Auth.auth().currentUser?.email)!).setData([
                            "movies": tempMovieArray
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                    }
                }
                UserDefaults.standard.set(true, forKey: "offeredSignIn")
                self.performSegue(withIdentifier: "unwindToMovie", sender: self)
            }
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
