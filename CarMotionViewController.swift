//
//  CarMotionViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/8/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class CarMotionViewController: SetupScreenViewController {
    
    
    @IBAction func enableButtonPressed(sender: AnyObject) {
        CarManager.start(true)
        //self.navigationController!.popViewControllerAnimated(true)
        ConfigManager.setBoolConfigValue(CONFIG_CAR_MOTION, newValue: true)
        
        // If we came from the settings screen we simply pop back to that screen instead of continuing 
        // in the setup flow.
        var childControllers : [UIViewController] = self.navigationController?.childViewControllers as [UIViewController];
        if ((childControllers.count > 1) &&
            childControllers[0].isKindOfClass(SettingsViewController)) {
                self.navigationController?.popViewControllerAnimated(true)
                return
        }
        self.performSegueWithIdentifier("fromCarMotionToCalendar", sender: self)
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
