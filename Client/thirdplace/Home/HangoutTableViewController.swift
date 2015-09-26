//
//  HangoutTableViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 24/09/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class HangoutTableViewController: DHCollectionTableViewController {
 
    let leftmargin: CGFloat = 30
     override func awakeFromNib()
    {
       super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDataSource()
        tableView.registerNib(UINib(nibName: "MultiLineTextInputTableViewCell", bundle: nil), forCellReuseIdentifier: "MultiLineTextInputTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initDataSource()
    {
        self.sourceArray = [
            ["Friend1","Friend2"],
            ["Weekend","Saturday","Sunday"],
            ["Afvo","Brunch","Lunch"],
            ["Place1","Place2","Place3"]
        ];
    }
}

// MARK: - Table view data source
extension HangoutTableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if (indexPath.section == 0)
        {
            return 70
        }
        else if(indexPath.section == 1 || indexPath.section == 2)
        {
            return 44
        }
        else if(indexPath.section == 3)
        {
            return 150
        }
        else if(indexPath.section == 4)
        {
            return UITableViewAutomaticDimension
        }
        else
        {
            return 50
        }
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (indexPath.section > 4)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("EditHangoutControlPanel") 
            return cell!
        }
        else if (indexPath.section == 4)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("MultiLineTextInputTableViewCell", forIndexPath: indexPath) as? MultiLineTextInputTableViewCell
            cell!.titleLabel?.text = "Multi line cell"
            cell!.textString = "Test String\nAnd another string\nAnd another"
            return cell!
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseTableViewCellIdentifier, forIndexPath: indexPath) as! DHCollectionTableViewCell
            if (indexPath.section != 0)
            {
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()  
                layout.minimumLineSpacing = leftmargin*2
                layout.sectionInset = UIEdgeInsetsMake(0, leftmargin, 0, leftmargin)
                layout.itemSize = CGSizeMake(cell.bounds.size.width - leftmargin*2, cell.bounds.size.height - 1)
                layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
                cell.collectionView.collectionViewLayout = layout
            }
            else
            {
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.minimumLineSpacing = 10
                layout.sectionInset = UIEdgeInsetsMake(0, leftmargin, 0, 0)
                layout.itemSize = CGSizeMake(cell.bounds.size.height - 10, cell.bounds.size.height - 10)
                layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
                cell.collectionView.collectionViewLayout = layout
            }
            return cell
        }
    }
        
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (indexPath.section <= 3)
        {
            let collectionCell: DHCollectionTableViewCell = cell as! DHCollectionTableViewCell
            collectionCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, index: indexPath.section)
            let index: NSInteger = collectionCell.collectionView.tag
            let value: AnyObject? = self.contentOffsetDictionary.valueForKey(index.description)
            let horizontalOffset: CGFloat = CGFloat(value != nil ? value!.floatValue : 0)
            collectionCell.collectionView.setContentOffset(CGPointMake(horizontalOffset, 0), animated: false)
        }
    }
}

// MARK: - Collection View Data source and Delegate
extension HangoutTableViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let collectionViewArray: NSArray = self.sourceArray[collectionView.tag] as! NSArray
        return collectionViewArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCollectionViewCellIdentifier, forIndexPath: indexPath)
        if (collectionView.tag == 0)
        {
            let friendView = FriendView.addFriendView() as? UIView;
            friendView!.frame = cell.bounds;
            cell.addSubview(friendView!)
        }
        else
        {
            print(indexPath.item)
            let label = UILabel(frame: cell.bounds)
            label.backgroundColor = UIColor.redColor()
            label.textAlignment = NSTextAlignment.Center
            label.text = self.sourceArray[collectionView.tag][indexPath.item] as? String
            cell.addSubview(label)
        }
        print(cell.bounds)
        //cell.backgroundColor = collectionViewArray[indexPath.item] as? UIColor
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let itemColor: UIColor = self.sourceArray[collectionView.tag][indexPath.item] as! UIColor
        //        let vc = UIViewController()
        //        vc.view.backgroundColor = itemColor
        //        vc.title = "Line-->\(collectionView.tag)"
        //        vc.navigationItem.prompt = "Item-->\(indexPath.item)"
        //        self.navigationController?.pushViewController(vc, animated: true)
        if UIDevice.currentDevice().systemVersion >= "8.0" {
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "第\(collectionView.tag)行", message: "第\(indexPath.item)个元素", preferredStyle: UIAlertControllerStyle.Alert)
            } else {
                // Fallback on earlier versions
            }
            // alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            let v: UIView = UIView(frame: CGRectMake(10, 20, 50, 50))
            v.backgroundColor = itemColor
            //  alert.view.addSubview(v)
            // self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if !scrollView.isKindOfClass(UICollectionView) {
            return
        }
        let horizontalOffset: CGFloat = scrollView.contentOffset.x
        let collectionView: UICollectionView = scrollView as! UICollectionView
        self.contentOffsetDictionary.setValue(horizontalOffset, forKey: collectionView.tag.description)
    }
}



