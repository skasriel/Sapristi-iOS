//
//  SettingsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/12/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var logoutTableViewCell: UITableViewCell!
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (sender as NSObject! == logoutTableViewCell) {
            println("Logout here...")
            let userDefaults = NSUserDefaults.standardUserDefaults();
            userDefaults.removeObjectForKey("username")
            userDefaults.removeObjectForKey("authToken")
            userDefaults.synchronize()
            // TODO: Other values to delete here? Clear CoreData?
            HTTPController.getInstance().doGET("/api/auth/logout", delegate: nil, queryID: nil)
        }
        println("prepareForSegue: \(sender) \(segue)")
    }


}

