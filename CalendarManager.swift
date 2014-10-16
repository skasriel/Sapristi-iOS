//
//  CalendarManager.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/30/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import EventKitUI

class Timeslot : NSObject {
    var startTime:      NSDate
    var endTime:        NSDate
    var availability:   String
    var recurrence:     String
    var source:         String
    
    init(startTime: NSDate, endTime: NSDate, availability: String, recurrence: String, source: String) {
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
        attributes["availability"] = availability
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

var calendarManagerInstance: CalendarManager?

class CalendarManager : HTTPControllerProtocol {
    var estore: EKEventStore!
    
    init(requestPermissions: Bool) {
        loadFromCalendar(requestPermissions)
    }
    
    
    class func start(requestPermissions: Bool) -> CalendarManager {
        if calendarManagerInstance == nil {
            calendarManagerInstance = CalendarManager(requestPermissions: requestPermissions)
        }
        return calendarManagerInstance!
    }
    
    class func stop() {
        // TBD
    }
    
    func get_estore(requestPermissions: Bool, completed: (EKEventStore) -> ()) {
        if estore != nil {
            completed(estore)
            return
        }
        
        estore = EKEventStore()
        
        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
        case .NotDetermined:
            if (!requestPermissions) {
                return
            }
            estore.requestAccessToEntityType(EKEntityTypeEvent) {
                (granted: Bool, err: NSError?) in
                if granted && (err == nil) {
                    completed(self.estore)
                } else {
                    self.estore = nil
                    HTTPController.sendUserToSettings()
                }
            }
        case .Authorized:
            completed(estore)
        default:
            estore = nil
            if (!requestPermissions) {
                return;
            }
            HTTPController.sendUserToSettings()
        }
    }
    
    
    func loadFromCalendar(requestPermissions: Bool) {
        get_estore(requestPermissions) { estore in
            var startDate = NSDate().dateByAddingTimeInterval(60*60*24*(-1))
            var endDate = NSDate().dateByAddingTimeInterval(60*60*24*7) // 7 days in the future
            var calPredicate: NSPredicate = estore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: nil)
            //println("look at dates between \(startDate) and \(endDate)")
            var events = estore.eventsMatchingPredicate(calPredicate)
            if (events == nil) {
                println("No events in calendar, returning")
                return
            }
            //println("found \(countElements(events)) calendar entries")
            
            var timeslots = Array<Timeslot>() //Array<Dictionary<String, String>>()
            for (index, eventObj) in enumerate(events) {
                let event: EKEvent = eventObj as EKEvent
                let title = event.title
                var sapristiAvailability: String
                if (title.toLowerCase().indexOf("sapristi") >= 0) {
                    sapristiAvailability = Availability.AVAILABLE
                } else if (event.availability.value != EKEventAvailabilityFree.value) {
                    sapristiAvailability = Availability.BUSY
                } else {
                    continue // a "free" event in your calendar is like not having an event at all - we mark the user neither as busy nor as available, we just don't know
                }
                let eventStart = event.startDate
                let eventEnd = event.endDate
                let allDay = event.allDay
                //println("Calendar entry: \(title) \(eventStart) \(eventEnd) \(sapristiAvailability) \(allDay) \(NSDate.ISOStringFromDate(eventStart))")
                var timeslot = Timeslot(startTime: eventStart, endTime: eventEnd, availability: sapristiAvailability, recurrence: "", source: "CALENDAR")
                timeslots.append(timeslot)
            }
            
            CalendarManager.submitTimeSlotsToServer(timeslots, delegate: self)
        }
    }
    
    class func submitTimeSlotsToServer(timeslots: [Timeslot], delegate: HTTPControllerProtocol) {
        let json = HTTPController.JSONStringify(Timeslot.serialize(timeslots))
        if (json == "") {
            println("Unable to JSON timeslots")
            return
        }
        let httpParams = ["json": json]
        let url = "/api/settings/timeslots"
        //let url = "/api/settings/calendar"
        HTTPController.getInstance().doPOST(url, parameters: httpParams, delegate: delegate, queryID: "UPLOAD_CALENDAR")
    }
    
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject? /*NSDictionary?*/) {
        println("TBD")
    }

}