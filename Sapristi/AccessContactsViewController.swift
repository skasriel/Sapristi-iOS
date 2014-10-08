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

class AccessContactsViewController: UIViewController, HTTPControllerProtocol {
    
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
        let allContacts: [Contact] = getAllContacts()
        self.performSegueWithIdentifier("fromContactsToMain", sender: allContacts)
    }
    
    func getAllContacts() -> [Contact] {
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
            return processContacts()
        }
        return []
    }
    
    func processContacts() -> [Contact]
    {
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        
        var allContacts: [Contact] = []
        for (index, record:ABRecordRef) in enumerate(contactList) {
            var contact = getAddressbookRecord(record)
            allContacts.append(contact)
        }
        
        let database = FriendLocalDatabase(delegate: nil)
        database.storeToCoreData(allContacts)
        
        sendToServer(allContacts)
        return allContacts
    }
    
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject?) {
        println("TBD")
    }
    
    func sendToServer(allContacts: [Contact]) {
        println("sendToServer: start")
        var params: [Dictionary<String, AnyObject>] = [];
        
        for (i, contact) in enumerate(allContacts) {
            if contact.phoneNumbers.count == 0 {
                continue // only send to server contacts with at least one phone number (otherwise, can't match so no point)
            }
            var dictionary = Dictionary<String, AnyObject>()
            dictionary["displayName"] = contact.displayName
            dictionary["phoneNumbers"] = contact.phoneNumbers
            //dictionary["emailAddresses"] = contact.emailAddresses
            params.append(dictionary)
        }
        println("sendToServer: toJSON")
        let json = HTTPController.JSONStringify(params);
        if (json == "") {
            println("Unable to JSON contacts");
            return;
        }
        println("sendToServer: doPost")
        let httpParams = ["json": json];
        let url = "/api/me/contacts"
        HTTPController.getInstance().doPOST(url, parameters: httpParams, delegate: self, queryID: "UPLOAD_CONTACTS")
        println("sendToServer: end")
    }
        
    func getFromNative(s: Unmanaged<CFString>?) -> String? {
        if (s != nil) {
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

