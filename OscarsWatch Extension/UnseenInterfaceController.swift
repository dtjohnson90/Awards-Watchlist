//
//  UnseenInterfaceController.swift
//  OscarsWatch Extension
//
//  Created by Dustin Johnson on 1/31/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import WatchKit
import Foundation


class UnseenInterfaceController: WKInterfaceController {

    var moviesLeftList = [Items2.movie]()
    @IBOutlet var unseenTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        moviesLeftList = context as! [Items2.movie]
        self.unseenTable.setNumberOfRows(self.moviesLeftList.count, withRowType: "unseenRow")
        for index in 0..<self.moviesLeftList.count {
            guard let controller = self.unseenTable.rowController(at: index) as? UnseenRowController else { continue }
            controller.nameLabel.setText(self.moviesLeftList[index].name)
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        var movie: Items2.movie
        if table == unseenTable {
            for item in Items2.sharedInstance.movieArray {
                if item == moviesLeftList[rowIndex] {
                    movie = item
                    presentController(withName: "DetailController", context: movie)
                    break
                }
            }
        }
    }
}
