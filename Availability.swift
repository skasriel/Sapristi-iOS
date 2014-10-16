//
//  Availability.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/14/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation


struct Availability {
    // Availabilty values (should change to enum?)
    static let AVAILABLE = "AVAILABLE"
    static let BUSY = "BUSY"
    static let UNKNOWN = "UNKNOWN"
    
    // Availability reasons (keep track of why the availability was set to a specific value
    static let USER = "USER"
    static let CAR_MOTION = "CAR_MOTION"
    static let TIMESLOT = "TIMESLOT"
    static let CALENDAR = "CALENDAR"
    
    static let SET_AVAILABILITY = "SET_AVAILABILITY"
}

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

}
