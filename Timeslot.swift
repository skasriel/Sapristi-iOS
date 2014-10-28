//
//  Timeslot.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/26/14.
//  Copyright (c) 2014 Sapristi. All rights reserved.
//

import Foundation

import EventKitUI

class Timeslot : NSObject {
    var startTime:      NSDate
    var endTime:        NSDate
    var availability:   Availability
    var recurrence:     String
    var source:         String
    
    init(startTime: NSDate, endTime: NSDate, availability: Availability, recurrence: String, source: String) {
        self.startTime = startTime
        self.endTime = endTime
        self.availability = availability
        self.recurrence = recurrence
        self.source = source
    }
    
    /**
    * Call this prior to converting to JSON because Swift doesn't have a way to serialize custom classes (lame)
    */
    func serialize() -> Dictionary<String, String> {
        var attributes: Dictionary<String, String>  = Dictionary()
        var formattedStartTime = NSDate.ISOStringFromDate(startTime)
        var formattedEndTime = NSDate.ISOStringFromDate(endTime)
        attributes["startTime"] = formattedStartTime
        attributes["endTime"] = formattedEndTime
        attributes["availability"] = availability.rawValue
        attributes["recurrence"] = recurrence
        attributes["source"] = source
        //println("Timeslot: \(formattedStartTime) - \(formattedEndTime)")
        return attributes
    }
    
    class func serialize(array: [Timeslot]) -> Array<Dictionary<String, String>> {
        var attributes: Array<Dictionary<String, String>> = []
        for (index, timeslot) in enumerate(array) {
            attributes.append(timeslot.serialize())
        }
        return attributes
    }
}

let RECURRENCE_WEEKDAYS = "12345"
let RECURRENCE_WEEKENDS = "60"

