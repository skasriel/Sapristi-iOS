//
//  AccessContactsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/15/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import UIKit

class AccessContactsViewController: UIViewController, AddressBookManagerCallbackProtocol {
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
        AddressBookManager.getInstance().syncAdressBook(self)
    }
    
    /**
    * Implementation of AddressBookManagerCallbackProtocol
    */
    func contactManagerCallback(contacts: [Contact]) {
        // need to do this from main thread through dispatch_async?
        self.performSegueWithIdentifier("fromContactsToMain", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if "fromContactsToMain" == segue.identifier  {
            let tabVC = segue.destinationViewController as UITabBarController
            let selectedTab = ConfigManager.getIntConfigValue(CONFIG_SELECTED_TAB, defaultValue: 1)
            tabVC.selectedIndex = selectedTab
        }
    }
    
}

