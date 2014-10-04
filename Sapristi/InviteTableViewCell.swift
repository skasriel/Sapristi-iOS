//
//  InviteTableViewCell.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/24/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class InviteTableViewCell: UITableViewCell {
    var delegate: InviteFriendsViewController?
    
    var isChecked : Bool = false
    var friend : FriendModel?
    var allPhoneNumbers: [String]?
    
    @IBOutlet weak var contactAddress: UILabel!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactInviteButton: UIButton!
    
    var grayView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //toggleSelected()
    }

    @IBAction func contactInviteButtonPressed(sender: UIButton) {
        toggleSelected()
        
        if (!isChecked) {
            return
        }
        
        let allPhoneNumbersString: String = friend!.allPhoneNumbers
        if (allPhoneNumbersString.indexOf(">") > 0) {
            // this contact has more than one phone number, need to prompt user to choose the right one
            allPhoneNumbers = allPhoneNumbersString.componentsSeparatedByString(">")
            
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenWidth = screenSize.width;
            let screenHeight = screenSize.height;

            grayView = UIView(frame: screenSize)
            grayView!.backgroundColor = UIColor(white: 0.4, alpha: 0.6)
            delegate!.view.addSubview(grayView!)

            let menuHeight = (countElements(allPhoneNumbers!) * 52) + 150
            var startY = Int(screenHeight) - menuHeight
            
            let label = UILabel(frame: CGRectMake(15, CGFloat(startY), screenWidth-30, 45))
            label.text = "Pick a number: "
            label.textAlignment = .Center
            label.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            label.textColor = UIColor(white: 0.4, alpha: 1.0)
            grayView!/*delegate!.view*/.addSubview(label)
            
            for (index, phoneNumber) in enumerate(allPhoneNumbers!) {
                let button   = UIButton.buttonWithType(UIButtonType.System) as UIButton
                let y: CGFloat = CGFloat( startY + 50 + 52.0*index )
                button.frame = CGRectMake(15, y, screenWidth-30, 50)
                button.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
                button.setTitle(phoneNumber, forState: UIControlState.Normal)
                button.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 15)
                button.tag = index
                button.addTarget(self, action: Selector("phoneSelected:")/* phoneNumber*/, forControlEvents: UIControlEvents.TouchUpInside)
                grayView!/*delegate!.view*/.addSubview(button)
            }
            
            let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
            let y: CGFloat = CGFloat( startY + 45 + 55.0 * countElements(allPhoneNumbers!) )
            button.frame = CGRectMake(15, y, screenWidth-30, 50)
            button.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            button.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 15)
            button.setTitle("Cancel", forState: UIControlState.Normal)
            button.tag = -1
            button.addTarget(self, action: Selector("phoneCancel:"), forControlEvents: UIControlEvents.TouchUpInside)
            grayView!/*delegate!.view*/.addSubview(button)
        }
    }
    
    func phoneSelected(sender: UIButton!) {
        println("Selected #\(sender.tag)     \(sender) ")
        if grayView != nil {
            grayView!.hidden = true
            grayView!.removeFromSuperview()
        }
        contactAddress.text = allPhoneNumbers![sender.tag]
        friend?.phoneNumber = allPhoneNumbers![sender.tag]
    }
    func phoneCancel(sender: UIButton!) {
        println("Cancel")
        if grayView != nil {
            grayView!.hidden = true
            grayView!.removeFromSuperview()
        }
        toggleSelected()
    }
    
    func setStatus(status: Bool) {
        isChecked = status
        if (status) {
            contactInviteButton.setImage(UIImage(named: "Checkbox_checked"), forState: UIControlState.Normal)
        } else {
            contactInviteButton.setImage(UIImage(named: "Checkbox_unchecked"), forState: UIControlState.Normal)
        }
    }
    
    func toggleSelected() {
        setStatus(!isChecked)
        if (delegate != nil) {
            delegate!.toggleSelected(friend!, phoneNumber: contactAddress.text!, isChecked: isChecked)
        }
    }
    
}
