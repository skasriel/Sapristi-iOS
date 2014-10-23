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
    var currentAvailability: String = Availability.UNKNOWN
    var currentReason: String?
    
    class func getInstance() -> AvailabilityManager {
        return sharedAvailabilityInstance
    }
    
    init() {
    }
    
    func setAvailability(newAvailability: String, updateServer: Bool = false, reason: String? = nil, delegate: HTTPControllerProtocol? = nil) {
        currentAvailability = newAvailability
        currentReason = reason
        
        if updateServer {
            sendAvailabilityUpdateToServer(reason!, delegate: delegate!)
        }
    }
    
    func sendAvailabilityUpdateToServer(reason: String, delegate: HTTPControllerProtocol) {
        var params = [
            "availability": currentAvailability,
            "reason": reason
        ]
        HTTPController.getInstance().doPOST("/api/me/availability", parameters: params, delegate: delegate, queryID: Availability.SET_AVAILABILITY)
    }
    
    func getReason() -> String? {
        if currentReason == nil {
            return nil
        }
        switch currentReason! {
        case Availability.USER:
            return "Set by you"
        case Availability.CAR_MOTION:
            return "Because you're driving"
        case Availability.TIMESLOT:
            return "During your defined time slots"
        case Availability.CALENDAR:
            return "Based on the entry in your calendar"
        default:
            return nil
        }
    }
    
}
