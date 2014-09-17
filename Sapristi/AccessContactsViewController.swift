//
//  AccessContactsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/15/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import UIKit
import AddressBook
import CoreData

class AccessContactsViewController: UIViewController {
    
    var authDone = false
    var adbk: ABAddressBook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // TODO: also register callback with ABAddressBookRegisterExternalChangeCallback and ABExternalChangeCallback
    
    // From http://stackoverflow.com/questions/24752627/accessing-ios-address-book-with-swift-array-count-of-zero
    @IBAction func accessContactsButtonPressed(sender: UIButton) {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        if (authorizationStatus == ABAuthorizationStatus.NotDetermined)
        {
            NSLog("requesting access...")
            var emptyDictionary: CFDictionaryRef?
            var addressBook = !(ABAddressBookCreateWithOptions(emptyDictionary, nil) != nil)
            ABAddressBookRequestAccessWithCompletion(addressBook, {success, error in
                if success {
                    self.processContacts();
                } else {
                    NSLog("unable to request access")
                }
            })
        } else if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {
            NSLog("access denied")
        } else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            NSLog("access granted")
            processContacts()
        }
    }
    
    func processContacts()
    {
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        println("records in the contacts array \(contactList.count)")
        
        var allContacts: [Contact] = []
        for (index, record:ABRecordRef) in enumerate(contactList) {
            println("Index # \(index) \(record)")
            var contact = getAddressbookRecord(record)
            allContacts.append(contact)
        }
        
        storeToCoreData(allContacts)

        self.performSegueWithIdentifier("fromContactsToMain", sender: allContacts)
    }
    
    func storeToCoreData(allContacts: [Contact]) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FriendModel", inManagedObjectContext: managedObjectContext)
        for (index, contact) in enumerate(allContacts) {
            let friend = FriendModel(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
            friend.displayName = contact.displayName
            if contact.phoneNumbers.count>0 {
                friend.phoneNumber = contact.phoneNumbers[0]
            } else {
                friend.phoneNumber = "xxx"
            }
            friend.hasAccount = false // TBD
            friend.availability = Availability.UNKNOWN // TBD
            //friend.allPhoneNumbers = nil
        }
        appDelegate.saveContext()
        
        var request = NSFetchRequest(entityName: "FriendModel")
        var error: NSError? = nil
        var results: NSArray = managedObjectContext!.executeFetchRequest(request, error: &error)
        for res in results {
            println("res = \(res)")
        }
    }
    
    /*override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue!.identifier == "fromContactsToMain" {
            println("destination = \(segue!.destinationViewController)")
            let destinationTabContainer: UITabBarController = segue!.destinationViewController as UITabBarController
            let destinationNavigationContainer: UINavigationController = destinationTabContainer.viewControllers[0] as UINavigationController
            let destinationVC: FirstViewController = destinationNavigationContainer.viewControllers[0] as FirstViewController
            destinationVC.allContacts = sender as [Contact]
        }
    }*/
    
    func getFromNative(s: Unmanaged<CFString>?) -> String? {
        if (s != nil) {
            println("Native = \(s)")
            var cfs:CFString = s!.takeRetainedValue()
            var nfs: NSString = cfs as NSString
            if nfs.length == 0 {
                return ""
            }
            var s: String = "" + nfs //nfs as String?
            return s
        } else {
            return nil
        }
    }

    
    func getAddressbookRecord(addressBookRecord: ABRecordRef) -> Contact {
        //var lastName: String = ABRecordCopyValue(addressBookRecord, kABPersonLastNameProperty).takeRetainedValue() as NSString // kABPersonPhoneProperty
        //NSLog("LastName: \(lastName)")
        
        //var contactName: String = ABRecordCopyCompositeName(addressBookRecord).takeRetainedValue() as NSString
        var contactName: String? = getFromNative(ABRecordCopyCompositeName(addressBookRecord))
        
        NSLog("contactName: \(contactName)")
        var contact = Contact()
        contact.displayName = contactName!
        var emails = getEmailAddresses(addressBookRecord)
        contact.emailAddresses = emails
        var phones = getPhoneNumbers(addressBookRecord)
        contact.phoneNumbers = phones
        return contact
    }

    func getPhoneNumbers(addressBookRecord: ABRecordRef) -> [String] {
        return getABList(addressBookRecord, property: kABPersonPhoneProperty);
    }
    
    func getABList(addressBookRecord: ABRecordRef, property: ABPropertyID) -> [String] {
        var results: [String] = []
        let nativeArray:ABMultiValueRef = extractABRef(ABRecordCopyValue(addressBookRecord, property))!
        for (var j = 0; j < ABMultiValueGetCount(nativeArray); ++j) {
            var nativeEntry = ABMultiValueCopyValueAtIndex(nativeArray, j)
            var entry = extractABFromRef(nativeEntry)
            results.append(entry!)
        }
        return results
    }
    
    func getEmailAddresses(addressBookRecord: ABRecordRef) -> [String] {
        return getABList(addressBookRecord, property: kABPersonEmailProperty)
    }
    
    
    func extractABRef (abRef: Unmanaged<ABMultiValueRef>!) -> ABMultiValueRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    func extractABFromRef (abRef: Unmanaged<AnyObject>!) -> String? {
        if let ab = abRef {
            return Unmanaged.fromOpaque(abRef.toOpaque()).takeUnretainedValue() as CFStringRef as NSString
        }
        return nil
    }
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
}

