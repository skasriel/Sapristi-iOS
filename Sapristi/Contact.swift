//
//  Contact.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/15/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import CoreData

class Contact : NSObject {
    var displayName: NSString = ""
    var phoneNumbers: NSArray = NSArray()
    var desiredCallFrequency: Int = 0
    //var emailAddresses: NSArray = NSArray()
    var thumbnail: UIImage?
    
    
    func serializeForHTTP() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["displayName"] = displayName
        dictionary["phoneNumbers"] = phoneNumbers
        dictionary["desiredCallFrequency"] = desiredCallFrequency
        //dictionary["emailAddresses"] = contact.emailAddresses
        return dictionary
    }
    
    func serializeForCoreData(entityDescription: NSEntityDescription?, managedObjectContext: NSManagedObjectContext?) -> FriendModel {
        let friend = FriendModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        friend.displayName = displayName
        friend.phoneNumber = phoneNumbers[0] as String
        friend.hasAccount = false // TBD
        friend.availability = Availability.UNKNOWN // TBD
        friend.desiredCallFrequency = desiredCallFrequency
        if thumbnail != nil {
            friend.thumbnail = UIImagePNGRepresentation(thumbnail!)
        }
        
        // separate all phone numbers with a special character... (a small hack)
        var allPhoneNumbers = "";
        for (i, number) in enumerate(phoneNumbers) {
            if (i>0) {
                allPhoneNumbers += ">"
            }
            allPhoneNumbers += number as String
        }
        friend.allPhoneNumbers = allPhoneNumbers
        return friend
    }
}