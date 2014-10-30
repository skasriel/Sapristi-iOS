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
enum Reason : String { // see user.js
    case User = "USER",
    CarMotion = "CAR_MOTION",
    Timeslot = "TIMESLOT",
    Calendar = "CALENDAR"
    
    static let allValues = [User.rawValue: User, CarMotion.rawValue: CarMotion, Timeslot.rawValue: Timeslot, Calendar.rawValue: Calendar]
}

enum Availability : String { // see user.js
    case Available = "AVAILABLE",
    Busy = "BUSY",
    Unknown = "UNKNOWN"
    static let allValues = [Available.rawValue: Available, Busy.rawValue: Busy, Unknown.rawValue: Unknown]
}

let SET_AVAILABILITY = "SET_AVAILABILITY"
