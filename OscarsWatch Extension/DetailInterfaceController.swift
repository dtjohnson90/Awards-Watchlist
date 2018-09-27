//
//  DetailInterfaceController.swift
//  OscarsWatch Extension
//
//  Created by Dustin Johnson on 1/31/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import WatchKit
import Foundation


class DetailInterfaceController: WKInterfaceController {

    @IBOutlet var nominationsLabel: WKInterfaceLabel!
    @IBOutlet var castLabel: WKInterfaceLabel!
    @IBOutlet var descriptionLabel: WKInterfaceLabel!
    @IBOutlet var nameLabel: WKInterfaceLabel!
    var movie = [String]()
    @IBOutlet var seenButton: WKInterfaceButton!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        movie = context as! [String]
        nameLabel.setText(movie[0])
        descriptionLabel.setText(movie[1])
        castLabel.setText(movie[2])
        nominationsLabel.setText(movie[3])
        if movie[4] == "Seen" {
            seenButton.setTitle("Seen")
            seenButton.setBackgroundColor(UIColor.green)
        }else {
            seenButton.setTitle("Unseen")
            seenButton.setBackgroundColor(UIColor.red)
        }
    }
    
    /*
    @IBAction func seenButtonClicked() {
        if movie[4] == "Seen"{
            seenButton.setTitle("Unseen")
            seenButton.setBackgroundColor(UIColor.red)
        } else {
            seenButton.setTitle("Seen")
            seenButton.setBackgroundColor(UIColor.green)
        }
    }
    */

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
