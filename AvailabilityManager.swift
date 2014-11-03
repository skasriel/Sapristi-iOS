//
//  AvailabilityManager.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/22/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation


let sharedAvailabilityInstance = AvailabilityManager()

class AvailabilityManager {
    var currentAvailability: Availability = Availability.Unknown
    var currentReason: Reason?
    
    class func getInstance() -> AvailabilityManager {
        return sharedAvailabilityInstance
    }
    
    init() {
    }
    
    func setAvailability(newAvailability: Availability, reason: Reason? = nil, updateServer: Bool = false, delegate: HTTPControllerProtocol? = nil) {
        currentAvailability = newAvailability
        currentReason = reason
        
        if updateServer {
            sendAvailabilityUpdateToServer(reason!, delegate: delegate!)
        }
    }
    
    func sendAvailabilityUpdateToServer(reason: Reason, delegate: HTTPControllerProtocol) {
        var params = [
            "availability": currentAvailability.rawValue,
            "reason": reason.rawValue
        ]
        HTTPController.getInstance().doPOST("/api/me/availability", parameters: params, delegate: delegate, queryID: SET_AVAILABILITY)
    }
    
    class func getAvailabilityFromString(string: String) -> Availability? {
        return Availability.allValues[string]
    }
    
    class func getReasonFromString(string: String?) -> Reason? {
        if string == nil {
            return nil
        }
        return Reason.allValues[string!]
    }
    
    func getReasonMessage() -> String? {
        if currentReason == nil {
            return nil
        }
        switch currentReason! {
        case Reason.User:
            return "Set by you"
        case Reason.CarMotion:
            if currentAvailability == Availability.Unknown {
                return "Because you're no longer driving"
            } else {
                return "Because you're driving"
            }
        case Reason.Timeslot:
            return "Because of your defined time slots"
        case Reason.Calendar:
            return "Based on an entry in your calendar"
        default:
            return nil
        }
    }
}
