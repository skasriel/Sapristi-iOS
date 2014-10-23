//
//  NotificationViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/22/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    
    @IBAction func enableButtonPressed(sender: AnyObject) {
        // Register for push notifications
        //TODO: This isn't the right place to do this, need to rethink the UI here
        let application = UIApplication.sharedApplication()
        
        var notificationActionOk: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        notificationActionOk.identifier = "ACCEPT_IDENTIFIER"
        notificationActionOk.title = "Call"
        notificationActionOk.destructive = false
        notificationActionOk.authenticationRequired = false
        notificationActionOk.activationMode = UIUserNotificationActivationMode.Background
        
        var notificationActionCancel: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        notificationActionCancel.identifier = "NOT_NOW_IDENTIFIER"
        notificationActionCancel.title = "Not Now"
        notificationActionCancel.destructive = true
        notificationActionCancel.authenticationRequired = false
        notificationActionCancel.activationMode = UIUserNotificationActivationMode.Background
        
        var notificationCategory: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        notificationCategory.identifier = "AVAILABILITY_CATEGORY"
        notificationCategory.setActions([notificationActionOk,notificationActionCancel], forContext: UIUserNotificationActionContext.Default)
        notificationCategory.setActions([notificationActionOk,notificationActionCancel], forContext: UIUserNotificationActionContext.Minimal)
        
        var types: UIUserNotificationType = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
        var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: NSSet(array:[notificationCategory]) )
        application.registerUserNotificationSettings( settings )
        application.registerForRemoteNotifications()
        
        self.performSegueWithIdentifier("fromNotificationsToCarMotion", sender: self)
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
