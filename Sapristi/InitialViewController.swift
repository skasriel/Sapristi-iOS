//
//  InitialViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/15/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import UIKit

class InitialViewController: UIViewController, HTTPControllerProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let carMotionEnabled = ConfigManager.getBoolConfigValue(CONFIG_CAR_MOTION)
        if carMotionEnabled == true {
            CarManager.start(false)
        }

        let calendarEnabled = ConfigManager.getBoolConfigValue(CONFIG_CALENDAR)
        if calendarEnabled == true {
            CalendarManager.start(false)
        }
        
        runTests()
    }
    func runTests() {
    }
    
    /* HTTPControllerProtocol implementation */
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject?) {
        if let desc = err?.localizedDescription {
            println("Server error: \(desc)")
            self.performSegueWithIdentifier("fromLoadingToRegistration", sender: self)
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("fromLoadingToMain", sender: self)
        })
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if "fromLoadingToMain" == segue.identifier  {
            let tabVC = segue.destinationViewController as UITabBarController
            let selectedTab = ConfigManager.getIntConfigValue(CONFIG_SELECTED_TAB, defaultValue: 1)
            tabVC.selectedIndex = selectedTab
        }
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)        
        HTTPController.getInstance().doLogin(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var label: UILabel!
}