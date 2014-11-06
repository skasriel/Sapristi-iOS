//
//  AllFriendsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/12/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

let refreshQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)

class AllFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HTTPControllerProtocol {
    
    let FRIEND_AVAILABILITY : String = "FRIEND_AVAILABILITY"
    let MY_AVAILABILITY: String = "GET_AVAILABILITY"
    
    @IBOutlet weak var changeAvailabilityButton: UIButton!
    @IBOutlet weak var allFriendsTableView: UITableView!
    @IBOutlet weak var inviteFriendsButton: UIButton!
    @IBOutlet weak var reasonLabel: UILabel!
    
    var refreshControl:UIRefreshControl?
    var friendLocalDatabase: FriendLocalDatabase?
    var refreshTimer: NSTimer?
    
    let notificationCenterManager = NotificationCenterManager()

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
        
        fetchFromDatabase() // load address book from Core Data
        
        refresh() // get friends' availability from server
        
        // allow user to pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull To Refresh...")
        refreshControl!.addTarget(self, action: Selector("refreshInvoked"), forControlEvents: UIControlEvents.ValueChanged)
        allFriendsTableView.addSubview(refreshControl!)
        
        // Also refresh periodically (at least until I build push notifications)
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("doRefresh"), userInfo: nil, repeats: true)
        
        notificationCenterManager.registerObserver(NotificationCenterAvailability) { userInfo in
            self.getMyAvailability() // not optimal, I already have the availability in userInfo...
        }
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
        getMyAvailability()
    }
    
    func refresh(viaPullToRefresh: Bool = false) {
        dispatch_async(refreshQueue) {
            self.getFriendAvailability()
            if (viaPullToRefresh) {
                self.refreshControl!.endRefreshing()
            }
        }
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

    let imageBusy = UIImage(named: "busy_dot_icon")
    let imageAvailable = UIImage(named: "available_dot_icon")
    let imageUnknown = UIImage(named: "icon_unknown")
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: FriendCell = allFriendsTableView.dequeueReusableCellWithIdentifier("myCell") as FriendCell
        var friend: FriendModel = friendLocalDatabase!.objectAtIndexPath(indexPath)
        //print("row: \(indexPath)")
        //print(" friend: \(friend.availability)")
        //print(" cell: \(cell.friendStatusLabel)")
        
        cell.friendNameLabel.text = friend.displayName
        
        if friend.thumbnail != nil {
            cell.thumbnailImageView.image = UIImage(data: friend.thumbnail)
        } else {
            cell.thumbnailImageView.image = nil
        }
        
        var status: String = ""
        var image: UIImage?
        
        switch AvailabilityManager.getAvailabilityFromString(friend.availability)! {
        case Availability.Busy:
            image = imageBusy
        case Availability.Unknown:
            image = imageUnknown
        case Availability.Available:
            image = imageAvailable
        default:
            image = imageUnknown // shouldn't happen
        }
        cell.availabilityImageView.image = image
            
        if (friend.updatedAt != nil) {
            //println("updated: \(friend.updatedAt) - now = \(NSDate())")
            status += " Updated " + NSDate.formatElapsedTime(friend.updatedAt, end: NSDate())
        }
        cell.friendStatusLabel.text = status
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
        var newAvailability : Availability
        
        switch(availabilityManager.currentAvailability) {
        case Availability.Available:
            newAvailability = Availability.Unknown
        case Availability.Unknown:
            newAvailability = Availability.Busy
        default:
            newAvailability = Availability.Available
        }
        availabilityManager.setAvailability(newAvailability, reason: Reason.User, updateServer: true, delegate: self)
        updateAvailabilityUI()
    }
    
    func updateAvailabilityUI() {
        let availability = availabilityManager.currentAvailability
        
        switch(availability) {
        case Availability.Available:
            changeAvailabilityButton.setTitle("AVAILABLE", forState: UIControlState.Normal)
            changeAvailabilityButton.backgroundColor = colorWithHexString("#00E85F") // UIColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1.0)
        case Availability.Unknown:
            changeAvailabilityButton.setTitle("UNKNOWN", forState: UIControlState.Normal)
            changeAvailabilityButton.backgroundColor = colorWithHexString("#8E8D93") // UIColor(red: 0.5, green: 0.3, blue: 0.3, alpha: 1.0)
        default:
            changeAvailabilityButton.setTitle("BUSY", forState: UIControlState.Normal)
            changeAvailabilityButton.backgroundColor =  colorWithHexString("#FF023F") // UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        }
        
        let reason: String? = availabilityManager.getReasonMessage()
        if reason != nil && reasonLabel != nil {
            reasonLabel.text = reason
        }
    }
    
    /** 
    * HTTPControllerProtocol implementation 
    */
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject?) {
        if (queryID == SET_AVAILABILITY) {
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
        if let error = err {
            println("Unable to set availability \(error.localizedDescription)")
            return
        }
    }
    
    func callbackMyAvailability(err: NSError?, results: AnyObject?) {
        if let error = err {
            println("Unable to retrieve availability \(error.localizedDescription)")
            return
        }
        let json = results! as Dictionary<String, AnyObject>
        let availabilityString = json["availability"]! as String
        let reasonString = json["reason"] as String?
        let availability = AvailabilityManager.getAvailabilityFromString(availabilityString)!
        let reason = AvailabilityManager.getReasonFromString(reasonString)
        availabilityManager.setAvailability(availability, reason: reason, updateServer: false, delegate: nil)
        updateAvailabilityUI();
    }
    
    func callbackFriendAvailability(err: NSError?, results: AnyObject?) {
        if let error = err {
            println("Unable to get friends' availability \(error.localizedDescription)")
            return
        }
        
        // Got an array from server, that contains the availability of my friends who are Sapristi users
        let jsonArray: Array<Dictionary<String, AnyObject>> = results! as Array<Dictionary<String, AnyObject>>
        
        // to be able to properly locate the results from server in the list of FriendModels stored locally, create a dictionary
        let map: Dictionary<String, FriendModel> = self.friendLocalDatabase!.getDictionary()
        
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
            let availability: String = availabilityOpt as String
            let updatedAt: String = updatedAtOpt as String
            println("availability: \(availability) for user \(username) @ \(index)")
            
            let friendLocalData: FriendModel? = map[username]
            if (friendLocalData == nil) {
                println("Unable to find local friend for \(username)");
            } else {
                if friendLocalData!.phoneNumber != username {
                    friendLocalData!.phoneNumber = username // set the primary phone number as the one used by that user on Sapristi - this way I'll always call the "correct" number, and not the one that's stored first in the list of numbers in my local address book
                    FriendLocalDatabase.saveToCoreData()
                }
                friendLocalData!.availability = availability
                if let updatedAtDate = NSDate.dateFromISOString(updatedAt) {
                    friendLocalData!.updatedAt = updatedAtDate
                }
            }
        }
        self.friendLocalDatabase!.sort() // Show available friends, then busy friends, then unknown friends
        self.allFriendsTableView.reloadData() // refresh the view
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

