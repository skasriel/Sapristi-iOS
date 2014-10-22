 //
//  AppDelegate.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/12/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, HTTPControllerProtocol {
                            
    var window: UIWindow?


    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        // Override point for customization after application launch.
        if launchOptions == nil {
            return true
        }
        var notification: [NSObject : AnyObject]? = launchOptions.objectForKey(UIApplicationLaunchOptionsRemoteNotificationKey) as [NSObject : AnyObject]?
        if notification != nil {
            NSLog("app recieved notification from remote \(notification)")
            handleRemoteNotification(notification!)
            return true
        }
        NSLog("app did not recieve notification")
        return true
    }
    
    // Open the app and show the friend details page for the correct friend
    // TODO: right now this works if the app was running in the background but not if it's terminated. Not sure why and hard to debug since Xcode is no longer attached at that point...
    func handleRemoteNotification(userInfo: [NSObject: AnyObject]) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabbedViewController = mainStoryboard.instantiateViewControllerWithIdentifier("tabController") as UITabBarController
        tabbedViewController.selectedIndex = 1 // All Contacts
        self.window!.rootViewController = tabbedViewController
        
        let friendDetailsViewController = mainStoryboard.instantiateViewControllerWithIdentifier("friendDetail") as FriendDetailViewController
        let username = userInfo["username"] as String
        let friendLocalDatabase = FriendLocalDatabase(delegate: nil)
        let friend: FriendModel? = friendLocalDatabase.getFriendByUsername(username)
        if (friend == nil) {
            println("Cannot find friend mentioned in push notification \(username)")
            return
        }
        friendDetailsViewController.friendLocalDatabase = friendLocalDatabase
        friendDetailsViewController.friend = friend

        let navigationController = tabbedViewController.navigationController
        let nav = tabbedViewController.viewControllers![1]
        nav.pushViewController(friendDetailsViewController, animated: true)
    }

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /**
    * Support for Push Notifications
    */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        /* TODO: found this code, not sure what it does: http://stackoverflow.com/questions/24816847/not-able-to-set-interactive-push-notifications-on-ios8
        let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackground()
        */
        
        // send token to server
        println("Push token = \(deviceToken)")
        var characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        var deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        println( deviceTokenString )

        var url = "/api/me/apn-token"
        var formData: [String: AnyObject] = [
            "apnToken":  deviceTokenString
        ]
        
        HTTPController.getInstance().doPOST(url, parameters: formData, delegate: self, queryID: nil)
    }
    
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject?) {
        if let error = err {
            println("Error sending APN Token: \(error.localizedDescription)")
        }
    }

    
    // error in registering push notification
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("Error registering for push notification: \(error.localizedDescription)")
    }
    
    // called both in foreground and background mode
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        
        if application.applicationState == UIApplicationState.Active {
            println("didReceiveRemoteNotification while app is active: \(userInfo)")
            // app was already in the foreground
        } else {
            // app was just brought from background to foreground
            println("didReceiveRemoteNotification while app is in background \(userInfo)")
            handleRemoteNotification(userInfo)
        }
        handler(UIBackgroundFetchResult.NoData) // TBD
    }
    
    // user requested a specific action from the push notification message
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        println("handleActionWithIdentifier \(identifier) \(userInfo)")
        completionHandler()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println("didReceiveRemoteNotification \(userInfo)")
    }

    /** 
     * CoreData code below
    */
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.johnnichols.Testing" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("SapristiModel", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SapristiModel.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            let alert = UIAlertView(title: "Old CoreData Schema", message: error!.localizedDescription,
                delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

