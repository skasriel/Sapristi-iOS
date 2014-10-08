//
//  FriendDetailViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/14/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import UIKit

class FriendDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var friend: FriendModel!
    
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendUpdateLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    
    var defaultPhoneNumber: String?
    var allPhoneNumbers: [String]?
    
    
    @IBOutlet weak var friendPhoneTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendNameLabel.text = friend.displayName
        friendUpdateLabel.text = "Status updated " + NSDate.formatElapsedTime(friend.updatedAt, end: NSDate())
        
        defaultPhoneNumber = friend.phoneNumber
        allPhoneNumbers = friend.allPhoneNumbers.split(">") as? [String]
        //friendImageView.image = UIImage(named:friend.imageName)
    }
    @IBAction func addToFavoritesButtonPressed(sender: UIButton) {
    }
    
    @IBAction func unfriendButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.navigationController!.popViewControllerAnimated(true)
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
        cell.textLabel!.text = "mobile"
        cell.detailTextLabel!.text = allPhoneNumbers![row]
        return cell
    }
    
    /* UITableViewDelegate implementation */
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let row = indexPath.row
        let phoneNumber = allPhoneNumbers![row]
        
        println("Calling: "+phoneNumber)
        let url:NSURL? = NSURL.URLWithString("tel://"+phoneNumber);
        if (url != nil) {
            println("Url = \(url)")
            UIApplication.sharedApplication().openURL(url!);
        } else {
            println("Invalid phone #: \(phoneNumber)")
        }
    }

}