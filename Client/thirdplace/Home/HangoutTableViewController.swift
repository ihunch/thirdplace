//
//  HangoutTableViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 24/09/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class HangoutTableViewController: DHCollectionTableViewController {
    var displayKeyboard = false
    var offset:CGPoint?
    var messageContent: String?
    let leftmargin: CGFloat = 30
    var selectedHangoutFriend : XMPPUserCoreDataStorageObject?
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    var rosterStorage: XMPPRosterCoreDataStorage?
    var xmppStream: XMPPStream?
    var rosterDBContext : NSManagedObjectContext?
    var xmppHangout: XMPPHangout?
    var selectedHangoutID: Int?
    var hangoutDataManager = XMPPHangoutDataManager.singleInstance;
    
    override func awakeFromNib()
    {
       super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "MultiLineTextInputTableViewCell", bundle: nil), forCellReuseIdentifier: "MultiLineTextInputTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        xmppStream = self.appDelegate!.xmppStream
        rosterDBContext = self.appDelegate!.managedObjectContext_roster()
        xmppHangout = self.appDelegate!.xmppHangout
        rosterStorage = self.appDelegate!.xmppRosterStorage
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide:"), name: UIKeyboardDidHideNotification, object: nil)
        displayKeyboard = false
        initDataSource()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initDataSource()
    {
        let me = rosterStorage?.myUserForXMPPStream(xmppStream, managedObjectContext: rosterDBContext)
        self.sourceArray =
        [
            [me!,selectedHangoutFriend!],
            ["Weekend","Saturday","Sunday"],
            ["Afvo","Brunch","Lunch"],//brunch 10:30, lunch 12:00pm afvo 2:00pm
            ["Place1","Place2","Place3"]
        ];
        //TODO: - change the here by reading the data
        self.contentOffsetDictionary.setValue(1, forKey: "1")
        self.contentOffsetDictionary.setValue(1, forKey: "2")
    }
    
    @IBAction func sendHangout(sender: AnyObject)
    {
        //create a temp hangout
        let p_context = hangoutDataManager.privateContext()
        let hangoutid = selectedHangoutID!
        let hangout = Hangout.MR_findFirstByAttribute("hangoutid", withValue: NSNumber(integer: hangoutid), inContext: p_context)
        let me = hangout.getUser(xmppStream!.myJID)
        me!.goingstatus = "going"
        
        let previoustime = hangout.getLatestTime()
        //time
        let hangouttime = HangoutTime.MR_createEntityInContext(p_context)
        hangouttime.startdate = previoustime?.startdate //calculate this based on selection
        hangouttime.enddate = previoustime?.enddate
        hangouttime.timedescription = "Weekend"//based on the selection
        hangouttime.updatejid = xmppStream!.myJID.bare()
        hangouttime.updatetime = NSDate()
        hangouttime.hangout = hangout

        //message
        let message = HangoutMessage.MR_createEntityInContext(p_context)
        message.updatetime = NSDate()
        message.updatejid = xmppStream!.myJID.bare()
        message.hangout = hangout
        message.content = messageContent
        
        //location to do it later
        xmppHangout!.updateHangout(hangout, sender: xmppStream!.myJID)
    }
    
    @IBAction func goback(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
            cell!.textView?.delegate = self
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
            if(indexPath.section == 1)
            {
                collectionCell.collectionView.backgroundColor = UIColor.yellowColor()
            }
            else if (indexPath.section == 2 )
            {
                collectionCell.collectionView.backgroundColor = UIColor.blackColor()
            }
            else
            {
                collectionCell.collectionView.backgroundColor = UIColor.blueColor()
            }
        }
        cell.backgroundColor = UIColor.lightGrayColor()
    }
    
    // MARK: ////////////////////////////////////////
    // MARK: //// KeyboardShow
    // MARK: ////////////////////////////////////////
    func keyboardDidShow (notif: NSNotification)
    {
        if (displayKeyboard) {
            return;
        }
        let info = notif.userInfo as NSDictionary?
        let aValue: NSValue? = info?.objectForKey(UIKeyboardFrameEndUserInfoKey) as? NSValue
        let keyboardSize: CGSize = aValue!.CGRectValue().size
        
        offset = tableView.contentOffset;
        let contentInsets = UIEdgeInsetsMake(tableView.contentInset.top, 0.0, keyboardSize.height, 0.0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
        displayKeyboard = true
    }
    
    func keyboardDidHide(notif: NSNotification)
    {
        if (!displayKeyboard) {
            return;
        }
        UIView.animateWithDuration(0.35, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            let contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 0.0, 0.0)
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
            }, completion: nil)
        displayKeyboard = false
    }
}

