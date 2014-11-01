//
//  PushNotificationManager.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/29/14.
//  Copyright (c) 2014 Sapristi. All rights reserved.
//

import Foundation


func nv_alert(msg: String) {
    let alert = UIAlertView(title: "Debug", message: msg,
        delegate: nil, cancelButtonTitle: "OK")
    alert.show()
    println(msg)
}

public enum APNType: String { // See NotificationManager.js
    case FriendAvailability = "FRIEND_AVAILABILITY"
    case MyAvailability = "MY_AVAILABILITY"
    case Registration = "REGISTRATION"
}

let acceptButton = "ACCEPT_IDENTIFIER"
let declineButton = "NOT_NOW_IDENTIFIER"

class PushNotificationManager {
    
    init() {
        
    }
    
    private class func registerMyAvailabilityPushNotifications(application: UIApplication) -> UIMutableUserNotificationCategory {
        var action1: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        action1.identifier = acceptButton // no-op
        action1.title = "Yep!"
        action1.destructive = false
        action1.authenticationRequired = false
        action1.activationMode = UIUserNotificationActivationMode.Background
        
        var action2: UIMutableUserNotificationAction = UIMutableUserNotificationAction() // Bring app to foreground to cancel the availability change
        action2.identifier = declineButton
        action2.title = "Nope :("
        action2.destructive = true
        action2.authenticationRequired = false
        action2.activationMode = UIUserNotificationActivationMode.Foreground
        
        var category: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        category.identifier = APNType.MyAvailability.rawValue
        category.setActions([action1, action2], forContext: UIUserNotificationActionContext.Minimal)
        category.setActions([action1, action2], forContext: UIUserNotificationActionContext.Default)
        return category
    }
    
    private class func registerFriendAvailabilityPushNotifications(application: UIApplication) -> UIMutableUserNotificationCategory {
        var action1: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        action1.identifier = acceptButton
        action1.title = "Call"
        action1.destructive = false
        action1.authenticationRequired = true
        action1.activationMode = UIUserNotificationActivationMode.Foreground
        
        var action2: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        action2.identifier = declineButton
        action2.title = "NVM"
        action2.destructive = true
        action2.authenticationRequired = false
        action2.activationMode = UIUserNotificationActivationMode.Background
        
        var category: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        category.identifier = APNType.MyAvailability.rawValue
        category.setActions([action1, action2], forContext: UIUserNotificationActionContext.Minimal)
        category.setActions([action1, action2], forContext: UIUserNotificationActionContext.Default)
        return category
    }
    
    private class func registerRegistrationPushNotifications(application: UIApplication) -> UIMutableUserNotificationCategory {
        return registerFriendAvailabilityPushNotifications(application)
    }
    
    class func registerForPushNotifications() {
        let application = UIApplication.sharedApplication()
        
        // APNType.MyAvailability
        // APNType.FriendAvailability
        // APNType.Registration
        
