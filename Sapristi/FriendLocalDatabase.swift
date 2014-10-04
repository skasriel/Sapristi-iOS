//
//  FriendLocalDatabase.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/24/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FriendLocalDatabase: NSFetchedResultsControllerDelegate {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController()
    let delegate: UITableView?

    init(delegate: UITableView?) {
        self.delegate = delegate
    }
    func fetchFromDatabase() {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: friendFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> FriendModel {
        return fetchedResultsController.objectAtIndexPath(indexPath) as FriendModel // friends[indexPath.row]
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects //friends.count        
    }

    func getDictionary() -> Dictionary<String, FriendModel> {
        let fetchedArray: [FriendModel] = fetchedResultsController.fetchedObjects as [FriendModel]
        var map: Dictionary<String, FriendModel> = Dictionary()
        for (index, friend) in enumerate(fetchedArray) {
            var normalizedFriendPhoneNumber = HTTPController.cleanPhone(friend.phoneNumber) // the server returns e164 phone numbers, so need to clean up my local numbers in order to use them as keys for the dictionary
            map[normalizedFriendPhoneNumber] = friend
        }
        return map
    }
    
    
    func storeToCoreData(allContacts: [Contact]) {
        println("storeToCoreData: start")
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        // First delete all stored contacts (normally, there shouldn't be any, but better safe than sorry)
        let fetchRequest = NSFetchRequest(entityName: "FriendModel")
        let sortDescriptor = NSSortDescriptor(key: "displayName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        var err: NSError?
        let fetchStatus = fetchedResultsController.performFetch(&err)
        var fetchArray = fetchedResultsController.fetchedObjects!
        for entry in fetchArray {
            managedObjectContext!.deleteObject(entry as NSManagedObject)
        }
        managedObjectContext!.save(nil)
        
        // Now store all new contacts
        let entityDescription = NSEntityDescription.entityForName("FriendModel", inManagedObjectContext: managedObjectContext!)
        for (index, contact) in enumerate(allContacts) {
            if contact.phoneNumbers.count==0 {
                continue; // don't save contacts who don't have a phone number
            }
            let friend = FriendModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
            friend.displayName = contact.displayName
            friend.phoneNumber = contact.phoneNumbers[0] as String
            friend.hasAccount = false // TBD
            friend.availability = Availability.UNKNOWN // TBD
            var allPhoneNumbers = "";
            for (i, number) in enumerate(contact.phoneNumbers) {
                if (i>0) {
                    allPhoneNumbers += ">" // separate all phone numbers with a special character... (a small hack)
                }
                allPhoneNumbers += number as String
            }
            friend.allPhoneNumbers = allPhoneNumbers
        }
        appDelegate.saveContext()
        println("storeToCoreData: end")
    }

    
    /**
    * CoreData Methods for retrieving friend list from local database
    */
    func friendFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "FriendModel")
        let sortDescriptorAvail = NSSortDescriptor(key: "availability", ascending: true)
        let sortDescriptorName = NSSortDescriptor(key: "displayName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorAvail, sortDescriptorName]
        return fetchRequest
    }
    /* NSFetchedResultsControllerDelegate implementation */
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        if delegate != nil {
            delegate!.reloadData()
        } else {
            println("FriendLocalDatabase doesn't have a delegate")
        }
    }

}