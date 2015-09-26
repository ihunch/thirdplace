//
//  FriendContainerTableViewCell.swift
//  thirdplace
//
//  Created by Yang Yu on 17/09/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class FriendContainerTableViewCell: UITableViewCell
{
    @IBOutlet weak var friendContainerView: FriendContainerView!
    
    override func setNeedsLayout() {
    }
    
    func setDelegate(delegate:FriendContainerViewDelegate)
    {
        if ( self.friendContainerView.delegate == nil)
        {
            self.friendContainerView.delegate = delegate
        }
    }
}