        let categoryMyAvailability = registerMyAvailabilityPushNotifications(application)
        let categoryFriendAvailability = registerFriendAvailabilityPushNotifications(application)
        let categoryRegistration = registerRegistrationPushNotifications(application)
        var types: UIUserNotificationType = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
        var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: NSSet(array:[categoryMyAvailability, categoryFriendAvailability, categoryRegistration]) )
        application.registerUserNotificationSettings( settings )
        application.registerForRemoteNotifications()

    }
    
    func checkWhetherStartingFromPushNotification(launchOptions: NSDictionary!) {
        var notification: [NSObject : AnyObject]? = launchOptions.objectForKey(UIApplicationLaunchOptionsRemoteNotificationKey) as [NSObject : AnyObject]?
        if notification != nil {
            NSLog("app received notification from remote \(notification)")
            handleRemoteNotification(notification!)
        } else {
            NSLog("app did not receive notification")
        }
    }

    // Open the app and show the friend details page for the correct friend
    // TODO: right now this works if the app was running in the background but not if it's terminated. Not sure why and hard to debug since Xcode is no longer attached at that point...
    func handleRemoteNotification(userInfo: [NSObject: AnyObject]) {
        let username = userInfo["username"] as String
        FriendDetailViewController.showFriend(username)
    }
    
    // Called when user takes action on a push notification while app is in background mode
    func handleActionWithIdentifier(application: UIApplication, handleActionWithIdentifier identifier: String?, userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        println("handleActionWithIdentifier \(identifier) \(userInfo)")
        let type = userInfo["type"] as String
        switch type {
        case APNType.FriendAvailability.rawValue, APNType.Registration.rawValue:
            if identifier == acceptButton { // user wants to see that friend's detail page (from where she can make a 1-tap call)
                let username = userInfo["username"] as String
                FriendDetailViewController.showFriend(username)
                println("showing friend details \(username)")
            }
        case APNType.MyAvailability.rawValue:
            if identifier == declineButton { // user doesn't want the system to update her availability
                println("Clicked on a MyAvailability push notif")
                //TODO...
            }
        default:
            println("No handler is set up for action \(identifier)")
        }
        completionHandler() // always call this when done (be careful with async calls above...)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    class func getTopController() -> UIViewController {
        var topController: UIViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        while topController.presentedViewController != nil {
            topController = topController.presentedViewController!;
        }
        return topController;
    }
    
    var remainingSecs: Int = 0
    var dismissibleAlert: UIAlertController?
    var dismissTimer: NSTimer?
    
    @objc func updateAlert() {
        if remainingSecs <= 0 {
            if dismissTimer != nil {
                dismissTimer!.invalidate()
                dismissTimer=nil
            }
            if dismissibleAlert != nil {
                dismissibleAlert!.dismissViewControllerAnimated(true) {
                    println("dismissed")
                }
            }
        } else {
            remainingSecs--
            dismissibleAlert!.message = "Message will dismiss in \(remainingSecs)s"
        }
    }

    
    func didReceiveRemoteNotification(application: UIApplication, userInfo: [NSObject : AnyObject]) {
        if application.applicationState == UIApplicationState.Active {
            // app was already in the foreground
            println("didReceiveRemoteNotification while app is active: \(userInfo)")
            let username = userInfo["username"] as String
            let aps = userInfo["aps"] as Dictionary<String, AnyObject>
            let type = userInfo["type"] as String
            let title = aps["alert"] as String
            remainingSecs = 5
            let message = "Message will dismiss in \(remainingSecs)s"
            dismissibleAlert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            switch type {
            case APNType.Registration.rawValue, APNType.FriendAvailability.rawValue: // a friend status changed
                let OKAction = UIAlertAction(title: "View", style: .Default) { (action) in
                    println("Alert OK pressed")
                    FriendDetailViewController.showFriend(username)
                }
                dismissibleAlert!.addAction(OKAction)
                let CancelAction = UIAlertAction(title: "NVM", style: .Cancel) { (action) in
                    println("Alert Cancel pressed")
                }
                dismissibleAlert!.addAction(CancelAction)
                
            case APNType.MyAvailability.rawValue: // my availability changed, initiated by the system (e.g. in car motion)
                let availability = userInfo["availability"] as String
                let reason = userInfo["reason"] as String
                dismissibleAlert!.title = "Is it OK to set my availability to \(availability) because \(reason)?"

                let OKAction = UIAlertAction(title: "Yep!", style: .Default) { (action) in
                    println("Alert OK pressed")
                    
                    NotificationCenterManager.postNotificationName(NotificationCenterAvailability, object: self, userInfo: ["availability": availability, "reason": reason])
                    /*var topController = PushNotificationManager.getTopController()
                    topController = topController.visibleViewController
                    println("topController \(topController)")
                    if topController.isKindOfClass(AllFriendsViewController) {
                        let allFriendsVC = topController as AllFriendsViewController
                        allFriendsVC.getMyAvailability()
                    }*/
                }
                dismissibleAlert!.addAction(OKAction)
                let CancelAction = UIAlertAction(title: "Nope :(", style: .Cancel) { (action) in
                    println("Alert Cancel pressed")
                    //TODO: change the logic so the server only sends the APN if the action wasn't triggered by the user in the first place
                    //TODO: send a cancel message back to server to revert/avoid changing my availability
                }
                dismissibleAlert!.addAction(CancelAction)                
            default:
                println("Unknown APN message type: \(type)")
                return
            }
            
            PushNotificationManager.getTopController().presentViewController(dismissibleAlert!, animated: true) {
                println("presentViewController")
            }
            
            dismissTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateAlert"), userInfo: nil, repeats: true)
        } else {
            // app was just brought from background to foreground
            println("didReceiveRemoteNotification while app is in background \(userInfo)")
            handleRemoteNotification(userInfo)
        }

    }

}