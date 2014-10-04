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
    let SET_AVAILABILITY: String = "SET_AVAILABILITY"
    let MY_AVAILABILITY: String = "GET_AVAILABILITY"
    
    @IBOutlet weak var changeAvailabilityButton: UIButton!
    @IBOutlet weak var allFriendsTableView: UITableView!
    @IBOutlet weak var inviteFriendsButton: UIButton!
    
    var friendLocalDatabase: FriendLocalDatabase = FriendLocalDatabase(delegate: nil)
        
    var currentAvailability = Availability.AVAILABLE
    
    override init() {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getFriendAvailability()
        getMyAvailability()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendLocalDatabase = FriendLocalDatabase(delegate: allFriendsTableView)
        friendLocalDatabase.fetchFromDatabase();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (sender as NSObject! == inviteFriendsButton) {
            return
        }
        if "showFriendDetail" == segue.identifier  {
            let detailVC:FriendDetailViewController = segue.destinationViewController as FriendDetailViewController
            let indexPath = self.allFriendsTableView.indexPathForSelectedRow()
            let selectedFriend = friendLocalDatabase.objectAtIndexPath(indexPath!)
            detailVC.friend = selectedFriend
        }
    }

    /**
    * UITableViewDataSource implementation
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendLocalDatabase.numberOfRowsInSection(section)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: FriendCell = allFriendsTableView.dequeueReusableCellWithIdentifier("myCell") as FriendCell
        var friend: FriendModel = friendLocalDatabase.objectAtIndexPath(indexPath)
        //print("row: \(indexPath)")
        //print(" friend: \(friend.availability)")
        //print(" cell: \(cell.friendStatusLabel)")
            
        cell.friendNameLabel.text = friend.displayName
        var status: String = friend.availability
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
        
        switch(currentAvailability) {
        case Availability.AVAILABLE:
            newAvailability = Availability.UNKNOWN
        case Availability.UNKNOWN:
            newAvailability = Availability.BUSY
        default:
            newAvailability = Availability.AVAILABLE
        }
        setAvailability(newAvailability)
        
        var params = ["availability": newAvailability]
        HTTPController.getInstance().doPOST("/api/me/availability", parameters: params, delegate: self, queryID: SET_AVAILABILITY)
    }
    
    func setAvailability(newAvailability: String) {
        currentAvailability = newAvailability
        switch(currentAvailability) {
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
    }
    
    /** HTTPControllerProtocol implementation */
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
        setAvailability(availability);
    }
    
    func callbackFriendAvailability(err: NSError?, results: AnyObject?) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * 60 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), getFriendAvailability) // Call this regularly in the background, at least until we figure out push notifications

        
        if err != nil {
            println("Unable to get friends' availability \(err!.localizedDescription)")
            return
        }
        // Got an array from server, that contains the availability of my friends who are Sapristi users
        let jsonArray: Array<Dictionary<String, AnyObject>> = results! as Array<Dictionary<String, AnyObject>>
        
        // to be able to properly locate the results from server in the list of FriendModels stored locally, create a dictionary
        let map: Dictionary<String, FriendModel> = friendLocalDatabase.getDictionary()
        
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
                println("converting: \(updatedAt)")
                if let updatedAtDate = NSDate.dateFromISOString(updatedAt) {
                    friendLocalData!.updatedAt = updatedAtDate
                    println("converted: \(updatedAtDate)")
                }
            }
        }
        allFriendsTableView.reloadData()
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

