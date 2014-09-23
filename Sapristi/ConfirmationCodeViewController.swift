//
//  ConfirmationCodeViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/15/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import UIKit

class ConfirmationCodeViewController: UIViewController, HTTPControllerProtocol {
    
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmationCodeTextField.becomeFirstResponder()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showError(error: String) {
        errorMessageLabel.text = error
        errorMessageLabel.hidden = false
        println("showError: \(error)")
    }

    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject?) {
        if (err != nil) {
            showError("Server error: \(err!.localizedDescription)")
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("fromConfirmToContacts", sender: self)
            //self.tableData = resultsArr
            //self.appsTableView!.reloadData()
        })
    }

    
    @IBAction func confirmButtonPressed(sender: UIButton) {
        errorMessageLabel.hidden = true
        var url = "/api/auth/confirmation-code"
        var formData: [String: AnyObject] = [
            "confirmationCode":  confirmationCodeTextField.text,
        ]
        
        HTTPController.getInstance().doPOST(url, parameters: formData, delegate: self, queryID: "CONFIRMATION_CODE")

    }
    
}

