//
//  LoginViewController.swift
//  Awards Watchlist TV
//
//  Created by Dustin Johnson on 3/9/21.
//  Copyright © 2021 Dustin Johnson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //https://stackoverflow.com/questions/57710305/how-do-i-get-the-entered-pin-in-tvdigitentryviewcontrollers-completion-handler
    func addDigitEntryComponent() {
        let digitEntryViewController = TVDigitEntryViewController()
        digitEntryViewController.isSecureDigitEntry = true
        digitEntryViewController.view.backgroundColor = .gray
        digitEntryViewController.numberOfDigits = 4
        digitEntryViewController.titleText = "Login Pin"
        digitEntryViewController.promptText = "Please enter the 4 digit pin found in the iOS app"
        digitEntryViewController.entryCompletionHandler = { (enteredText) in
            // Text will be received here in variable "enteredText"
            print(enteredText)
        }
        self.addChild(digitEntryViewController)
        digitEntryViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(digitEntryViewController.view)

        digitEntryViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        digitEntryViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        digitEntryViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        digitEntryViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

        digitEntryViewController.didMove(toParent: self)
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
