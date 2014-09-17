//
//  InitialViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/15/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import UIKit

class InitialViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let isLoggedIn = false; // check whether CoreData says the user is logged in
        
        if (isLoggedIn) {
            println("Do segue to main")
            self.performSegueWithIdentifier("fromLoadingToMain", sender: self)
        } else {
            println("Do segue to registration")
            self.performSegueWithIdentifier("fromLoadingToRegistration", sender: self)
       }
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
