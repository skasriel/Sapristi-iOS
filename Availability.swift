//
//  Availability.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/14/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation

/**
 * Reason codes indicating why the user is shown with a specific availability
 */
enum Reason : String {
    case User = "USER",
    CarMotion = "CAR_MOTION",
    Timeslot = "TIMESLOT",
    Calendar = "CALENDAR"
    
    static let allValues = [User.rawValue: User, CarMotion.rawValue: CarMotion, Timeslot.rawValue: Timeslot, Calendar.rawValue: Calendar]
}

enum Availability : String {
    case Available = "AVAILABLE",
    Busy = "BUSY",
    Unknown = "UNKNOWN"
    static let allValues = [Available.rawValue: Available, Busy.rawValue: Busy, Unknown.rawValue: Unknown]
}

let SET_AVAILABILITY = "SET_AVAILABILITY"

//typealias ReasonType = String
//typealias AvailabilityType = String

/*struct Availability {
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
}*/
