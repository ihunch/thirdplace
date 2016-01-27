//
//  HangoutFriendViewStaticCell.swift
//  thirdplace
//
//  Created by Yang Yu on 22/01/2016.
//  Copyright © 2016 Hunch Pty Ltd. All rights reserved.
//

import Foundation

class HangoutFriendViewStaticCell: UITableViewCell {
    
@IBOutlet weak var collectionView: DHIndexedCollectionView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionViewCellIdentifier as String)
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.pagingEnabled = true
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(4, 5, 4, 5)
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSizeMake(65, 65)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.collectionView.collectionViewLayout = layout
        self.collectionView.showsHorizontalScrollIndicator = false
        collectionView!.layer.shadowColor = UIColor.grayColor().CGColor
        collectionView!.layer.shadowOffset = CGSizeMake(1, 3)
        collectionView!.layer.shadowOpacity = 1
        collectionView!.layer.shadowRadius = 2.0
        collectionView!.layer.masksToBounds = false
        
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