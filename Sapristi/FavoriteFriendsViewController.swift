//
//  FavoriteFriendsViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/9/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class FavoriteFriendsViewController: AllFriendsViewController {

    @IBOutlet weak var nullStateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ConfigManager.setIntConfigValue(CONFIG_SELECTED_TAB, newValue: 0)

        // Need to refresh the list of favorites because it can be modified by other views (e.g. Friend Details)
        fetchFromDatabase()
        refresh()
        
        if countElements(friendLocalDatabase!.localFriends) == 0 {
            // No favorites (yet).
            nullStateLabel.hidden = false
            allFriendsTableView.hidden = true
            
            //self.parentViewController!.performSegueWithIdentifier("fromFavoritesToAll", sender: self)
        } else {
            nullStateLabel.hidden = true
            allFriendsTableView.hidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func fetchFromDatabase() {
        friendLocalDatabase = FriendLocalDatabase(delegate:allFriendsTableView)
        friendLocalDatabase!.fetchFavoritesFromDatabase();
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
