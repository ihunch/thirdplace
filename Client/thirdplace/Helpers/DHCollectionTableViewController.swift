//
//  DHCollectionTableViewController.swift
//  DHCollectionTableView
//
//  Created by 胡大函 on 14/11/3.
//  Copyright (c) 2014年 HuDahan_payMoreGainMore. All rights reserved.
//

import UIKit

let reuseTableViewCellIdentifier = "TableViewCell"
let reuseCollectionViewCellIdentifier = "CollectionViewCell"
let reuseLocationCollectionViewCellIdentifier = "LocationCollectionViewCell"
let reuseDayTimeCollectionViewCellIdentifier = "DateTimeCollectionViewCell"
class DHCollectionTableViewController: UITableViewController {

    var sourceArray: NSArray!
    var contentOffsetDictionary: NSMutableDictionary!
    
    override func awakeFromNib() {
        self.tableView.registerClass(DHCollectionTableViewCell.self, forCellReuseIdentifier: reuseTableViewCellIdentifier)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.contentOffsetDictionary = NSMutableDictionary()
    }
    convenience init(source: NSMutableArray) {
        self.init()
        self.sourceArray = NSArray(array: source)
    }
}
