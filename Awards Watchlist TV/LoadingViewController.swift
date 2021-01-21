//
//  LoadingViewController.swift
//  Awards Watchlist TV
//
//  Created by Dustin Johnson on 10/19/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //myActivityView.startAnimating()

        // Do any additional setup after loading the view.
        
        let db = Firestore.firestore()
        
        db.collection("Settings").document("AppInformation").getDocument { (document, error) in
            if let error = error {
                //self.logError(logString: "Loading VC - Getting 'Is Updating'", logError: error.localizedDescription)
                //self.showError(errorString: error.localizedDescription)
                print(error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    print(document.data()!["listToUse"] as! String)
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
