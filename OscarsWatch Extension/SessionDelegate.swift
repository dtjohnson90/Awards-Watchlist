//
//  SessionDelegate.swift
//  OscarsWatch Extension
//
//  Created by Dustin Johnson on 10/22/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol DataObserver {
    func dataDidChange(data: Any)
}

class SessionDelegate {
    static let sharedDelegate = SessionDelegate()
    
    private var observers = [DataObserver]()
    
    func addObserver(observer: DataObserver){
    }
    
    func removeObserver(observer: DataObserver) {
    }
    
    func dataDidChange(data: Any) {
    }
    
    func didReceiveData(data: Any) {
        for observer in observers {
            observer.dataDidChange(data: data)
        }
    }
}

extension ExtensionDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        SessionDelegate.sharedDelegate.dataDidChange(data: applicationContext)
    }
}
