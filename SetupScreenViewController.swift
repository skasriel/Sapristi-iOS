//
//  SetupScreenViewController.swift
//  Sapristi
//
//  Created by Michal Sellin on 12/10/14.
//  Copyright (c) 2014 Sapristi. All rights reserved.
//

import UIKit

class SetupScreenViewController: UIViewController {

    @IBOutlet var skipButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func skipButtonPressed(sender: AnyObject) {
        var childControllers : [UIViewController] = self.navigationController?.childViewControllers as [UIViewController];
        if ((childControllers.count > 1) &&
            childControllers[0].isKindOfClass(SettingsViewController)) {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        var mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var nextVC:UITabBarController = mainStoryboard.instantiateInitialViewController() as UITabBarController
        self.navigationController?.presentViewController(nextVC, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
