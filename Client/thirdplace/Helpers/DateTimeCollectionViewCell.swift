//
//  DateTimeCollectionViewCell.swift
//  thirdplace
//
//  Created by Yang Yu on 25/01/2016.
//  Copyright © 2016 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class DateTimeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var leftarrow: UIImageView!
    @IBOutlet weak var rightarrow: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib()
    {
        let rightimage = UIImage(named: "chevron")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let leftimage = UIImage(named: "chevron_left")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        leftarrow.image = leftimage
        leftarrow.tintColor = UIColor(white: 0, alpha: 0.5)
        rightarrow.image = rightimage
        rightarrow.tintColor = UIColor(white: 0, alpha: 0.5)
    }
}
