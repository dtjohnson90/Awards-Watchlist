//
//  ConfigurationModel.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/22/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit

class ConfigurationModel: NSObject {
    
    public static let storageKey = "group.com.johnsonapps.awardswatchlist"
    public let userStorage = UserDefaults(suiteName: storageKey)
    
    public var savedMovies: [String] {
        get {
            if userStorage?.object(forKey: "savedMovies") == nil {
                userStorage?.set([String](), forKey: "savedMovies")
                userStorage?.synchronize()
            }
            
            return userStorage?.object(forKey: "savedMovies") as! [String]
        }
        
        set {
            userStorage?.set(newValue, forKey: "savedMovies")
            userStorage?.synchronize()
        }
    }
}
