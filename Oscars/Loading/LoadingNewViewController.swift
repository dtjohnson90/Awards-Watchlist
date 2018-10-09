//
//  LoadingNewViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/8/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase
import FirebaseFirestore

class LoadingNewViewController: UIViewController {

    @IBOutlet weak var myActivityView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        myActivityView.startAnimating()
        
        let downloading = DispatchGroup()
        Firestore.firestore().collection("Movies").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for movie in querySnapshot!.documents {
                    downloading.enter()
                    let movieData = movie.data()
                    let imageReference = Storage.storage().reference(forURL: movieData["Cover"] as! String)
                    
                    imageReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            // Uh-oh, an error occurred!
                            print("Couldn't get book images: \(error)")
                        } else {
                            // Data for "images/island.jpg" is returned
                            let image = UIImage(data: data!)
                            Items.sharedInstance.movieArray.append(Items.movie(actors: movieData["Actors"] as! [String], cover: image!, description: movieData["Description"] as! String, idmb: movieData["IMDB"] as! String, name: movie.documentID, nominatedFor: movieData["NominatedFor"] as! [String], youtube: movieData["Youtube"] as! String))
                            downloading.leave()
                        }
                    }
                }
                    
                downloading.notify(queue: .main) {
                    let sorting = DispatchGroup()
                    for _ in 0 ... 23 {
                        Items.sharedInstance.sortedMovieArray.append([Items.movie]())
                    }
                    for movie in Items.sharedInstance.movieArray {
                        sorting.enter()
                        for nomination in movie.nominatedFor {
                            switch nomination {
                            case "Best Picture":
                                Items.sharedInstance.sortedMovieArray[0].append(movie)
                            case "Best Actor":
                                Items.sharedInstance.sortedMovieArray[1].append(movie)
                            case "Best Actress":
                                Items.sharedInstance.sortedMovieArray[2].append(movie)
                            case "Supporting Actor":
                                Items.sharedInstance.sortedMovieArray[3].append(movie)
                            case "Supporting Actress":
                                Items.sharedInstance.sortedMovieArray[4].append(movie)
                            case "Animated":
                                Items.sharedInstance.sortedMovieArray[5].append(movie)
                            case "Cinematography":
                                Items.sharedInstance.sortedMovieArray[6].append(movie)
                            case "Costume Design":
                                Items.sharedInstance.sortedMovieArray[7].append(movie)
                            case "Directing":
                                Items.sharedInstance.sortedMovieArray[8].append(movie)
                            case "Documentary Feature":
                                Items.sharedInstance.sortedMovieArray[9].append(movie)
                            case "Documentary Short":
                                Items.sharedInstance.sortedMovieArray[10].append(movie)
                            case "Film Editing":
                                Items.sharedInstance.sortedMovieArray[11].append(movie)
                            case "Foreign Film":
                                Items.sharedInstance.sortedMovieArray[12].append(movie)
                            case "Makeup":
                                Items.sharedInstance.sortedMovieArray[13].append(movie)
                            case "Music Score":
                                print("Should not be in here")
                                Items.sharedInstance.sortedMovieArray[14].append(movie)
                            case "Music Song":
                                Items.sharedInstance.sortedMovieArray[15].append(movie)
                            case "Production Design":
                                Items.sharedInstance.sortedMovieArray[16].append(movie)
                            case "Animated Short":
                                Items.sharedInstance.sortedMovieArray[17].append(movie)
                            case "Live Action Short":
                                Items.sharedInstance.sortedMovieArray[18].append(movie)
                            case "Sound Editing":
                                Items.sharedInstance.sortedMovieArray[19].append(movie)
                            case "Sound Mixing":
                                Items.sharedInstance.sortedMovieArray[20].append(movie)
                            case "Visual Effects":
                                Items.sharedInstance.sortedMovieArray[21].append(movie)
                            case "Writing Adapted":
                                Items.sharedInstance.sortedMovieArray[22].append(movie)
                            case "Writing Original":
                                Items.sharedInstance.sortedMovieArray[23].append(movie)
                            default:
                                print("There was an error")
                            }
                        }
                        sorting.leave()
                    }
                    sorting.notify(queue: .main) {
                        self.performSegue(withIdentifier: "loadingSegue", sender: self)
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
