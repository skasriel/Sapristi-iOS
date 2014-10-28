
//
//  CalendarManager.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/30/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import EventKitUI

func cm_alert(msg: String) {
    /*let alert = UIAlertView(title: "Debug", message: msg,
    delegate: nil, cancelButtonTitle: "OK")
    alert.show()*/
    println(msg)
}



var calendarManagerInstance: CalendarManager?

class CalendarManager : HTTPControllerProtocol {
    var eventStore: EKEventStore!
    
    class func start(requestPermissions: Bool) -> CalendarManager {
        if calendarManagerInstance == nil {
            calendarManagerInstance = CalendarManager(requestPermissions: requestPermissions)
        }
        return calendarManagerInstance!
    }
    
    class func stop() {
        // TBD
    }

    init(requestPermissions: Bool) {
        loadFromCalendar(requestPermissions)
    }
    
    
    
    func getEventStore(requestPermissions: Bool, completed: (EKEventStore) -> ()) {
        if eventStore != nil {
            completed(eventStore)
            return
        }
        
        eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
        case .NotDetermined:
            if (!requestPermissions) {
                return
            }
            eventStore.requestAccessToEntityType(EKEntityTypeEvent) {
                (granted: Bool, err: NSError?) in
                if granted && (err == nil) {
                    completed(self.eventStore)
                } else {
                    self.eventStore = nil
                    HTTPController.sendUserToSettings()
                }
            }
        case .Authorized:
            completed(eventStore)
        default:
            eventStore = nil
            if (!requestPermissions) {
                return;
            }
            HTTPController.sendUserToSettings()
        }
    }
    
    func loadFromCalendar(requestPermissions: Bool) {
        getEventStore(requestPermissions) { eventStore in // horrible swift closure syntax...
            var startDate = NSDate().dateByAddingTimeInterval(60*60*24*(-1))
            var endDate = NSDate().dateByAddingTimeInterval(60*60*24*7) // 7 days in the future
            var calPredicate: NSPredicate = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: nil)
            cm_alert("Searching for calendar events with dates between \(startDate) and \(endDate)")
            var events = eventStore.eventsMatchingPredicate(calPredicate)
            if (events == nil) {
                cm_alert("No events in calendar, returning")
                return
            }
            cm_alert("found \(countElements(events)) calendar entries")
            
            var timeslots = Array<Timeslot>()
            for (index, eventObj) in enumerate(events) {
                let event: EKEvent = eventObj as EKEvent
                let title = event.title
                var sapristiAvailability: Availability
                if (title.toLowerCase().indexOf("sapristi") >= 0) {
                    sapristiAvailability = Availability.Available
                } else if (event.availability.value != EKEventAvailabilityFree.value) {
                    sapristiAvailability = Availability.Busy
                } else {
                    continue // a "free" event in your calendar is like not having an event at all - we mark the user neither as busy nor as available, we just don't know
                }
                let eventStart = event.startDate
                let eventEnd = event.endDate
                let allDay = event.allDay
                cm_alert("Calendar entry: \(title) \(eventStart) \(eventEnd) \(sapristiAvailability) \(allDay) \(NSDate.ISOStringFromDate(eventStart))")
                var timeslot = Timeslot(startTime: eventStart, endTime: eventEnd, availability: sapristiAvailability, recurrence: "", source: "CALENDAR")
                timeslots.append(timeslot)
            }
            
            CalendarManager.submitTimeSlotsToServer(timeslots, delegate: self)
        }
    }
    
    class func submitTimeSlotsToServer(timeslots: [Timeslot], delegate: HTTPControllerProtocol) {
        let json = HTTPController.JSONStringify(Timeslot.serialize(timeslots))
        if (json == "") {
            cm_alert("Unable to JSON timeslots")
            return
        }
        let httpParams = ["json": json]
        let url = "/api/settings/timeslots"
        //let url = "/api/settings/calendar"
        HTTPController.getInstance().doPOST(url, parameters: httpParams, delegate: delegate, queryID: "UPLOAD_CALENDAR")
    }
    
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject? /*NSDictionary?*/) {
        cm_alert("TBD")
    }

}