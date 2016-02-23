//
//  MultiLineTextViewTableCell.swift
//  thirdplace
//
//  Created by Yang Yu on 23/02/2016.
//  Copyright © 2016 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class MultiLineTextViewTableCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var bgview: UIView!
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Disable scrolling inside the text view so we enlarge to fitted size
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
