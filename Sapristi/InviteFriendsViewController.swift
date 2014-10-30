//
//  InviteFriendsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/23/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit
import MessageUI

class InviteFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var allFriendsTableView: UITableView!
    
    var friendLocalDatabase: FriendLocalDatabase?
    var selectedFriends = Dictionary<FriendModel, Bool>()
    var selectedNumbers = Dictionary<String, Bool>()
    
    var sms: MFMessageComposeViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        friendLocalDatabase = FriendLocalDatabase(delegate: allFriendsTableView)
        friendLocalDatabase!.fetchFromAllDatabase();
    }
    
    override func viewDidAppear(animated: Bool) {
        selectedFriends = Dictionary()
        selectedNumbers = Dictionary()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func inviteButtonPressed(sender: AnyObject) {
        // MFMailComposeResult
        // MFMessageComposeViewController
        
        if MFMessageComposeViewController.canSendText() {
            sms = MFMessageComposeViewController()
        } else {
            println("Phone can't send text messages")
            self.navigationController!.popViewControllerAnimated(true)
            return
        }
        
        var recipients = [String]()
        for (recipient, isChecked) in selectedNumbers {
            if (!isChecked) {
                continue
            }
            recipients.append(recipient)
        }
        sms!.messageComposeDelegate = self
        sms!.recipients = recipients
        sms!.subject = "Join sapristi"
        sms!.body = "I'd like to use Sapristi with you. It's the best way for us to share our availability for a quick phone call. https://sapristi.me/d/"
        presentViewController(sms!, animated:true, completion: nil)
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    /** UITableViewDelegate implementation
    */
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult: MessageComposeResult) {
        // result =  MessageComposeResultCancelled, MessageComposeResultSent, MessageComposeResultFailed
        println("In callback")
        sms!.dismissViewControllerAnimated(true, completion: nil)
    }
    func toggleSelected(friend: FriendModel, phoneNumber: String, isChecked: Bool) {
        selectedFriends[friend] = isChecked
        selectedNumbers[phoneNumber] = isChecked
    }
    
    /* UITableViewDelegate implementation */
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        /*var friend: FriendModel = friendLocalDatabase.objectAtIndexPath(indexPath)
        cell.toggleSelected()*/
    }
    
    // Need to replace this with an ActionSheet controller... Or see: http://nshipster.com/uialertcontroller/
    /**
    * UITableViewDataSource implementation
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendLocalDatabase!.numberOfRowsInSection(section)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: InviteTableViewCell = allFriendsTableView.dequeueReusableCellWithIdentifier("inviteCell") as InviteTableViewCell
        var friend: FriendModel = friendLocalDatabase!.objectAtIndexPath(indexPath)
        cell.delegate = self
        cell.friend = friend
        cell.setStatus(selectedFriends[friend] == true)
        
        cell.contactName.text = friend.displayName
        cell.contactAddress.text = friend.phoneNumber
        
        /*if friend.imageName {
        cell.friendImageView.image = UIImage(named:friend.imageName)
        }*/

        //print("row: \(indexPath)")
        //print(" friend: \(friend.availability)")
        //print(" cell: \(cell.friendStatusLabel)")
        return cell
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
