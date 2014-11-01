//
//  NotificationCenterManager.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/29/14.
//  Copyright (c) 2014 Sapristi. All rights reserved.
//

import Foundation

let NotificationCenterAvailability = "availability"

class NotificationCenterManager {
    private var observerTokens: [AnyObject] = []
    
    deinit {
        deregisterAll()
    }
    
    func deregisterAll() {
        for token in observerTokens {
            NSNotificationCenter.defaultCenter().removeObserver(token)
        }
        
        observerTokens = []
    }
    
    func registerObserver(name: String!, block: (NSNotification! -> ()?)) {
        let newToken = NSNotificationCenter.defaultCenter().addObserverForName(name, object: nil, queue: nil) {note in
            block(note)
            ()
        }
        
        observerTokens.append(newToken)
    }
    
    func registerObserver(name: String!, forObject object: AnyObject!, block: (NSNotification! -> ()?)) {
        let newToken = NSNotificationCenter.defaultCenter().addObserverForName(name, object: object, queue: nil) {note in
            block(note)
            ()
        }
        
        observerTokens.append(newToken)
    }
    
    class func postNotificationName(name: String, object: AnyObject?, userInfo: [NSObject : AnyObject]?) {
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: object, userInfo: userInfo)
    }
}