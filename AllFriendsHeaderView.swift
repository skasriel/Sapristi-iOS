//
//  AllFriendsHeaderView.swift
//  Sapristi
//
//  Created by Cedric Sellin on 12/3/14.
//  Copyright (c) 2014 Sapristi. All rights reserved.
//

import Foundation
import UIKit

class AllFriendsHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    
    var allFriendsController : AllFriendsViewController?
    let availabilityManager = AvailabilityManager.getInstance()
    
    @IBAction func changeStatus(sender: AnyObject) {
        var newAvailability : Availability
        
        switch(availabilityManager.currentAvailability) {
        case Availability.Available:
            newAvailability = Availability.Unknown
        case Availability.Unknown:
            newAvailability = Availability.Busy
        default:
            newAvailability = Availability.Available
        }
        
        availabilityManager.setAvailability(newAvailability, reason: Reason.User, updateServer: true, delegate: allFriendsController)
        
        updateAvailabilityUI()
    }
    
    func updateAvailabilityUI() {
        let availability = availabilityManager.currentAvailability
        
        switch(availability) {
        case Availability.Available:
            statusButton.setTitle("AVAILABLE", forState: UIControlState.Normal)
            statusButton.backgroundColor = colorWithHexString("#00E85F") // UIColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1.0)
        case Availability.Unknown:
            statusButton.setTitle("UNKNOWN", forState: UIControlState.Normal)
            statusButton.backgroundColor = colorWithHexString("#8E8D93") // UIColor(red: 0.5, green: 0.3, blue: 0.3, alpha: 1.0)
        default:
            statusButton.setTitle("BUSY", forState: UIControlState.Normal)
            statusButton.backgroundColor =  colorWithHexString("#FF023F") // UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        }
        
        let reason: String? = availabilityManager.getReasonMessage()
        if reason != nil && reasonLabel != nil {
            reasonLabel.text = reason
        }
    }
}
