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
    var delegate: UITableView?
    var localFriends = [FriendModel]()
    //var localFriendMap = Dictionary<String, FriendModel>()
    var needsRefresh: Bool = false

    init(delegate: UITableView?) {
        self.delegate = delegate
    }
    
    func fetch(fetchRequest: NSFetchRequest) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        localFriends = []
        //localFriendMap = Dictionary<String, FriendModel>()
        for var i=0; i < fetchedResultsController.sections![0].numberOfObjects; i++ {
            var indexPath = NSIndexPath(forRow: i, inSection: 0)
            let friend = fetchedResultsController.objectAtIndexPath(indexPath) as FriendModel
            localFriends.append(friend)
            //localFriendMap[friend.phonenumber] = friend // incorrect: phonenumber may not be the user's actual username...
        }
    }
    
    func fetchFromAllDatabase() {
        println("fetchFromAllDatabase")
        let allFriendFetchRequest = NSFetchRequest(entityName: "FriendModel")
        let sortDescriptorAvail = NSSortDescriptor(key: "availability", ascending: true)
        let sortDescriptorFavorite = NSSortDescriptor(key: "isFavorite", ascending: true)
        let sortDescriptorName = NSSortDescriptor(key: "displayName", ascending: true)
        allFriendFetchRequest.sortDescriptors = [sortDescriptorAvail, sortDescriptorFavorite, sortDescriptorName]
        fetch(allFriendFetchRequest)
    }
    
    func fetchFavoritesFromDatabase() {
        println("fetchFavoritesFromDatabase")
        let favoritesFetchRequest = NSFetchRequest(entityName: "FriendModel")
        let predicate = NSPredicate(format: "isFavorite == TRUE", argumentArray: nil)
        let sortDescriptorAvail = NSSortDescriptor(key: "availability", ascending: true)
        let sortDescriptorName = NSSortDescriptor(key: "displayName", ascending: true)
        favoritesFetchRequest.predicate = predicate
        favoritesFetchRequest.sortDescriptors = [sortDescriptorAvail, sortDescriptorName]
        fetch(favoritesFetchRequest)
    }
    
    // Super inefficient way of finding a friend by username...
    func getFriendByUsername(username: String) -> FriendModel? {
        if countElements(localFriends) == 0 {
            fetchFromAllDatabase()
        }
        for (i, friend) in enumerate(localFriends) {
            if friend.phoneNumber == username {
                return friend
            }
        }
        return nil
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> FriendModel {
        return localFriends[indexPath.row]
        //return fetchedResultsController.objectAtIndexPath(indexPath) as FriendModel // friends[indexPath.row]
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return countElements(localFriends)
        //return fetchedResultsController.sections![section].numberOfObjects //friends.count
    }
    
    func sort() {
        println("Sorting local friend database by availability \(countElements(localFriends))")
        localFriends.sort({ (friend0: FriendModel, friend1: FriendModel) -> Bool in
            //$0.availability < $1.availability 
            // Sort by availability first, then by DesiredFrequency and then by name
            if friend0.availability != friend1.availability {
                return friend0.availability < friend1.availability // low availability (by alphabetical order...) at top
            } else if self.getCallFrequency(friend0) != self.getCallFrequency(friend1) {
                return self.getCallFrequency(friend0) > self.getCallFrequency(friend1) // high frequency at top
            } else {
                return friend0.displayName < friend1.displayName
            }
        })
    }
    
    func getCallFrequency(friend: FriendModel) -> Int {
        if let frequenty = friend.desiredCallFrequency {
            return friend.desiredCallFrequency as Int
        } else {
            return 0
        }
    }

    func getDictionary() -> Dictionary<String, FriendModel> {
        //let fetchedArray: [FriendModel] = fetchedResultsController.fetchedObjects as [FriendModel]
        let fetchedArray = localFriends
        var map: Dictionary<String, FriendModel> = Dictionary()
        for (index, friend) in enumerate(fetchedArray) {
            let phoneNumbers = FriendLocalDatabase.getPhoneNumbers(friend)
            for phoneNumber in phoneNumbers {
                var normalizedFriendPhoneNumber = PhoneController.cleanPhoneNumber(phoneNumber) // the server returns e164 phone numbers, so need to clean up my local numbers in order to use them as keys for the dictionary
                map[normalizedFriendPhoneNumber] = friend
            }
        }
        return map
    }
    
    class func getPhoneNumbers(friend: FriendModel) -> [String] {
        let phoneNumbers: [String] = friend.allPhoneNumbers.split(">") as [String]
        return phoneNumbers
    }
    
    
    func storeToCoreData(allContacts: [Contact]) {
        println("storeToCoreData: start")
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        // First delete all stored contacts
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
            let friend: FriendModel = contact.serializeForCoreData(entityDescription, managedObjectContext: managedObjectContext)
        }
        appDelegate.saveContext()
        println("storeToCoreData: end")
    }

    
    /**
    * CoreData Methods for retrieving friend list from local database
    */
    
    /* NSFetchedResultsControllerDelegate implementation */
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        sort()
        if delegate != nil {
            delegate!.reloadData()
        } else {
            println("FriendLocalDatabase doesn't have a delegate")
        }
    }

}