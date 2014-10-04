//
//  InitialViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/15/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import UIKit

class InitialViewController: UIViewController, HTTPControllerProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate! as AppDelegate
        appDelegate.carDetector = CarDetector()  // Start the car motion detector
        appDelegate.calendarManager = CalendarManager(requestPermissions: false) // start the calendar manager

        runTests()
    }
    func runTests() {
//        println(HTTPController.cleanPhone("(408) 506 - 0781"))
//        println(HTTPController.cleanPhone("0033146245726"))
//        println(HTTPController.cleanPhone("+33146245726"))
    }
    
    /* HTTPControllerProtocol implementation */
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject?) {
        if let desc = err?.localizedDescription {
            println("Server error: \(desc)")
            self.performSegueWithIdentifier("fromLoadingToRegistration", sender: self)
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("fromLoadingToMain", sender: self)
        })
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)        
        HTTPController.getInstance().doLogin(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var label: UILabel!
}
