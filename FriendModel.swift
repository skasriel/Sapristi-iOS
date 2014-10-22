//
//  FriendModel.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/21/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import CoreData

@objc(FriendModel)
class FriendModel: NSManagedObject {

    @NSManaged var allPhoneNumbers: String!
    @NSManaged var availability: String!
    @NSManaged var desiredCallFrequency: NSNumber!
    @NSManaged var displayName: String!
    @NSManaged var hasAccount: NSNumber!
    @NSManaged var imageName: String!
    @NSManaged var isFavorite: NSNumber!
    @NSManaged var phoneNumber: String!
    @NSManaged var updatedAt: NSDate!
    @NSManaged var thumbnail: NSData!

}

/*
//
//  FriendModel.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/9/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import CoreData

class FriendModel: NSManagedObject {

@NSManaged var allPhoneNumbers: String!
@NSManaged var availability: String!
@NSManaged var displayName: String!
@NSManaged var hasAccount: NSNumber!
@NSManaged var desiredCallFrequency: NSNumber!
@NSManaged var imageName: String!
@NSManaged var phoneNumber: String!
@NSManaged var updatedAt: NSDate!
@NSManaged var isFavorite: NSNumber?

}*/
