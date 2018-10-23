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

    var comingFrom = String()
    
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
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
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
                        Items.sharedInstance.moviesSeenArray.removeAll()
                        Items.sharedInstance.predictions.removeAll()
                        
                        let nomList = ["Best Picture","Best Actor","Best Actress","Supporting Actor","Supporting Actress","Animated","Cinematography","Costume Design","Directing","Documentary Feature","Documentary Short","Film Editing","Foreign","Makeup","Music Score","Music Song","Production Design","Short Animated","Short Live","Sound Editing","Sound Mixing","Visual Effects","Writing Adapted","Writing Original"]
                        for item in nomList {
                            Items.sharedInstance.predictions.append(document.data()![item] as! String)
                        }
                        
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
                            "Name": Auth.auth().currentUser!.displayName!
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
                UserDefaults.standard.set(Auth.auth().currentUser?.email, forKey: "loggedIn")
                Items.sharedInstance.loggedIn = (Auth.auth().currentUser?.email)!
                if self.comingFrom == "B" {
                    self.performSegue(withIdentifier: "unwindFromLogin", sender: self)
                } else if self.comingFrom == "C" {
                    self.performSegue(withIdentifier: "unwindToSettings", sender: self)
                } else {
                    self.performSegue(withIdentifier: "unwindToMovie", sender: self)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AccessToken.current != nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
            
            Auth.auth().currentUser?.linkAndRetrieveData(with: credential)  { (authResult, error) in
                // ...
            }
            
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    // ...
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let account = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                        LoginManager().logOut()
                        return
                    }
                    
                    alertController.addAction(account)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let docRef = Firestore.firestore().collection("UserMovieList").document((Auth.auth().currentUser?.email)!)
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            Items.sharedInstance.moviesSeenArray.removeAll()
                            Items.sharedInstance.predictions.removeAll()
                            
                            let nomList = ["Best Picture","Best Actor","Best Actress","Supporting Actor","Supporting Actress","Animated","Cinematography","Costume Design","Directing","Documentary Feature","Documentary Short","Film Editing","Foreign","Makeup","Music Score","Music Song","Production Design","Short Animated","Short Live","Sound Editing","Sound Mixing","Visual Effects","Writing Adapted","Writing Original"]
                            for item in nomList {
                                Items.sharedInstance.predictions.append(document.data()![item] as! String)
                            }
                            
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
                                "Name": Auth.auth().currentUser?.displayName ?? "No Name"
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
                    UserDefaults.standard.set(Auth.auth().currentUser?.email, forKey: "loggedIn")
                    Items.sharedInstance.loggedIn = (Auth.auth().currentUser?.email)!
                    
                    if self.comingFrom == "B" {
                        self.performSegue(withIdentifier: "unwindFromLogin", sender: self)
                    } else if self.comingFrom == "C" {
                        self.performSegue(withIdentifier: "unwindToSettings", sender: self)
                    } else {
                        self.performSegue(withIdentifier: "unwindToMovie", sender: self)
                    }
                }
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
