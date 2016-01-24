//
//  HangoutTableViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 24/09/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class HangoutTableViewController: DHCollectionTableViewController {
    
    @IBOutlet weak var pagebackbutton: UIButton!
    @IBOutlet weak var sendbutton: UIButton!
    let reuseFriendCellIdentifier = "friendstaticcell"
    var displayKeyboard = false
    var offset:CGPoint?
    var messageContent: String?
    let leftmargin: CGFloat = 0
    let offsetLeftMargin: CGFloat = 30
    let offsetRightMargin: CGFloat = 30
    var selectedHangoutFriend : XMPPUserCoreDataStorageObject?
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    var rosterStorage: XMPPRosterCoreDataStorage?
    var xmppStream: XMPPStream?
    var rosterDBContext : NSManagedObjectContext?
    var xmppHangout: XMPPHangout?
    var selectedHangoutID: Int?
    var hangoutDataManager = XMPPHangoutDataManager.singleInstance;
    let dayrow = "1"
    let timerow = "2"
    let placerow = "3"
    let placelocationtag = 999
    let ownphototag = 1000
    let friendtag = 1001
    let placelocationimagetag = 1002
    let placelocatinaddresstag = 1003
    let leftarrowtag = 1004
    let rightarrowtag = 1005
    var locationdata: NSArray?
    
    var hangoutmodule : XMPPHangout{
        get{
            return self.appDelegate!.xmppHangout
        }
    }
    
    override func awakeFromNib()
    {
       super.awakeFromNib()
    }
    
    deinit
    {
        hangoutmodule.removeDelegate(self)
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
        hangoutmodule.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
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
        let dayarray = XMPPHangoutDataManager.initHangoutDayData()
        let timearray = XMPPHangoutDataManager.initHangoutTimeData()
        locationdata = XMPPHangoutDataManager.initLocationData()
        let me = rosterStorage?.myUserForXMPPStream(xmppStream, managedObjectContext: rosterDBContext)
 
        //TODO: - change place data
        let p_context = hangoutDataManager.privateContext()
        let hangoutid = selectedHangoutID!
        let hangout = Hangout.MR_findFirstByAttribute("hangoutid", withValue: NSNumber(integer: hangoutid), inContext: p_context)
        
        let preferlocation = hangout.preferedlocation
        let locationstring = preferlocation!.componentsSeparatedByString(",")
        self.sourceArray =
            [
                [me!,selectedHangoutFriend!],
                dayarray,
                timearray,
                [locationstring[0],locationstring[1],locationstring[2]]
        ];
        let time = hangout.getLatestTime()
        let startday = time?.startdate!.mt_weekdayOfWeek()
        let endday =  time?.enddate!.mt_weekdayOfWeek()
        let hour = time?.startdate!.mt_hourOfDay()
        if(startday != endday)
        {
            self.contentOffsetDictionary.setValue(0, forKey: dayrow)
        }
        else
        {
            if(startday == Weekday.Sat.rawValue) //Saturday
            {
                self.contentOffsetDictionary.setValue(1, forKey: dayrow)
            }
            else
            {
                self.contentOffsetDictionary.setValue(2, forKey: dayrow)
            }
        }
        if (hour > 0)
        {
            if (hour == 10)
            {
                self.contentOffsetDictionary.setValue(0, forKey: timerow)
            }
            else if(hour == 14)
            {
                self.contentOffsetDictionary.setValue(2, forKey: timerow)
            }
            else
            {
                self.contentOffsetDictionary.setValue(1, forKey: timerow)
            }
        }
        else
        {
             self.contentOffsetDictionary.setValue(0, forKey: timerow)
        }
        if let location = hangout.getLatestLocation()
        {
            let index = sourceArray[3].indexOfObject((location.locationid?.stringValue)!)
            self.contentOffsetDictionary.setValue(index, forKey: placerow)
        }
        else
        {
            self.contentOffsetDictionary.setValue(0, forKey: placerow)
        }
    }
    
    @IBAction func sendHangout(sender: AnyObject)
    {
        self.showloadscreen()
        let createtime = NSDate().mt_inTimeZone(NSTimeZone.localTimeZone())
        //create a temp hangout
        let p_context = hangoutDataManager.privateContext()
        let hangoutid = selectedHangoutID!
        let hangout = Hangout.MR_findFirstByAttribute("hangoutid", withValue: NSNumber(integer: hangoutid), inContext: p_context)
        let me = hangout.getUser(xmppStream!.myJID)
        me!.goingstatus = "going"
        let selectdayindex = self.contentOffsetDictionary[dayrow] as! Int
        let selecttimeindex = self.contentOffsetDictionary[timerow] as! Int
        let selectlocationindex = self.contentOffsetDictionary[placerow] as! Int
        let day = self.sourceArray[Int(dayrow)!][selectdayindex] as! Hangout_Day
        let time = self.sourceArray[Int(timerow)!][selecttimeindex] as! Hangout_Time
        let locationid = self.sourceArray[Int(placerow)!][selectlocationindex] as! String
        let hangouttime = HangoutTime.MR_createEntityInContext(p_context)
        let sundaymidnight = hangout.getLatestTime()!.enddate!.calculateSundayMidnightTime()
        let sundayendtime = sundaymidnight.mt_dateHoursAfter(23).mt_dateMinutesAfter(59)
        if (day.dayvalue == 7) // Saturday
        {
            hangouttime.startdate = sundaymidnight.mt_dateDaysBefore(1).mt_dateHoursAfter(Int(time.time!))
            hangouttime.enddate = sundayendtime.mt_oneDayPrevious()
        }
        else if(day.dayvalue == 1) //Sunday
        {
            hangouttime.startdate = sundaymidnight.mt_dateHoursAfter(Int(time.time!))
            hangouttime.enddate = sundayendtime
        }
        else
        {
            //work out the time only
            let satmid = sundaymidnight.mt_dateDaysBefore(1)
            hangouttime.startdate = satmid.mt_dateHoursAfter(Int(time.time!))
            hangouttime.enddate = sundayendtime
        }
        
        let startdatedes = hangouttime.startdate?.mt_stringFromDateWithFormat("dd/MM", localized: true)
        var daydes = day.day_description!
        if (daydes == "Weekend")
        {
            daydes = "This \(daydes)"
        }
        //time
        if (startdatedes != nil)
        {
            hangouttime.timedescription = "\(daydes), \(time.time_description!) (\(startdatedes!))"//based on the selection
        }
        else
        {
            hangouttime.timedescription = "\(daydes), \(time.time_description!)"
        }
        hangouttime.updatejid = xmppStream!.myJID.bare()
        hangouttime.updatetime = createtime
        hangouttime.hangout = hangout

        //location to do it later
        let location = HangoutLocation.MR_createEntityInContext(p_context)
        location.updatejid = xmppStream!.myJID.bare()
        location.updatetime = createtime
        location.locationconfirm = NSNumber(bool: false)
        location.locationid = NSNumber(integer: Int(locationid)!)
        location.hangout = hangout
        
        //message
        let message = HangoutMessage.MR_createEntityInContext(p_context)
        message.updatetime = createtime
        message.updatejid = xmppStream!.myJID.bare()
        message.hangout = hangout
        message.content = messageContent
        
        xmppHangout!.updateHangout(hangout, sender: xmppStream!.myJID)
    }
    
    @IBAction func goback(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showloadscreen()
    {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.hide(true, afterDelay: 10.0)
    }
    
    func dismissloadscreen()
    {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
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
            return 50
        }
        else if(indexPath.section == 3)
        {
            return 180
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
            cell!.textView?.placeholder = "Insert personal message"
            cell!.titleLabel?.text = ""
            cell!.textString = ""
            cell!.bgview.selectiveBorderFlag = UInt(AUISelectiveBordersFlagTop | AUISelectiveBordersFlagBottom | AUISelectiveBordersFlagLeft | AUISelectiveBordersFlagRight)
            cell!.bgview.selectiveBordersColor = UIColor.lightGrayColor()
            cell!.bgview.selectiveBordersWidth = 1
            
            cell!.bgview.layer.shadowColor = UIColor.grayColor().CGColor
            cell!.bgview.layer.shadowOffset = CGSizeMake(1,3)
            cell!.bgview.layer.shadowOpacity = 1
            cell!.bgview.layer.shadowRadius = 3.0
            cell!.bgview.layer.masksToBounds = false
            return cell!
        }
        else
        {
            if (indexPath.section != 0)
            {
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseTableViewCellIdentifier, forIndexPath: indexPath) as! DHCollectionTableViewCell
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()  
                layout.minimumLineSpacing = 15
                layout.sectionInset = UIEdgeInsetsMake(0, offsetLeftMargin, 0, offsetRightMargin)
                layout.itemSize = CGSizeMake(cell.bounds.size.width - 60, cell.bounds.size.height - 6)
                layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
                cell.collectionView.collectionViewLayout = layout
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseFriendCellIdentifier, forIndexPath: indexPath) as! HangoutFriendViewStaticCell
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.minimumLineSpacing = 10
                layout.sectionInset = UIEdgeInsetsMake(0, offsetLeftMargin, 0, 0)
                layout.itemSize = CGSizeMake(cell.bounds.size.height - 10, cell.bounds.size.height - 10)
                layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
                cell.collectionView.collectionViewLayout = layout
                return cell
            }
        }
    }
        
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (indexPath.section <= 3)
        {
            if (indexPath.section == 0)
            {
                let friendCell: HangoutFriendViewStaticCell = cell as! HangoutFriendViewStaticCell
                friendCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, index: indexPath.section)
                friendCell.collectionView.backgroundColor = UIColor.clearColor()
            }
            else
            {
                let collectionCell: DHCollectionTableViewCell = cell as! DHCollectionTableViewCell
                collectionCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, index: indexPath.section)
                collectionCell.collectionView.backgroundColor = UIColor.clearColor()
            }
        }
        cell.backgroundColor = AppConfig.themebgcolour()
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = AppConfig.themebgcolour()
        return view
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
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.max))
        
        // Resize the cell only when cell's size is changed
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            if let tableviewcell = textView.superview!.superview as? UITableViewCell
            {
                if let thisIndexPath = tableView.indexPathForCell(tableviewcell) {
                    tableView?.scrollToRowAtIndexPath(thisIndexPath, atScrollPosition: .Bottom, animated: false)
                }
            }
        }
    }
}

