//
//  FriendsCell.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/14/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import UIKit


class FriendCell: UITableViewCell {
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendStatusLabel: UILabel!
    @IBOutlet weak var friendPhoneButton: UIButton!
    @IBOutlet weak var availabilityImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var phoneNumber : String = ""
    
    @IBAction func callButtonPressed(sender: UIButton) {
        PhoneController.makePhoneCall(phoneNumber)
    }
}