//
//  AllFriendsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/12/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class AllFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HTTPControllerProtocol {
    
    let FRIEND_AVAILABILITY : String = "FRIEND_AVAILABILITY"
    let MY_AVAILABILITY: String = "GET_AVAILABILITY"
    
    @IBOutlet weak var changeAvailabilityButton: UIButton!
    @IBOutlet weak var allFriendsTableView: UITableView!
    @IBOutlet weak var inviteFriendsButton: UIButton!
    
    
    var refreshControl:UIRefreshControl?
    var friendLocalDatabase: FriendLocalDatabase?
    var refreshTimer: NSTimer?
    
    let availabilityManager = AvailabilityManager.getInstance()
    
    override init() {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ConfigManager.setIntConfigValue(CONFIG_SELECTED_TAB, newValue: 1)
        getMyAvailability()
        if let friends = friendLocalDatabase {
            if friends.needsRefresh {
                refresh()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let timer = refreshTimer {
            timer.invalidate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFromDatabase()
        
        refresh()
        
        // allow user to pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull To Refresh...")
        refreshControl!.addTarget(self, action: Selector("refreshInvoked"), forControlEvents: UIControlEvents.ValueChanged)
        allFriendsTableView.addSubview(refreshControl!)
        
        // Also refresh periodically (at least until I build push notifications)
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("doRefresh"), userInfo: nil, repeats: true)
        
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
    }
    
    func fetchFromDatabase() {
        friendLocalDatabase = FriendLocalDatabase(delegate: allFriendsTableView)
        friendLocalDatabase!.fetchFromAllDatabase();
    }

    @objc func refreshInvoked()
    {
        refresh(viaPullToRefresh: true)
    }
    
    @objc func doRefresh() {
        refresh()
        
        // refresh the button value periodically, a bit of a hack - server will change my availability automatically and this needs to be reflected in UI
        updateAvailabilityUI();
    }
    
    func refresh(viaPullToRefresh: Bool = false) {
        println("Do Refresh")
        getFriendAvailability()
        if (viaPullToRefresh) {
            self.refreshControl!.endRefreshing()
        }
        println("Done refreshing")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (inviteFriendsButton != nil && sender as NSObject! == inviteFriendsButton) {
            return
        }
        if "showFriendDetail" == segue.identifier  {
            let detailVC:FriendDetailViewController = segue.destinationViewController as FriendDetailViewController
            let indexPath = self.allFriendsTableView.indexPathForSelectedRow()
            let selectedFriend = friendLocalDatabase!.objectAtIndexPath(indexPath!)
            detailVC.friend = selectedFriend
            detailVC.friendLocalDatabase = friendLocalDatabase!
        }
    }

    /**
    * UITableViewDataSource implementation
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendLocalDatabase!.numberOfRowsInSection(section)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: FriendCell = allFriendsTableView.dequeueReusableCellWithIdentifier("myCell") as FriendCell
        var friend: FriendModel = friendLocalDatabase!.objectAtIndexPath(indexPath)
        //print("row: \(indexPath)")
        //print(" friend: \(friend.availability)")
        //print(" cell: \(cell.friendStatusLabel)")
        
        cell.friendNameLabel.text = friend.displayName
        
        var status: String = friend.availability
        var imageName: String
        switch status {
        case Availability.BUSY:
            imageName = "busy_dot_icon"
        case Availability.UNKNOWN:
            imageName = "icon_unknown" // TODO: another icon
        case Availability.AVAILABLE:
            imageName = "available_dot_icon"
        default:
            imageName = "icon_unknown" // shouldn't happen...
        }
        cell.availabilityImageView.image = UIImage(named: imageName)
            
        if (friend.availability != Availability.UNKNOWN) {
            status += " (updated " + NSDate.formatElapsedTime(friend.updatedAt, end: NSDate()) + ")"
        }
        cell.friendStatusLabel.text = status
        /*if friend.imageName {
            cell.friendImageView.image = UIImage(named:friend.imageName)
        }*/
        cell.phoneNumber = friend.phoneNumber
        return cell
    }
    
    /* UITableViewDelegate implementation */
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        self.performSegueWithIdentifier("showFriendDetail", sender: self)        
    }
    
    func getFriendAvailability() {
        HTTPController.getInstance().doGET("/api/me/friend-availability", delegate: self, queryID: FRIEND_AVAILABILITY)
    }
    func getMyAvailability() {
        HTTPController.getInstance().doGET("/api/me/availability", delegate: self, queryID: MY_AVAILABILITY)
    }

    @IBAction func changeAvailabilityButtonPressed(sender: UIButton) {
        var newAvailability : String;
        
        switch(availabilityManager.currentAvailability) {
        case Availability.AVAILABLE:
            newAvailability = Availability.UNKNOWN
        case Availability.UNKNOWN:
            newAvailability = Availability.BUSY
        default:
            newAvailability = Availability.AVAILABLE
        }
        availabilityManager.setAvailability(newAvailability, updateServer: true, reason: Availability.USER, delegate: self)
        updateAvailabilityUI()
    }
    
    func updateAvailabilityUI() {
        let availability = availabilityManager.currentAvailability
        
        switch(availability) {
        case Availability.AVAILABLE:
            changeAvailabilityButton.setTitle("AVAILABLE", forState: UIControlState.Normal)
            changeAvailabilityButton.backgroundColor = UIColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1.0)
        case Availability.UNKNOWN:
            changeAvailabilityButton.setTitle("UNKNOWN", forState: UIControlState.Normal)
            changeAvailabilityButton.backgroundColor = UIColor(red: 0.5, green: 0.3, blue: 0.3, alpha: 1.0)
        default:
            changeAvailabilityButton.setTitle("BUSY", forState: UIControlState.Normal)
            changeAvailabilityButton.backgroundColor = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        }
        
        let reason = availabilityManager.currentReason
        if reason == nil {
            
        } else {
            
        }
    }
    
    /** HTTPControllerProtocol implementation */
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject?) {
        if (queryID == Availability.SET_AVAILABILITY) {
            return callbackChangeAvailability(err, results: results);
        } else if (queryID == FRIEND_AVAILABILITY) {
            return callbackFriendAvailability(err, results: results);
        } else if (queryID == MY_AVAILABILITY) {
            return callbackMyAvailability(err, results: results);
        } else {
            println("Unknown callback type: "+queryID!);
        }
    }
    func callbackChangeAvailability(err: NSError?, results: AnyObject?) {
        if err != nil {
            println("Unable to set availability \(err!.localizedDescription)")
            return
        }
    }
    func callbackMyAvailability(err: NSError?, results: AnyObject?) {
        if err != nil {
            println("Unable to retrieve availability \(err!.localizedDescription)")
            return
        }
        let json = results! as Dictionary<String, AnyObject>
        let availability = json["availability"]! as String
        availabilityManager.setAvailability(availability)
        updateAvailabilityUI();
    }
    
    func callbackFriendAvailability(err: NSError?, results: AnyObject?) {
        if err != nil {
            println("Unable to get friends' availability \(err!.localizedDescription)")
            return
        }
        // Got an array from server, that contains the availability of my friends who are Sapristi users
        let jsonArray: Array<Dictionary<String, AnyObject>> = results! as Array<Dictionary<String, AnyObject>>
        
        // to be able to properly locate the results from server in the list of FriendModels stored locally, create a dictionary
        let map: Dictionary<String, FriendModel> = friendLocalDatabase!.getDictionary()
        
        // now update the availability of my friends
        for (index, friendServerData: Dictionary<String, AnyObject>) in enumerate(jsonArray) {
            let username: String = friendServerData["username"]! as String
            let availabilityOpt: AnyObject? = friendServerData["availability"] as AnyObject?
            let updatedAtOpt: AnyObject? = friendServerData["updatedAt"] as AnyObject?
            if (availabilityOpt == nil) {
                println("Error: no availability for "+username);
                continue;
            }
            if (updatedAtOpt == nil) {
                println("Error: no updatedAt for "+username);
                continue;
            }
            println("availability: \(availabilityOpt) for user \(username) @ \(index)")
            let availability: String = availabilityOpt as String!
            let updatedAt: String = updatedAtOpt as String!
            
            let friendLocalData: FriendModel? = map[username]
            if (friendLocalData == nil) {
                println("Unable to find local friend for \(username)");
            } else {
                friendLocalData!.availability = availability
                if let updatedAtDate = NSDate.dateFromISOString(updatedAt) {
                    friendLocalData!.updatedAt = updatedAtDate
                }
            }
        }
        friendLocalDatabase!.sort() // Show available friends, then busy friends, then unknown friends
        allFriendsTableView.reloadData() // refresh the view
    }
    
    

    
    /**
    * Utility Methods
    */
    func showAlertWithText (header : String = "Warning", message : String) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

