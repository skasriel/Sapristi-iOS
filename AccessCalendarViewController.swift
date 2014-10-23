//
//  AccessCalendarViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/1/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class AccessCalendarViewController: UIViewController {

    @IBAction func enableButtonPressed(sender: AnyObject) {
        CalendarManager.start(true)
        //calendarManager = CalendarManager(requestPermissions: true)
        //self.navigationController!.popViewControllerAnimated(true)
        self.performSegueWithIdentifier("fromSetupToMain", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if "fromSetupToMain" == segue.identifier  {
            let tabVC = segue.destinationViewController as UITabBarController
            let selectedTab = ConfigManager.getIntConfigValue(CONFIG_SELECTED_TAB, defaultValue: 1)
            tabVC.selectedIndex = selectedTab
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
