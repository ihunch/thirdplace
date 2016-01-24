//
//  LocationCollectionViewCell.swift
//  thirdplace
//
//  Created by Yang Yu on 13/12/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class LocationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var addresslabel: UILabel!
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var addressContainer: UIView!
    @IBOutlet weak var leftarrow: UIImageView!
    @IBOutlet weak var rightarrow: UIImageView!
    
    override func awakeFromNib()
    {
        let rightimage = UIImage(named: "chevron")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let leftimage = UIImage(named: "chevron_left")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        leftarrow.image = leftimage
        leftarrow.tintColor = UIColor(white: 1, alpha: 0.5)
        rightarrow.image = rightimage
        rightarrow.tintColor = UIColor(white: 1, alpha: 0.5)
    }
}
