//
//  userMovieList.swift
//  Oscars
//
//  Created by Dustin Johnson on 12/13/17.
//  Copyright © 2017 Dustin Johnson. All rights reserved.
//

import Foundation
import UIKit

class Items {
    static let sharedInstance = Items()
    
    struct actorData: Equatable{
        let name: String
        let id: String
    }
    
    struct movie: Equatable {
        let actors: [actorData]
        let cover: UIImage
        let description: String
        let idmb: String
        let name: String
        let nominatedFor: [String]
        let youtube: String
        let id: String
        let originalLanguage: String
        let releaseDate: String
        let runTime: Int
        let revenue: Int
        let budget: Int
    }
    
    struct actors: Equatable {
        let name: String
        let image: UIImage
        let nominatedFor: String
        var movie: String
        //var used: Bool
    }
    
    let updateKey = "3.0-2"
    var userMovieListYear = String()
    var movieList = String()
    var movieArray = [movie]()
    var sortedMovieArray = [[movie]]()
    var moviesSeenArray = [movie]()
    var actorArray = [actors]()
    var predictions = [String]()
    var loggedIn = String()
    var dataCleared = Bool()
    var purchased = Bool()
    var profilePic = UIImage(named: "profilePic")
    var notificationToken = String()
    var winners = [String]()
    var winnerYear = String()
}