// MARK: - Collection View Data source and Delegate
//TODO - it's better to use customcollectioncell for the day / time 
extension HangoutTableViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let collectionViewArray: NSArray = self.sourceArray[collectionView.tag] as! NSArray
        return collectionViewArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if (collectionView.tag == Int(placerow))
        {
            let currentplacerow = self.contentOffsetDictionary[placerow] as! Int
            let cell: LocationCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseLocationCollectionViewCellIdentifier, forIndexPath: indexPath) as!LocationCollectionViewCell
            if let placeidstr = self.sourceArray[collectionView.tag][indexPath.item] as? String{
                let placeid = Int(placeidstr)
                let locationdic = locationdata!.objectAtIndex(Int(placeid!)) as? NSDictionary
                let name = locationdic!.objectForKey("name") as! String
                let address = locationdic!.objectForKey("address") as! String
                let photopath = locationdic!.objectForKey("photopath") as! String
                cell.locationImageView.image = UIImage(named: photopath)
                cell.namelabel.text = name
                cell.addresslabel.text = address
                cell.namelabel.textColor = UIColor.blackColor()
                cell.labelContainer.backgroundColor = UIColor(white: 1, alpha: 0.6)
                cell.addresslabel.textColor = UIColor.blackColor()
                cell.addressContainer.backgroundColor = UIColor(white: 1, alpha: 0.6)
                if (indexPath.row == currentplacerow)
                {
                    if (currentplacerow == 0)
                    {
                        cell.leftarrow.hidden = true
                        cell.rightarrow.hidden = false
                    }
                    else if(currentplacerow == 2)
                    {
                        cell.leftarrow.hidden = false
                        cell.rightarrow.hidden = true
                    }
                    else
                    {
                        cell.leftarrow.hidden = false
                        cell.rightarrow.hidden = false
                    }
                }
                else
                {
                    cell.leftarrow.hidden = true
                    cell.rightarrow.hidden = true
                }
            }
            return cell
        }
        else if (collectionView.tag == 0)
        {
            let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCollectionViewCellIdentifier, forIndexPath: indexPath)
            var friendView: UIView? = nil
            if (indexPath.item == 0)
            {
                let me = rosterStorage!.myUserForXMPPStream(xmppStream!, managedObjectContext: rosterDBContext!)
                let sarray = cell.contentView.subviews.filter({
                    $0.tag == ownphototag
                })
                if (sarray.count == 0)
                {
                    friendView = FriendView.friendViewWithFriend(me) as? UIView
                    friendView!.frame = cell.bounds
                    friendView?.tag = ownphototag
                    cell.contentView.addSubview(friendView!)
                }
                else
                {
                    friendView = sarray[0] as UIView
                    friendView!.frame = cell.bounds
                    friendView?.tag = ownphototag
                }
            }
            else
            {
                let sarray = cell.contentView.subviews.filter({
                    $0.tag == friendtag
                })
                if (sarray.count == 0)
                {
                    friendView = FriendNormalView.friendViewWithFriend(selectedHangoutFriend) as? UIView
                    friendView?.tag = friendtag
                    friendView!.frame = cell.bounds
                    cell.contentView.addSubview(friendView!)
                }
                else
                {
                    friendView = sarray[0] as UIView
                    friendView!.frame = cell.bounds
                    friendView?.tag = ownphototag
                }
            }
            return cell
        }
        else if (collectionView.tag.description == self.timerow)
        {
            let currenttimerow = self.contentOffsetDictionary[timerow] as! Int
            let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCollectionViewCellIdentifier, forIndexPath: indexPath)
            var label: UILabel? = nil
            let rightimage = UIImage(named: "chevron")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            let leftimage = UIImage(named: "chevron_left")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            let rightarrow: UIImageView = UIImageView(image: rightimage)
            rightarrow.tintColor = UIColor(white: 0, alpha: 0.5)
            rightarrow.frame.origin = CGPoint(x: cell.frame.size.width - rightarrow.frame.width - 5, y: 8)
            rightarrow.tag = rightarrowtag
            let  leftarrow: UIImageView = UIImageView(image: leftimage)
            leftarrow.frame.origin = CGPoint(x: 5, y: 8)
            leftarrow.tag = leftarrowtag
            leftarrow.tintColor = UIColor(white: 0, alpha: 0.5)
            var array = cell.contentView.subviews.filter({
                $0.tag == placelocationtag
            })
            if (array.count == 0)
            {
                label = UILabel(frame: cell.bounds)
                label?.tag = placelocationtag
                cell.contentView.addSubview(label!)
            }
            else
            {
                label = array[0] as? UILabel
            }
            let leftarrowarray = cell.contentView.subviews.filter({
                $0.tag == leftarrowtag
            })
            if (leftarrowarray.count == 0 && indexPath.row != 0)
            {
                if (indexPath.row != currenttimerow){
                    leftarrow.hidden = true
                }
                else
                {
                    leftarrow.hidden = false
                }
                cell.contentView.addSubview(leftarrow)
            }
            let rightarrowarray = cell.contentView.subviews.filter({
                $0.tag == rightarrowtag
            })
            if (rightarrowarray.count == 0 && indexPath.row != 2)
            {
                if (indexPath.row != currenttimerow)
                {
                    rightarrow.hidden = true
                }
                else
                {
                    rightarrow.hidden = false
                }
                cell.contentView.addSubview(rightarrow)
            }
            if (indexPath.row == currenttimerow)
            {
                if (rightarrowarray.count > 0)
                {
                    if (currenttimerow == 2)
                    {
                        rightarrowarray[0].hidden = true
                    }
                    else
                    {
                        rightarrowarray[0].hidden = false
                    }

                }
                if (leftarrowarray.count > 0)
                {
                    leftarrowarray[0].hidden = false
                }
            }
            else
            {
                if (rightarrowarray.count > 0)
                {
                    rightarrowarray[0].hidden = true
                }
                if (leftarrowarray.count > 0)
                {
                    leftarrowarray[0].hidden = true
                }
            }
            
            label!.backgroundColor = UIColor.whiteColor()
            label!.textAlignment = NSTextAlignment.Center
            let time = self.sourceArray[collectionView.tag][indexPath.item] as? Hangout_Time
            label!.text = time?.time_description
            return cell
        }
        else
        {
            let currentdayrow = self.contentOffsetDictionary[dayrow] as! Int
            let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCollectionViewCellIdentifier, forIndexPath: indexPath)
            var label: UILabel? = nil
            let rightimage = UIImage(named: "chevron")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            let leftimage = UIImage(named: "chevron_left")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            let rightarrow: UIImageView = UIImageView(image: rightimage)
            rightarrow.tintColor = UIColor(white: 0, alpha: 0.5)
            rightarrow.frame.origin = CGPoint(x: cell.frame.size.width - rightarrow.frame.width - 5, y: 8)
            rightarrow.tag = rightarrowtag
            let  leftarrow: UIImageView = UIImageView(image: leftimage)
            leftarrow.frame.origin = CGPoint(x: 5, y: 8)
            leftarrow.tag = leftarrowtag
            leftarrow.tintColor = UIColor(white: 0, alpha: 0.5)
            var array = cell.contentView.subviews.filter({
                $0.tag == placelocationtag
            })
            if (array.count == 0)
            {
                label = UILabel(frame: cell.bounds)
                label?.tag = placelocationtag
                cell.contentView.addSubview(label!)
            }
            else
            {
                label = array[0] as? UILabel
            }
            let leftarrowarray = cell.contentView.subviews.filter({
                $0.tag == leftarrowtag
            })
            if (leftarrowarray.count == 0 && indexPath.row != 0)
            {
                if (indexPath.row != currentdayrow){
                    leftarrow.hidden = true
                }
                else
                {
                    leftarrow.hidden = false
                }
                cell.contentView.addSubview(leftarrow)
            }
            
            let rightarrowarray = cell.contentView.subviews.filter({
                $0.tag == rightarrowtag
            })
            if (rightarrowarray.count == 0 && indexPath.row != 2)
            {
                if (indexPath.row != currentdayrow)
                {
                    rightarrow.hidden = true
                }
                else
                {
                    rightarrow.hidden = false
                }
                cell.contentView.addSubview(rightarrow)
            }
            if (indexPath.row == currentdayrow)
            {
                if (rightarrowarray.count > 0)
                {
                    if (currentdayrow == 2)
                    {
                        rightarrowarray[0].hidden = true
                    }
                    else
                    {
                        rightarrowarray[0].hidden = false
                    }
                }
                if (leftarrowarray.count > 0)
                {
                    leftarrowarray[0].hidden = false
                }
            }
            else
            {
                if (rightarrowarray.count > 0)
                {
                    rightarrowarray[0].hidden = true
                }
                if (leftarrowarray.count > 0)
                {
                    leftarrowarray[0].hidden = true
                }
            }
            label!.backgroundColor = UIColor.whiteColor()
            label!.textAlignment = NSTextAlignment.Center
            let day = self.sourceArray[collectionView.tag][indexPath.item] as? Hangout_Day
            label!.text = day?.day_description
            return cell
        }
    }
    
     func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
     {
        let width = cell.bounds.size.width+15
        let index: NSInteger = collectionView.tag
        let value: AnyObject? = self.contentOffsetDictionary.valueForKey(index.description)
        let horizontalOffset: CGFloat = CGFloat(value != nil ? value!.floatValue : 0)
         collectionView.setContentOffset(CGPointMake(horizontalOffset*width, 0), animated: false)
     }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if !scrollView.isKindOfClass(UICollectionView) {
            return
        }
        let collectionView: DHIndexedCollectionView = scrollView as! DHIndexedCollectionView
        let pageWidth: CGFloat = self.view.frame.width - 44
        let currentOffset: CGFloat = scrollView.contentOffset.x
        let targetOffset = targetContentOffset.memory.x
        var newTargetOffset:CGFloat = 0
        
        if (targetOffset > currentOffset)
        {
            newTargetOffset = CGFloat(ceilf(Float(currentOffset / pageWidth))) * pageWidth
        }
        else
        {
            newTargetOffset = CGFloat(floorf(Float(currentOffset / pageWidth))) * pageWidth
        }
        
        if (newTargetOffset < 0)
        {
            newTargetOffset = 0
        }
        else if (newTargetOffset > scrollView.contentSize.width)
        {
            newTargetOffset = scrollView.contentSize.width
        }
        self.contentOffsetDictionary.setValue(newTargetOffset/pageWidth, forKey: collectionView.tag.description)
        targetContentOffset.memory.x = currentOffset
        scrollView.setContentOffset(CGPointMake(newTargetOffset, 0), animated: true)
        collectionView.reloadData()
    }
}

extension HangoutTableViewController
{
    func xmppHangout(sender:XMPPHangout, didUpdateHangout iq:XMPPIQ)
    {
        dismissloadscreen()
        self.navigationController?.popViewControllerAnimated(true)
    }
}



