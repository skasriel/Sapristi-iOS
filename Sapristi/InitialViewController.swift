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
    }
    
    func didReceiveAPIResults(err: NSError?, results: NSDictionary?) {
        println("In InitialViewController.didReceiveAPIResults")
        if (err != nil) {
            println("Server error: ") //\(err!.localizedDescription)")
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
    
    @IBAction func buttonPressed(sender: AnyObject) {
        if (true) {
            println("Do segue to main")
            self.performSegueWithIdentifier("fromLoadingToMain", sender: self)
            println("Done segue to main")
        }
    }
}
