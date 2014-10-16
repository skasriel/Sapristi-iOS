//
//  ConfigManager.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/8/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import UIKit

let CONFIG_TIMESLOT = "timeslotEnabled"
let CONFIG_CALENDAR = "calendarEnabled"
let CONFIG_CAR_MOTION = "carMotionEnabled"
let CONFIG_USERNAME = "username"
let CONFIG_PWD = "authToken"
let CONFIG_SELECTED_TAB = "selectedTab"


class ConfigManager {
    
    class func getIntConfigValue(key: String, defaultValue: Int) -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        let value = userDefaults.objectForKey(key) as Int?
        if (value == nil) {
            return defaultValue
        }
        return value! as Int
    }
    class func setIntConfigValue(key: String, newValue: Int) {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        userDefaults.setObject(newValue, forKey: key)
        userDefaults.synchronize()
    }
    
    class func getBoolConfigValue(key: String) -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        let value = userDefaults.objectForKey(key) as Bool?
        if (value == nil) {
            return false
        }
        return value! as Bool
    }
    
    class func setBoolConfigValue(key: String, newValue: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        userDefaults.setObject(newValue, forKey: key)
        userDefaults.synchronize()
    }
    
    class func showButton(button: UIButton, isChecked: Bool) {
        if (isChecked) {
            button.setImage(UIImage(named: "Checkbox_checked"), forState: UIControlState.Normal)
        } else {
            button.setImage(UIImage(named: "Checkbox_unchecked"), forState: UIControlState.Normal)
        }
    }

    class func doLogout() {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        userDefaults.removeObjectForKey(CONFIG_USERNAME)
        userDefaults.removeObjectForKey(CONFIG_PWD)
        userDefaults.synchronize()
        // TODO: Other values to delete here? Clear CoreData?
    }
}