//
//  CarMotionViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/8/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class CarMotionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CarDetector.start(true)
        self.navigationController!.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
