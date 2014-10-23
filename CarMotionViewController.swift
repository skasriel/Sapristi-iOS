//
//  CarMotionViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/8/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class CarMotionViewController: UIViewController {
    
    
    @IBAction func enableButtonPressed(sender: AnyObject) {
        CarManager.start(true)
        //self.navigationController!.popViewControllerAnimated(true)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
