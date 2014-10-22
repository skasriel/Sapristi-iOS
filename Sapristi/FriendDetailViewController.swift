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
    var allPhoneNumbers: [String]?
    
    
    @IBOutlet weak var friendPhoneTableView: UITableView!
    
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

        //friendImageView.image = UIImage(named:friend.imageName)
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
        cell.textLabel.text = "mobile"
        cell.detailTextLabel!.text = allPhoneNumbers![row]
        return cell
    }
    
    /* UITableViewDelegate implementation */
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let row = indexPath.row
        let phoneNumber = allPhoneNumbers![row]
        
        println("Calling: "+phoneNumber)
        PhoneController.makePhoneCall(phoneNumber)
    }
    
    @IBAction func addToFavoritesButtonPressed(sender: AnyObject) {
        if friend.isFavorite==nil || friend.isFavorite!.boolValue==false {
            friend.isFavorite = true
        } else {
            friend.isFavorite = false
        }
        showFavoriteButton()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        var err: NSError? = nil
        managedObjectContext?.save(&err)
        if let error = err {
            println("Error saving favorite: \(error)")
        }
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
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        var err: NSError? = nil
        managedObjectContext?.save(&err)
        if let error = err {
            println("Error saving frequency: \(error)")
        } else {
            updateFrequencyLabel()
            friendLocalDatabase.needsRefresh = true
        }
        
        // And to the server (which may use it e.g. to send more / fewer push notifications about that user)
        var url = "/api/me/desired-frequency/" + defaultPhoneNumber!
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