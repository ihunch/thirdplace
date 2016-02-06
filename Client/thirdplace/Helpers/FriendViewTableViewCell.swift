//
//  FriendViewTableViewCell.swift
//  thirdplace
//
//  Created by Yang Yu on 5/02/2016.
//  Copyright © 2016 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class FriendViewTableViewCell: UITableViewCell {

    @IBOutlet weak var friendView: UIView!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var namelabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        friendView.makeCircular()
        friendView.layer.shadowColor = UIColor.grayColor().CGColor
        friendView.layer.shadowOffset = CGSizeMake(1,3)
        friendView.layer.shadowOpacity = 1
        friendView.layer.shadowRadius = 2.0
        friendView.layer.masksToBounds = false
        friendImageView.layer.cornerRadius = friendImageView.bounds.size.width/2;
        friendImageView.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
