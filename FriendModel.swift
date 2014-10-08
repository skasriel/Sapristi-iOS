//
//  FriendModel.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/26/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import CoreData

@objc(FriendModel)
class FriendModel: NSManagedObject {

    @NSManaged var availability: String
    @NSManaged var displayName: String
    @NSManaged var hasAccount: NSNumber
    @NSManaged var imageName: String
    @NSManaged var phoneNumber: String!
    @NSManaged var allPhoneNumbers: String
    @NSManaged var updatedAt: NSDate

}
