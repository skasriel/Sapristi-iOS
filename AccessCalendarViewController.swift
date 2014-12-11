//
//  AccessCalendarViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/1/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class AccessCalendarViewController: SetupScreenViewController {

    @IBAction func enableButtonPressed(sender: AnyObject) {
        CalendarManager.start(true)
        ConfigManager.setBoolConfigValue(CONFIG_CALENDAR, newValue: true)
        // If we came from the settings screen we simply pop back to that screen instead of continuing
        // in the setup flow.
        var childControllers : [UIViewController] = self.navigationController?.childViewControllers as [UIViewController];
        if ((childControllers.count > 1) &&
            childControllers[0].isKindOfClass(SettingsViewController)) {
                self.navigationController?.popViewControllerAnimated(true)
                return
        }
        
        var mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var nextVC:UITabBarController = mainStoryboard.instantiateInitialViewController() as UITabBarController
        self.navigationController?.presentViewController(nextVC, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if "fromSetupToMain" == segue.identifier  {
            let tabVC = segue.destinationViewController as UITabBarController
            let selectedTab = ConfigManager.getIntConfigValue(CONFIG_SELECTED_TAB, defaultValue: 1)
            tabVC.selectedIndex = selectedTab
        }
        
        super.prepareForSegue(segue, sender: sender)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
