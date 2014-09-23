//
//  FriendDetailViewController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/14/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import UIKit

class FriendDetailViewController: UIViewController
{
    var friend: FriendModel!
    
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendUpdateLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendNameLabel.text = friend.displayName
        //friendImageView.image = UIImage(named:friend.imageName)
    }
    @IBAction func addToFavoritesButtonPressed(sender: UIButton) {
    }
    
    @IBAction func unfriendButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.navigationController!.popViewControllerAnimated(true)
    }
}