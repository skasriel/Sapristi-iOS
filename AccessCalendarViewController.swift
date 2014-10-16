//
//  AccessCalendarViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/1/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class AccessCalendarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CalendarManager.start(true)

        //calendarManager = CalendarManager(requestPermissions: true)
        
        self.navigationController!.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
