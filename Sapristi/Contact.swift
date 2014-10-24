//
//  Contact.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/15/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import CoreData

class PhoneNumberWithLabel {
    var phoneNumber: String = ""
    var label: String?
    
    init(phoneNumber: String, label: String?) {
        self.phoneNumber = phoneNumber
        self.label = label
    }
    
    class func getArrayWithoutLabels(phoneNumbers: [PhoneNumberWithLabel]) -> [String] {
        var array = [String]()
        for phoneNumber in phoneNumbers {
            array.append(phoneNumber.phoneNumber)
        }
        return array
    }
}

class Contact : NSObject {
    var displayName: String = ""
    var phoneNumbers = [PhoneNumberWithLabel]() // [String]()
    var desiredCallFrequency: Int = 0
    var thumbnail: UIImage?
    
    
    func serializeForHTTP() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["displayName"] = displayName
        dictionary["phoneNumbers"] = PhoneNumberWithLabel.getArrayWithoutLabels(phoneNumbers) as NSArray // because Swift's json serializer is too dumb to serialize the full object...
        dictionary["desiredCallFrequency"] = desiredCallFrequency
        return dictionary
    }
    
    func serializeForCoreData(entityDescription: NSEntityDescription?, managedObjectContext: NSManagedObjectContext?) -> FriendModel {
        let friend = FriendModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        friend.displayName = displayName
        friend.phoneNumber = phoneNumbers[0].phoneNumber
        friend.hasAccount = false // TBD
        friend.availability = Availability.Unknown.rawValue // TBD
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
            var label = number.label
            if label == nil {
                label = ""
            }
            allPhoneNumbers += label! + ":" + number.phoneNumber
        }
        friend.allPhoneNumbers = allPhoneNumbers
        return friend
    }
    
    class func getPhoneNumbersWithLabelFromString(string: String) -> [PhoneNumberWithLabel] {
        return [PhoneNumberWithLabel]() // TODO
    }
}