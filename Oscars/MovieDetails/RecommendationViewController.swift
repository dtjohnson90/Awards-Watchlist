//
//  RecommendationViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 2/27/19.
//  Copyright © 2019 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RecommendationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var recommendationCollection: UICollectionView!
    
    var movieSelected = String()
    var nominationList = [[String]]()
    let images = ["iTunes","amazon","youtube","vudu","googlePlay","netflix","hulu","theatre","hbo","recommendation"]
    let labels = ["iTunes","Amazon","Youtube","Vudu","Google","Netflix","Hulu","Theatre","HBO","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendationCell", for: indexPath) as! RecommendationCollectionViewCell
        
        cell.recommendationImage.image = UIImage(named: images[indexPath.item])
        cell.recommendationLabel.text = labels[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == labels.count - 1 {
            let alert = UIAlertController(title: "Link", message: "Enter the company that is offering this movie", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                //textField.text = "Some default text"
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            }))
            
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
                let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
                self.uploadItem(link: textField.text!, indexPath: indexPath.item)
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            uploadItem(link: labels[indexPath.item], indexPath: indexPath.item)
        }
    }
    
    func uploadItem(link: String, indexPath: Int) {
        var nomAvailable = false
        for nom in nominationList {
            if nom[0] == link {
                nomAvailable = true
            }
        }
        
        if nomAvailable {
            logError(logString: "Recommendation VC - Attempted to add link for \(movieSelected) on \(labels[indexPath]) but the link is already available")
            let alert = UIAlertController(title: "Duplicate", message: "This movie already has a link for \(labels[indexPath])", preferredStyle: .alert)
            
            let okAlert = UIAlertAction(title: "Ok", style: .default, handler: { action in
            })
            
            alert.addAction(okAlert)
            self.present(alert, animated: true)
        } else {
            Firestore.firestore().collection("Recommendations").addDocument(data: [
                "Movie": movieSelected,
                "Link": link,
                "Date": Date(),
                "User": Items.sharedInstance.loggedIn
            ]) { err in
                if let err = err {
                    self.logError(logString: "Recommendation VC - Error creating document for movie \(self.movieSelected) link \(self.labels[indexPath])", logError: err.localizedDescription)
                    let alert = UIAlertController(title: "Error", message: "Your recommendation was unable to be saved. Please try again", preferredStyle: .alert)
                    
                    let okAlert = UIAlertAction(title: "Ok", style: .default, handler: { action in
                    })
                    
                    alert.addAction(okAlert)
                    self.present(alert, animated: true)
                } else {
                    self.logError(logString: "Recommendation VC - Succesfully created document for movie \(self.movieSelected) and recommendation \(self.labels[indexPath])")
                    let alert = UIAlertController(title: "Recommendation Added", message: "Thank you for recommending this link! The developer will review it and add it if possible", preferredStyle: .alert)
                    
                    let okAlert = UIAlertAction(title: "Ok", style: .default, handler: { action in
                        self.performSegue(withIdentifier: "returnSegue", sender: self)
                    })
                    
                    alert.addAction(okAlert)
                    self.present(alert, animated: true)
                }
            }
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
