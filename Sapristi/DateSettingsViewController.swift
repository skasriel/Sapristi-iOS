//
//  DateSettingsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/26/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import UIKit

class DateSettingsViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, HTTPControllerProtocol {
    
    @IBOutlet var allDatesTableView: UITableView!
    
    var tableDatas = [
        ["title" : "Morning - Start At", "type": "datepicker"],
        ["title" : "Morning - End At",   "type": "datepicker"],
        ["title" : "Afternoon - Start At", "type": "datepicker"],
        ["title" : "Afternoon - End At", "type": "datepicker"],
        ["title" : "Morning - Start At", "type": "datepicker"],
        ["title" : "Morning - End At", "type": "datepicker"],
        ["title" : "Afternoon - Start At", "type": "datepicker"],
        ["title" : "Afternoon - End At", "type": "datepicker"]
    ]

    let dateCellID = "datePickerCell"
    let regularCellID = "titleDetailCell"
    
    var selectedIndexPath :NSIndexPath? // the table cell that is selected (to show the date picker), if any

    var dates = Array<Array<NSDate>>() // [section][row] where section in {weekend, weekday} and row in {start1, end1, start2, end2}
    var dateFormatter: NSDateFormatter?
    
    let rowLabels: [String] = ["Start at", "End at"]
    let sectionLabels: [String] = ["Week days", "Weekends"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter = NSDateFormatter()
        dateFormatter!.dateStyle = .NoStyle
        dateFormatter!.dateFormat = "hh:mm a"


        var gregorian: NSCalendar = NSCalendar.currentCalendar() // NSCalendar(NSCalendarIdentifierGregorian)
        var components = NSDateComponents()

        var defaultDates = Array<Array<NSDate>>()
        var weekdayArray = Array<NSDate>()
        components.hour = 8
        components.minute = 30
        weekdayArray.append(gregorian.dateFromComponents(components)!)

        components.hour = 9
        components.minute = 0
        weekdayArray.append(gregorian.dateFromComponents(components)!)
        
        components.hour = 14
        components.minute = 30
        weekdayArray.append(gregorian.dateFromComponents(components)!)
        
        components.hour = 15
        components.minute = 0
        weekdayArray.append(gregorian.dateFromComponents(components)!)

        defaultDates.append(weekdayArray);

        var weekendArray = Array<NSDate>()
        components.hour = 10
        components.minute = 30
        weekendArray.append(gregorian.dateFromComponents(components)!)
        
        components.hour = 12
        components.minute = 0
        weekendArray.append(gregorian.dateFromComponents(components)!)
        
        components.hour = 18
        components.minute = 30
        weekendArray.append(gregorian.dateFromComponents(components)!)
        
        components.hour = 21
        components.minute = 0
        weekendArray.append(gregorian.dateFromComponents(components)!)
        
        defaultDates.append(weekendArray)
       
        // load from stored config, but use default if no config is stored
        let userDefaults = NSUserDefaults.standardUserDefaults();
        for section in 0...1 {
            var rowData = Array<NSDate>()
            for row in 0...3 {
                var config: NSString? = userDefaults.objectForKey("date[\(section)][\(row)]") as NSString?
                if (config == nil) {
                    rowData.append(defaultDates[section][row])
                } else {
                    println("Config date value = \(config!)")
                    rowData.append(dateFormatter!.dateFromString(config!)!)
                }
            }
            dates.append(rowData)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject? /*NSDictionary?*/) {
        println("TBD")
        //self.navigationController!.popViewControllerAnimated(true)
    }
    
   
    
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        var timeslots = [Timeslot]() //[String: AnyObject] = Dictionary() // Dictionary<String, AnyObject>] = [];

        
        let userDefaults = NSUserDefaults.standardUserDefaults();
        
        for (section, sectionData) in enumerate(dates) { // weekdays, weekends
            
            for (row, date) in enumerate(sectionData) { // save to local settings
                var formattedDate: NSString = dateFormatter!.stringFromDate(date)
                var key = "date[\(section)][\(row)]"
                userDefaults.setObject(formattedDate, forKey: key)
            }
            
            // now send to server
            var recurrence: String
            if (section==0) {
                recurrence = RECURRENCE_WEEKDAYS // "12345" // Mon-Fri
            } else {
                recurrence = RECURRENCE_WEEKENDS // "60" // Sat-Sun
            }
            for i in 0...1 {
                let startTime = sectionData[i*2]
                let endTime = sectionData[i*2+1]
                var timeslot = Timeslot(startTime: startTime, endTime: endTime,
                    availability: Availability.Available, recurrence: recurrence, source: "USER_TIMESLOTS")
                timeslots.append(timeslot)
            }
        }
        
        
        CalendarManager.submitTimeSlotsToServer(timeslots, delegate: self)
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    /* UITableViewDelegate implementation */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var dataSection = indexPath.section
        var dataRow = indexPath.row
        if selectedIndexPath != nil && selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row < indexPath.row {
            dataRow -= 1
        }
        
        var rowData = tableDatas[dataSection * countElements(dates[0]) + dataRow]
        var type = rowData["type"]! as String
        if type != "normal" {
            displayOrHideInlinePickerViewForIndexPath(indexPath);
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
    /**
    * UITableViewDataSource implementation
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 // weekend and week days
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        var numRows = 4
        if hasInlineTableViewCell(numberOfRowsInSection) {
            numRows += 1
        }
        return numRows // start time & end time for that section
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionLabels[section]
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var heightForRow :CGFloat = 44.0
        if selectedIndexPath != nil
            && selectedIndexPath!.section == indexPath.section
            && selectedIndexPath!.row == indexPath.row - 1 {
                heightForRow = 216.0
        }
        
        return heightForRow
    }


    //    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return "Test footer"
//    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle: String, atIndex: Int) -> Int {
        return 0 // TBD
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath: NSIndexPath) -> UITableViewCell {
        var dataSection = cellForRowAtIndexPath.section
        var dataRow = cellForRowAtIndexPath.row
        
        if selectedIndexPath != nil && selectedIndexPath!.section == cellForRowAtIndexPath.section && selectedIndexPath!.row < cellForRowAtIndexPath.row {
            dataRow -= 1;
        }
        
        // Configure the cell...
        var rowData = tableDatas[dataSection * countElements(dates[0]) + dataRow]
        let title = rowData["title"]! as String
        let type = rowData["type"]! as String
        if selectedIndexPath != nil && selectedIndexPath!.section == cellForRowAtIndexPath.section && selectedIndexPath!.row == cellForRowAtIndexPath.row - 1 {
            if type == "datepicker" {
                let datePickerCell = tableView.dequeueReusableCellWithIdentifier(dateCellID, forIndexPath: cellForRowAtIndexPath) as DatePickerCell
                
                datePickerCell.datePicker.addTarget(self, action:"handleDatePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
                datePickerCell.datePicker.datePickerMode = .Time
                datePickerCell.datePicker.setDate(dates[dataSection][dataRow] as NSDate, animated: true)
                return datePickerCell
            } else {
                println("Shouldn't happen?")
            }
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(regularCellID, forIndexPath: cellForRowAtIndexPath) as UITableViewCell
        
        
        cell.textLabel!.text = title
        let valueOfRow = dates[dataSection][dataRow]
        cell.detailTextLabel!.text = dateFormatter!.stringFromDate(valueOfRow as NSDate)
        return cell
        
//        var cell = tableView.dequeueReusableCellWithIdentifier(dateCellID) as DatePickerCell
//        var date = dates[cellForRowAtIndexPath.section][cellForRowAtIndexPath.row]
//        cell.datePicker.setDate(date, animated: true)
//        cell.label.text = rowLabels[cellForRowAtIndexPath.row % countElements(rowLabels)]
//        cell.delegate = self
//        return cell
    }
    
    
    func displayOrHideInlinePickerViewForIndexPath(indexPath: NSIndexPath!) {
        tableView.beginUpdates()
        
        if selectedIndexPath == nil {
            selectedIndexPath = indexPath
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)], withRowAnimation: .Fade)
        } else if selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row == indexPath.row {
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)], withRowAnimation: .Fade)
            selectedIndexPath = nil
        } else if selectedIndexPath!.section != indexPath.section || selectedIndexPath!.row != indexPath.row {
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: selectedIndexPath!.row + 1, inSection: selectedIndexPath!.section)], withRowAnimation: .Fade)
            // After the deletion operation the then indexPath of original table view changed to the resulting table view
            if (selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row < indexPath.row) {
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)], withRowAnimation: .Fade)
                selectedIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
            } else {
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)], withRowAnimation: .Fade)
                selectedIndexPath = indexPath
            }
        }
        tableView.endUpdates()
    }

    func hasInlineTableViewCell(section: Int) -> Bool {
        if (selectedIndexPath==nil) {
            return false
        }
        return (selectedIndexPath!.section == section)
        //!(self.selectedIndexPath == nil)
    }
    
    func handleDatePickerValueChanged(datePicker: UIDatePicker!) {
        var index = selectedIndexPath!.section * countElements(dates[0]) + selectedIndexPath!.row
        println("Changing: \(selectedIndexPath) + -> \(index)")
        var rowData = tableDatas[index]
        //rowData["value"] = datePicker.date
        dates[selectedIndexPath!.section][selectedIndexPath!.row] = datePicker.date
        
        var tmpArray = tableDatas
        tmpArray[index] = rowData
        tableDatas = tmpArray
        
        tableView.reloadRowsAtIndexPaths([selectedIndexPath!], withRowAnimation: .Fade)
        
    }
}