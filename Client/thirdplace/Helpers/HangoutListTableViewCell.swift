//
//  HangoutListTableViewCell.swift
//  thirdplace
//
//  Created by Yang Yu on 23/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class HangoutListTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: DHIndexedCollectionView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var labelViewContainer: UIView!
    @IBOutlet weak var bgimageview: UIImageView!
    @IBOutlet weak var locationViewContainer: UIView!
    @IBOutlet weak var mapbutton: UIButton!
    @IBOutlet weak var middlesection: UIView!
    @IBOutlet weak var mapheightconstraint: NSLayoutConstraint!
    @IBOutlet weak var topvalueconstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionViewCellIdentifier as String)
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.pagingEnabled = true
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(90, 5, 4, 5)
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSizeMake(65, 65)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.collectionView.collectionViewLayout = layout
        let image = UIImage(named: "btn_icn_Zoo-Map")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        mapbutton.setImage(image, forState: UIControlState.Normal)
        mapbutton.tintColor = AppConfig.blueColour()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: protocol<UICollectionViewDelegate,UICollectionViewDataSource>, index: NSInteger) {
        self.collectionView.dataSource = delegate
        self.collectionView.delegate = delegate
        self.collectionView.tag = index
        self.collectionView.reloadData()
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: protocol<UICollectionViewDelegate,UICollectionViewDataSource>, indexPath: NSIndexPath) {
        self.collectionView.dataSource = delegate
        self.collectionView.delegate = delegate
        self.collectionView.indexPath = indexPath
        self.collectionView.tag = indexPath.section
        self.collectionView.reloadData()
    }

}
