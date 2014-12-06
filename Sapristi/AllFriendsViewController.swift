//
//  AllFriendsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/12/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

let refreshQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)

class AllFriendsViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, HTTPControllerProtocol {
    
    let FRIEND_AVAILABILITY : String = "FRIEND_AVAILABILITY"
    let MY_AVAILABILITY: String = "GET_AVAILABILITY"
    
    @IBOutlet weak var changeAvailabilityButton: UIButton!
    @IBOutlet weak var inviteFriendsButton: UIButton!
    @IBOutlet weak var reasonLabel: UILabel!
    var headerView: AllFriendsHeaderView!
    var footerView: AllFriendsFooterView!
    
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
        
        
        var nib: UINib = UINib(nibName: "AllFriendsHeader", bundle:nil)
        self.tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier:"Header");
        headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("Header") as AllFriendsHeaderView;
        headerView.allFriendsController = self
        
        let nib2:NSArray = NSBundle.mainBundle().loadNibNamed("AllFriendsFooterView", owner: nil, options: nil)
        footerView = nib2[0] as AllFriendsFooterView
        footerView.allFriendsController = self
        
        // Also refresh periodically (at least until I build push notifications)
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("doRefresh"), userInfo: nil, repeats: true)
        
        notificationCenterManager.registerObserver(NotificationCenterAvailability) { userInfo in
            self.getMyAvailability() // not optimal, I already have the availability in userInfo...
        }
        
        fetchFromDatabase() // load address book from Core Data
        refresh() // get friends' availability from server
    }
    
    func fetchFromDatabase() {
        friendLocalDatabase = FriendLocalDatabase(delegate: tableView)
        friendLocalDatabase!.fetchFromAllDatabase();
    }

    @IBAction func refreshInvoked(sender: AnyObject) {
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
            let indexPath = tableView.indexPathForSelectedRow()
            let selectedFriend = friendLocalDatabase!.objectAtIndexPath(indexPath!)
            detailVC.friend = selectedFriend
            detailVC.friendLocalDatabase = friendLocalDatabase!
        }
    }

    /**
    * UITableViewDataSource implementation
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendLocalDatabase!.numberOfRowsInSection(section)
    }

    let imageBusy = UIImage(named: "busy_dot_icon")
    let imageAvailable = UIImage(named: "available_dot_icon")
    let imageUnknown = UIImage(named: "icon_unknown")
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell: FriendCell = tableView.dequeueReusableCellWithIdentifier("friendCell") as FriendCell
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
    
    // Need to implement this function to get the viewForHeaderInSection call back...
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if headerView == nil {
            return 0
        }
        var height = headerView.frame.height
        return height
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return headerView
    }
    
    // Need to implement this function to get the viewForHeaderInSection call back...
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height = footerView.frame.height
        
        //For the FavoriteFriendsVC we don't want a footer
       if self is FavoriteFriendsViewController {
            height = 0;
        }
        
        return height
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return footerView
    }
    
    /* UITableViewDelegate implementation */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showFriendDetail", sender: self)        
    }
    
    func clickedOnInviteFriends() {
        self.performSegueWithIdentifier("InviteFriend", sender: self)
    }
    
    func getFriendAvailability() {
        HTTPController.getInstance().doGET("/api/me/friend-availability", delegate: self, queryID: FRIEND_AVAILABILITY)
    }
    func getMyAvailability() {
        HTTPController.getInstance().doGET("/api/me/availability", delegate: self, queryID: MY_AVAILABILITY)
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
        headerView.updateAvailabilityUI();
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
        self.tableView.reloadData() // refresh the view
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

