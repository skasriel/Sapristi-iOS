//
//  SyncContactsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/1/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class SyncContactsViewController: AccessContactsViewController, AddressBookManagerCallbackProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        AddressBookManager.getInstance().syncAdressBook(self)
    }

    /** 
    * Implementation of AddressBookManagerCallbackProtocol
    */
    override func contactManagerCallback(contacts: [Contact]) {
        // need to do this from main thread through dispatch_async?
        println("Done updating all contacts, now redirect back to Settings")
        self.navigationController!.popViewControllerAnimated(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
