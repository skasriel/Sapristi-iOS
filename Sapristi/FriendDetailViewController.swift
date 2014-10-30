//
//  FriendDetailViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/14/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import UIKit

class FriendDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HTTPControllerProtocol
{
    var friend: FriendModel!
    var friendLocalDatabase: FriendLocalDatabase!
    
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendUpdateLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    @IBOutlet weak var currentFrequencyLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var defaultPhoneNumber: String?
    var allPhoneNumbers: [PhoneNumberWithLabel]?
    
    
    @IBOutlet weak var friendPhoneTableView: UITableView!
    
    /**
     * Displays this view for a specific user. Called from push notification handlers
    */
    class func showFriend(username: String) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabbedViewController = mainStoryboard.instantiateViewControllerWithIdentifier("tabController") as UITabBarController
        tabbedViewController.selectedIndex = 1 // All Contacts
        UIApplication.sharedApplication().keyWindow!.rootViewController = tabbedViewController
        
        let friendDetailsViewController = mainStoryboard.instantiateViewControllerWithIdentifier("friendDetail") as FriendDetailViewController
        let friendLocalDatabase = FriendLocalDatabase(delegate: nil)
        let friend: FriendModel? = friendLocalDatabase.getFriendByUsername(username)
        if (friend == nil) {
            println("Cannot find friend mentioned in push notification \(username)")
            return
        }
        friendDetailsViewController.friendLocalDatabase = friendLocalDatabase
        friendDetailsViewController.friend = friend
        
        let navigationController = tabbedViewController.navigationController
        let nav: UINavigationController = tabbedViewController.viewControllers![1] as UINavigationController
        nav.pushViewController(friendDetailsViewController, animated: true)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        friendNameLabel.text = friend.displayName
        if (friend.updatedAt != nil) {
            friendUpdateLabel.text = "Status updated " + NSDate.formatElapsedTime(friend.updatedAt, end: NSDate())
        } else {
            friendUpdateLabel.text = ""
        }
        showFavoriteButton()
        updateFrequencyLabel()

        defaultPhoneNumber = friend.phoneNumber
        allPhoneNumbers = FriendLocalDatabase.getPhoneNumbers(friend)
        
        if friend.thumbnail != nil {
            thumbnailImageView.image = UIImage(data: friend.thumbnail)
        } else {
            thumbnailImageView.image = nil
        }
    }

    
    @IBAction func unfriendButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func showFavoriteButton() {
        if friend.isFavorite == nil {
            friend.isFavorite = false
        }
        if friend.isFavorite! == true {
            addToFavoritesButton.setTitle("Remove from Favorites", forState: UIControlState.Normal)
        } else {
            addToFavoritesButton.setTitle("Add to Favorites", forState: UIControlState.Normal)
        }

    }
    
    /**
    * UITableViewDataSource implementation
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let allNumbers = allPhoneNumbers {
            return countElements(allPhoneNumbers!)
        } else {
            println("All Phone Numbers array is nil")
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = friendPhoneTableView.dequeueReusableCellWithIdentifier("phoneNumberCell") as UITableViewCell
        let row = indexPath.row
        cell.textLabel.text = allPhoneNumbers![row].label // "mobile" // TODO: replace with the phoneWithLabels construct
        cell.detailTextLabel!.text = allPhoneNumbers![row].phoneNumber
        return cell
    }
    
    /* UITableViewDelegate implementation */
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let row = indexPath.row
        let phoneNumber = allPhoneNumbers![row]
        
        println("Calling: \(phoneNumber.phoneNumber)")
        PhoneController.makePhoneCall(phoneNumber.phoneNumber)
    }
    
    @IBAction func addToFavoritesButtonPressed(sender: AnyObject) {
        if friend.isFavorite==nil || friend.isFavorite!.boolValue==false {
            friend.isFavorite = true
        } else {
            friend.isFavorite = false
        }
        showFavoriteButton()
        FriendLocalDatabase.saveToCoreData()
        friendLocalDatabase.needsRefresh = true
    }

    func updateFrequency(change: Int) {
        var newFrequency: Int
        if let currentFrequency = friend.desiredCallFrequency {
            newFrequency = friend.desiredCallFrequency.integerValue + change
        } else {
            newFrequency = change
        }
        friend.desiredCallFrequency = newFrequency
        
        // save new desired call frequency to CoreData
        FriendLocalDatabase.saveToCoreData()
        updateFrequencyLabel()
        friendLocalDatabase.needsRefresh = true
        
        // And to the server (which may use it e.g. to send more / fewer push notifications about that user)
        var url = "/api/me/desired-frequency/" + PhoneController.cleanPhoneNumber(defaultPhoneNumber!)
        var formData: [String: AnyObject] = [
            "newFrequency":  friend.desiredCallFrequency
        ]
        HTTPController.getInstance().doPOST(url, parameters: formData, delegate: self, queryID: nil)
    }
    
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject?) {
        if let error = err {
            println("Error sending Desired Frequency to server: \(error.localizedDescription)")
        }
    }

    func updateFrequencyLabel() {
        var frequencyName: String;
        let frequency: Int = friend.desiredCallFrequency as Int
        switch frequency {
        case 2...10000:
            frequencyName = "Very Frequently"
        case 1:
            frequencyName = "Frequently"
        case 0:
            frequencyName = ""
        case -1:
            frequencyName = "Infrequently"
        case -2:
            frequencyName = "Rarely"
        case (-100000)...(-3):
            frequencyName = "Never"
        default:
            frequencyName = "Unknown"
        }
        currentFrequencyLabel.text = frequencyName
    }
    @IBAction func callMoreOftenButtonPressed(sender: AnyObject) {
        updateFrequency(1)
    }
    
    @IBAction func callLessOftenButtonPressed(sender: AnyObject) {
        updateFrequency(-1)
    }

    @IBAction func callButtonPressed(sender: AnyObject) {
        PhoneController.makePhoneCall(defaultPhoneNumber!)
    }
    
}