//
//  AllFriendsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/12/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit
import CoreData

class AllFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
                            NSFetchedResultsControllerDelegate, HTTPControllerProtocol {
    
    let FRIEND_AVAILABILITY : String = "FRIEND_AVAILABILITY"
    let SET_AVAILABILITY: String = "SET_AVAILABILITY"
    
    @IBOutlet weak var changeAvailabilityButton: UIButton!
    @IBOutlet weak var allFriendsTableView: UITableView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController()
    
    var friends: [FriendModel] = []
    
    var currentAvailability = Availability.AVAILABLE
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        HTTPController.getInstance().doGET("/api/me/friend-availability", delegate: self, queryID: FRIEND_AVAILABILITY)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: friendFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
        //allFriendsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showFriendDetail" {
            let detailVC:FriendDetailViewController = segue.destinationViewController as FriendDetailViewController
            let indexPath = self.allFriendsTableView.indexPathForSelectedRow()
            let selectedFriend = fetchedResultsController.objectAtIndexPath(indexPath!) as FriendModel // friends[indexPath.row]
            detailVC.friend = selectedFriend
        }
    }

    /**
    * UITableViewDataSource implementation
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects //friends.count
    }
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: FriendCell = allFriendsTableView.dequeueReusableCellWithIdentifier("myCell") as FriendCell
        var friend: FriendModel = fetchedResultsController.objectAtIndexPath(indexPath) as FriendModel
        print("row: \(indexPath)")

        print(" friend: \(friend.availability)")
        print(" cell: \(cell.friendStatusLabel)")
        cell.friendNameLabel.text = friend.displayName
        cell.friendStatusLabel.text = friend.availability
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
        
        var params = ["availability": newAvailability]
        HTTPController.getInstance().doPOST("/api/me/availability", parameters: params, delegate: self, queryID: SET_AVAILABILITY)
    }
    
    /** HTTPControllerProtocol implementation */
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject?) {
        if (queryID == SET_AVAILABILITY) {
            return callbackChangeAvailability(err, results: results);
        } else if (queryID == FRIEND_AVAILABILITY) {
            return callbackFriendAvailability(err, results: results);
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
    func callbackFriendAvailability(err: NSError?, results: AnyObject?) {
        if err != nil {
            println("Unable to get friends' availability \(err!.localizedDescription)")
            return
        }
        // Got an array from server, that contains the availability of my friends who are Sapristi users
        let jsonArray: Array<Dictionary<String, AnyObject>> = results! as Array<Dictionary<String, AnyObject>>
        
        // to be able to properly locate the results from server in the list of FriendModels stored locally, create a dictionary
        let fetchedArray: [FriendModel] = fetchedResultsController.fetchedObjects as [FriendModel]
        var map: Dictionary<String, FriendModel> = Dictionary()
        for (index, friend) in enumerate(fetchedArray) {
            var normalizedFriendPhoneNumber = HTTPController.cleanPhone(friend.phoneNumber) // the server returns e164 phone numbers, so need to clean up my local numbers in order to use them as keys for the dictionary
            map[normalizedFriendPhoneNumber] = friend
        }
        
        // now update the availability of my friends
        for (index, friendServerData: Dictionary<String, AnyObject>) in enumerate(jsonArray) {
            let username: String = friendServerData["username"]! as String
            let availability: String = friendServerData["availability"]! as String
            let updatedAt = friendServerData["updatedAt"]! as String
            let friendLocalData: FriendModel? = map[username]
            if (friendLocalData == nil) {
                println("Unable to find local friend for \(username)");
            } else {
                friendLocalData!.availability = availability
                //cell!.updatedAt = updatedAt
            }
        }
        allFriendsTableView.reloadData()
    }
    
    /**
    * CoreData Methods for retrieving friend list from local database
    */
    func friendFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "FriendModel")
        let sortDescriptor = NSSortDescriptor(key: "displayName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    /* NSFetchedResultsControllerDelegate implementation */
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
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

