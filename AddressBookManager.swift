//
//  AddressBookManager.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/9/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import AddressBook
import CoreData

protocol AddressBookManagerCallbackProtocol {
    func contactManagerCallback(contacts: [Contact])
}


let addressBookManagerInstance = AddressBookManager()

class AddressBookManager: HTTPControllerProtocol {
    
    class func getInstance() -> AddressBookManager {
            return addressBookManagerInstance
    }
    
    let addressBook = APAddressBook()

    func syncAdressBook(delegate: AddressBookManagerCallbackProtocol) {
        
        addressBook.fieldsMask = APContactField.All //APContactField.Default | APContactField.Thumbnail
        addressBook.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true),
            NSSortDescriptor(key: "lastName", ascending: true)]
        addressBook.filterBlock = {(contact: APContact!) -> Bool in
            return contact.phones.count > 0
        }
        addressBook.loadContacts({ (nativeContacts: [AnyObject]!, error: NSError!) in
            println("loadContacts")
            if (error != nil) {
                let alert = UIAlertView(title: "Unable to sync contacts", message: error.localizedDescription,
                    delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                return;
            }
            var contacts: [Contact] = self.processContacts(nativeContacts as [APContact])
            delegate.contactManagerCallback(contacts)
        })
    }
    
    
    /**
    * Pulls the list of contacts from native address book
    * Uploads them to the server
    * And stores them locally in CoreData, for use by the AllFriends controller
    */
    func processContacts(nativeContacts: [APContact]) -> [Contact] {
        var allContacts: [Contact] = []
        for (index, nativeContact: APContact) in enumerate(nativeContacts) {
            var contact: Contact = getContact(nativeContact)
            //println("#\(index) \(contact.displayName) \(contact.phoneNumbers)")
            allContacts.append(contact)
        }
        
        // store contacts to CoreData (sync)
        let database = FriendLocalDatabase(delegate: nil)
        database.storeToCoreData(allContacts)
        
        // send contacts to server (async)
        sendToServer(allContacts)
        return allContacts
    }
   

    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject?) {
        if let error = err {
            // TODO: handle server errors
            println("Error sending contacts to server: \(error.localizedDescription)")
        }
    }
    
    func sendToServer(allContacts: [Contact]) {
        println("sendToServer: start")
        var params: [Dictionary<String, AnyObject>] = []
        
        for (i, contact) in enumerate(allContacts) {
            if contact.phoneNumbers.count == 0 {
                continue // only send to server contacts with at least one phone number (otherwise, can't match so no point)
            }
            var dictionary = contact.serializeForHTTP()
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
    
    func getContact(nativeContact: APContact) -> Contact {
        var contact = Contact()
        contact.displayName = contactName(nativeContact)
        contact.phoneNumbers = nativeContact.phones as [String]
        let contactID: NSNumber! = nativeContact.recordID
        let fullPhoto: UIImage! = nativeContact.photo
        let thumbnail: UIImage! = nativeContact.thumbnail
        
        if thumbnail != nil {
            contact.thumbnail = thumbnail!
        }
        
        let phonesWithLabels: [AnyObject]! = nativeContact.phonesWithLabels
        if (phonesWithLabels != nil) {
            for (index, phoneWithLabel) in enumerate(phonesWithLabels) {
                let number: String? = phoneWithLabel.phone
                let label: String? = phoneWithLabel.label!
                //println("phone: \(index) \(label) \(number)")
            }
        }
        let socialProfiles: [AnyObject]! = nativeContact.socialProfiles
        if (socialProfiles != nil) {
            for (index, socialProfileObj) in enumerate(socialProfiles) {
                let socialProfile: APSocialProfile = socialProfileObj as APSocialProfile
                let socialNetwork: APSocialNetworkType = socialProfile.socialNetwork
                let username: String? = socialProfile.username
                let userIdentifier: String? = socialProfile.userIdentifier
                let url: NSURL? = socialProfile.url

                println("social: \(index) \(socialNetwork) \(username) \(userIdentifier) \(url)")
            }
        }

        //nativeContact.emails
        return contact
        
    }
    func contactName(contact :APContact) -> String {
        if contact.firstName != nil && contact.lastName != nil {
            return "\(contact.firstName) \(contact.lastName)"
        }
        else if contact.firstName != nil || contact.lastName != nil {
            return (contact.firstName != nil) ? "\(contact.firstName)" : "\(contact.lastName)"
        } else {
            return "Unnamed contact"
        }
    }
}

 