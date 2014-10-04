//
//  SyncContactsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/1/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class SyncContactsViewController: AccessContactsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        super.getAllContacts()
        println("Done, now redirect")
        self.navigationController!.popViewControllerAnimated(true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
