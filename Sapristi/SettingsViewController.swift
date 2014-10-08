//
//  SettingsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/12/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit



class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var logoutTableViewCell: UITableViewCell!
                            
    @IBOutlet weak var timeslotButton: UIButton!
    @IBOutlet weak var carMotionButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    
    var timeslotEnabled: Bool = false
    var carMotionEnabled: Bool = false
    var calendarEnabled: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeslotEnabled = ConfigManager.getBoolConfigValue(CONFIG_TIMESLOT)
        ConfigManager.showButton(timeslotButton, isChecked: timeslotEnabled)

        carMotionEnabled = ConfigManager.getBoolConfigValue(CONFIG_CALENDAR)
        ConfigManager.showButton(carMotionButton, isChecked: carMotionEnabled)

        calendarEnabled = ConfigManager.getBoolConfigValue(CONFIG_CAR_MOTION)
        ConfigManager.showButton(calendarButton, isChecked: calendarEnabled)
    }
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (sender as NSObject! == logoutTableViewCell) {
            println("Logout!")
            ConfigManager.doLogout()
            HTTPController.getInstance().doGET("/api/auth/logout", delegate: nil, queryID: nil)
        }
        println("prepareForSegue: \(sender) \(segue)")
    }
    
    
    @IBAction func timeslotButtonPressed(sender: AnyObject) {
        timeslotEnabled = !timeslotEnabled
        ConfigManager.setBoolConfigValue(CONFIG_TIMESLOT, newValue: timeslotEnabled)
        ConfigManager.showButton(timeslotButton, isChecked: timeslotEnabled)
        if timeslotEnabled {
            self.performSegueWithIdentifier("fromSettingsToTimeslot", sender: self)
        }
    }
    
    

    @IBAction func carMotionButtonPressed(sender: AnyObject) {
        carMotionEnabled = !carMotionEnabled
        ConfigManager.setBoolConfigValue(CONFIG_CAR_MOTION, newValue: carMotionEnabled)
        ConfigManager.showButton(carMotionButton, isChecked: carMotionEnabled)
        if carMotionEnabled {
            self.performSegueWithIdentifier("fromSettingsToCarMotion", sender: self)
        }

    }

    @IBAction func calendarButoonPressed(sender: AnyObject) {
        calendarEnabled = !calendarEnabled
        ConfigManager.setBoolConfigValue(CONFIG_CALENDAR, newValue: calendarEnabled)
        ConfigManager.showButton(calendarButton, isChecked: calendarEnabled)
        if calendarEnabled {
            self.performSegueWithIdentifier("fromSettingsToCalendar", sender: self)
        }
    }

}