extension HangoutTableViewController: UITextViewDelegate
{
    func textViewDidChange(textView: UITextView) {
        messageContent = textView.text
    }
}


// MARK: - Collection View Data source and Delegate
extension HangoutTableViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let collectionViewArray: NSArray = self.sourceArray[collectionView.tag] as! NSArray
        return collectionViewArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCollectionViewCellIdentifier, forIndexPath: indexPath)
        if (collectionView.tag == 0)
        {
            var friendView: UIView? = nil
            if (indexPath.item == 0)
            {
               let me = rosterStorage!.myUserForXMPPStream(xmppStream!, managedObjectContext: rosterDBContext!)
               friendView = FriendView.friendViewWithFriend(me) as? UIView;
            }
            else
            {
                friendView = FriendView.friendViewWithFriend(selectedHangoutFriend) as? UIView;
            }
            friendView!.frame = cell.bounds;
            cell.addSubview(friendView!)
        }
        else
        {
            let label = UILabel(frame: cell.bounds)
            label.backgroundColor = UIColor.redColor()
            label.textAlignment = NSTextAlignment.Center
            label.text = self.sourceArray[collectionView.tag][indexPath.item] as? String
            cell.addSubview(label)
        }
        return cell
    }
    
     func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
     {
        let width = cell.bounds.size.width + leftmargin*2
        let index: NSInteger = collectionView.tag
        let value: AnyObject? = self.contentOffsetDictionary.valueForKey(index.description)
        let horizontalOffset: CGFloat = CGFloat(value != nil ? value!.floatValue : 0)
        collectionView.setContentOffset(CGPointMake(horizontalOffset*width, 0), animated: false)
     }

//
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let itemColor: UIColor = self.sourceArray[collectionView.tag][indexPath.item] as! UIColor
//        //        let vc = UIViewController()
//        //        vc.view.backgroundColor = itemColor
//        //        vc.title = "Line-->\(collectionView.tag)"
//        //        vc.navigationItem.prompt = "Item-->\(indexPath.item)"
//        //        self.navigationController?.pushViewController(vc, animated: true)
//        if UIDevice.currentDevice().systemVersion >= "8.0" {
//            if #available(iOS 8.0, *) {
//                let alert = UIAlertController(title: "第\(collectionView.tag)行", message: "第\(indexPath.item)个元素", preferredStyle: UIAlertControllerStyle.Alert)
//            } else {
//                // Fallback on earlier versions
//            }
//            // alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
//            let v: UIView = UIView(frame: CGRectMake(10, 20, 50, 50))
//            v.backgroundColor = itemColor
//            //  alert.view.addSubview(v)
//            // self.presentViewController(alert, animated: true, completion: nil)
//        }
//    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if !scrollView.isKindOfClass(UICollectionView) {
            return
        }
        let horizontalOffset: CGFloat = scrollView.contentOffset.x
        
        let width = self.view.frame.width
        let collectionView: UICollectionView = scrollView as! UICollectionView
        self.contentOffsetDictionary.setValue(horizontalOffset/width, forKey: collectionView.tag.description)
    }
}



