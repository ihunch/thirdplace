//
//  DHCollectionTableViewCell.swift
//  DHCollectionTableView
//
//  Created by 胡大函 on 14/11/3.
//  Copyright (c) 2014年 HuDahan_payMoreGainMore. All rights reserved.
//

import UIKit

class DHIndexedCollectionView: UICollectionView {
    
    var indexPath: NSIndexPath!
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.pagingEnabled = true
    }
}

let collectionViewCellIdentifier: NSString = "CollectionViewCell"
let locationViewCellIdentifier: NSString = "LocationCollectionViewCell"
let daytimeViewCellIdentifier: NSString = "DateTimeCollectionViewCell"
class DHCollectionTableViewCell: UITableViewCell {

    var collectionView: DHIndexedCollectionView!
    var frameView: UIView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(91, 91)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.collectionView = DHIndexedCollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionViewCellIdentifier as String)
       
        self.collectionView.registerNib(UINib(nibName: "LocationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: locationViewCellIdentifier as String)
        self.collectionView.registerNib(UINib(nibName: "DateTimeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: daytimeViewCellIdentifier as String)
        self.collectionView.showsHorizontalScrollIndicator = false
        collectionView!.layer.shadowColor = UIColor.grayColor().CGColor
        collectionView!.layer.shadowOffset = CGSizeMake(1, 3)
        collectionView!.layer.shadowOpacity = 1
        collectionView!.layer.shadowRadius = 2.0
        collectionView!.layer.masksToBounds = false
        self.contentView.addSubview(self.collectionView)
        
        self.frameView = UIView(frame: CGRectZero)
        self.frameView.backgroundColor = UIColor.clearColor()
        self.frameView.selectiveBorderFlag =  UInt(AUISelectiveBordersFlagTop | AUISelectiveBordersFlagBottom | AUISelectiveBordersFlagLeft | AUISelectiveBordersFlagRight)
        frameView.selectiveBordersColor = UIColor.yellowColor()
        frameView.selectiveBordersWidth = 3
        self.contentView.addSubview(frameView)
        self.contentView.bringSubviewToFront(self.collectionView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.contentView.bounds
        self.collectionView.frame = CGRectMake(0, 3, frame.size.width, frame.size.height-6)
        self.frameView.frame = CGRectMake(30, 0, frame.size.width - 58, frame.size.height)
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
