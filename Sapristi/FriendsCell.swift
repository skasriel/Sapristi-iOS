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
    
    var phoneNumber : String = ""
    
    @IBAction func callButtonPressed(sender: UIButton) {
        println("Calling: "+phoneNumber)
        let url:NSURL? = NSURL.URLWithString("tel://"+phoneNumber);
        if (url != nil) {
            println("Url = \(url)")
            UIApplication.sharedApplication().openURL(url!);
        } else {
            println("Invalid phone #!!!")
        }
    }
}