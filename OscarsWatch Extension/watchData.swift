//
//  watchData.swift
//  OscarsWatch Extension
//
//  Created by Dustin Johnson on 1/31/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import Foundation
import UIKit

class Items2 {
    static let sharedInstance = Items2()
    
    struct movie: Equatable {
        let actors: [String]
        let description: String
        let name: String
        let nominatedFor: [String]
    }
    
    struct actors: Equatable {
        let name: String
        let nominatedFor: String
        var movie: String
    }
    
    var movieArray = [movie]()
    var sortedMovieArray = [[movie]]()
    var moviesSeenArray = [movie]()
    var actorArray = [actors]()
}
