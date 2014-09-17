//
//  FirstViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/12/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit
import CoreData

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
                            
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var availabilityButton: UIButton!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController()
    
    var friends: [FriendModel] = []
    //var allContacts: [Contact] = []
    
    var currentAvailability = Availability.AVAILABLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController = getFetchedResultsController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
        /*for (index, contact) in enumerate(allContacts) {
            println("Current contact = \(contact)")
            var friend = Friend();
            friend.name = contact.displayName
            friend.availability = Availability.UNKNOWN
            friend.phoneNumber = contact.phoneNumbers[0]
            friends.append(friend)
        }*/
        
        /*var friend = Friend();
        friend.name = "Cedric Sellin"
        friend.availability = Availability.AVAILABLE
        friend.phoneNumber = "650-xxx-xxxx"
        friend.imageName = "ced.jpg"
        friends.append(friend)

        friend = Friend()
        friend.name = "Gwen Kasriel"
        friend.availability = Availability.UNKNOWN
        friend.phoneNumber = "+1 (650) 319-5424"
        friend.imageName = "gwen.jpg"
        friends.append(friend)
        
        friend = Friend()
        friend.name = "Michal Sellin"
        friend.availability = Availability.BUSY
        friend.phoneNumber = "408-xxx-xxxx"
        friends.append(friend)
        
        friend = Friend()
        friend.name = "Reza"
        friend.availability = Availability.BUSY
        friend.phoneNumber = "408-xxx-xxxx"
        friend.imageName = "reza.jpg"
        friends.append(friend)
        
        friend = Friend()
        friend.name = "John M."
        friend.availability = Availability.BUSY
        friend.phoneNumber = "408-xxx-xxxx"
        friend.imageName = "john.jpg"
        friends.append(friend)*/
        
        friendsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue!.identifier == "showFriendDetail" {
            let detailVC:FriendDetailViewController = segue!.destinationViewController as FriendDetailViewController
            let indexPath = self.friendsTableView.indexPathForSelectedRow()
            let selectedFriend = fetchedResultsController.objectAtIndexPath(indexPath) as FriendModel // friends[indexPath.row]
            detailVC.friend = selectedFriend
        }
    }

    // UITableViewDataSource implementation
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections[section].numberOfObjects //friends.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        println("drawing \(indexPath.row)")
        var cell: FriendCell = friendsTableView.dequeueReusableCellWithIdentifier("myCell") as FriendCell
        var friend: FriendModel = fetchedResultsController.objectAtIndexPath(indexPath) as FriendModel // friends[indexPath.row % friends.count]
        cell.friendNameLabel.text = friend.displayName
        cell.friendStatusLabel.text = friend.availability
        /*if friend.imageName {
            cell.friendImageView.image = UIImage(named:friend.imageName)
        }*/
        cell.phoneNumber = friend.phoneNumber
        return cell
    }
    
    // CoreData delegate
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        friendsTableView.reloadData()
    }
    
    // UITableViewDelegate implementation
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        self.performSegueWithIdentifier("showFriendDetail", sender: self)        
    }
    
    @IBAction func callButtonPressed(sender: UIButton) {
        println("Clicked on: \(sender)")
    }

    @IBAction func availabilityButtonPressed(sender: UIButton) {
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
            availabilityButton.setTitle("AVAILABLE", forState: UIControlState.Normal)
            availabilityButton.backgroundColor = UIColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1.0)
        case Availability.UNKNOWN:
            availabilityButton.setTitle("UNKNOWN", forState: UIControlState.Normal)
            availabilityButton.backgroundColor = UIColor(red: 0.5, green: 0.3, blue: 0.3, alpha: 1.0)
        default:
            availabilityButton.setTitle("BUSY", forState: UIControlState.Normal)
            availabilityButton.backgroundColor = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        }
    }
    
    // Utility Methods
    func friendFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "FriendModel")
        let sortDescriptor = NSSortDescriptor(key: "displayName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    func getFetchedResultsController() -> NSFetchedResultsController {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: friendFetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
        
    }
    
    func showAlertWithText (header : String = "Warning", message : String) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

