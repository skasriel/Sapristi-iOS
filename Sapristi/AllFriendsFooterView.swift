//
//  AllFriendsFooterView.swift
//  Sapristi
//
//  Created by Cedric Sellin on 12/3/14.
//  Copyright (c) 2014 Sapristi. All rights reserved.
//

import Foundation
import UIKit

class AllFriendsFooterView: UIView {

    var allFriendsController : AllFriendsViewController?

    @IBAction func InviteContactTouchUpInside() {
        //Call back the parent VC to let him know of the click
        allFriendsController?.clickedOnInviteFriends()
    }
}