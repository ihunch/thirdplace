//
//  HangoutInitTableViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 12/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class HangoutInitTableViewController: DHCollectionTableViewController
{
    let aumaxlocations = 18
    let leftmargin: CGFloat = 30
    var displayKeyboard = false
    var offset:CGPoint?
    var selectedHangoutid:Int?
    var _selectedHangoutFriend: XMPPUserCoreDataStorageObject?
    var selectedHangoutFriend : XMPPUserCoreDataStorageObject{
        get {
            return _selectedHangoutFriend!
        }
        set(friend)
        {
            _selectedHangoutFriend = friend
        }
    }
    
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    var defaultMessage: String {
        get {
            return String(format: "Want to chat up with %@ this weekend", selectedHangoutFriend.nickname)
        }
    }
    var defaultConfirmMessage: String {
        get {
            return "Let's catch up this weekend"
        }
    }
    var alternativeMessage: String?
    
    var rosterStorage: XMPPRosterCoreDataStorage{
        get{
            return self.appDelegate!.xmppRosterStorage
        }
    }
    
    var hangoutDataManager = XMPPHangoutDataManager.singleInstance;
    
    var xmppStream: XMPPStream{
        get{
            return self.appDelegate!.xmppStream
        }
    }
    var rosterDBContext : NSManagedObjectContext{
        get{
            return self.appDelegate!.managedObjectContext_roster()
        }
    }
    var hangoutmodule : XMPPHangout{
        get{
            return self.appDelegate!.xmppHangout
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "MultiLineTextInputTableViewCell", bundle: nil), forCellReuseIdentifier: "MultiLineTextInputTableViewCell")
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 50
        hangoutmodule.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide:"), name: UIKeyboardDidHideNotification, object: nil)
        displayKeyboard = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit{
        hangoutmodule.removeDelegate(self)
    }

    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func sendButton(sender: AnyObject)
    {
        //create a temp hangout 
        let p_context = hangoutDataManager.privateContext()
        let hangout = Hangout.MR_createEntityInContext(p_context)
        if ((alternativeMessage != nil) && (alternativeMessage != ""))
        {
            hangout.hangoutdescription = alternativeMessage
        }
        else
        {
            hangout.hangoutdescription = defaultMessage
        }
        hangout.createtime = NSDate()
        hangout.createUserJID = xmppStream.myJID.bare()
        hangout.hangoutid = NSNumber(integer: HangoutConfig.tempHangoutID)
        let array = XMPPHangoutDataManager.getRandomThreeDigital(aumaxlocations)
        hangout.preferedlocation = "\(array[0]),\(array[1]),\(array[2])"
        //user 
        let sender = HangoutUser.MR_createEntityInContext(p_context)
        sender.goingstatus = "maybe"
        sender.jidstr  = xmppStream.myJID.bare()
        sender.username = xmppStream.myJID.bare()
        sender.hangout = hangout
        
        let invitor = HangoutUser.MR_createEntityInContext(p_context)
        invitor.goingstatus = "maybe"
        invitor.jidstr  = selectedHangoutFriend.jidStr
        invitor.username = selectedHangoutFriend.jidStr
        invitor.hangout = hangout
        //time
        let hangouttime = HangoutTime.MR_createEntityInContext(p_context)
        let now = NSDate()
        let sat = now.getNextSaturday()?.mt_inTimeZone(NSTimeZone.localTimeZone())
        let sun = now.getNextSaturday()?.mt_inTimeZone(NSTimeZone.localTimeZone()).mt_dateHoursAfter(24).mt_dateHoursAfter(23).mt_dateMinutesAfter(59)
        hangouttime.startdate = sat
        hangouttime.enddate = sun
        hangouttime.timedescription = "Weekend"
        hangouttime.updatejid = xmppStream.myJID.bare()
        hangouttime.updatetime = NSDate()
        hangouttime.hangout = hangout
        hangoutmodule.sendHangoutInvitation(hangout, sender: xmppStream.myJID)
        //message
        let message = HangoutMessage.MR_createEntityInContext(p_context)
        if ((alternativeMessage != nil) && (alternativeMessage != ""))
        {
            message.content = alternativeMessage
        }
        else
        {
            message.content = defaultMessage
        }
        message.updatetime = NSDate()
        message.updatejid = xmppStream.myJID.bare()
        message.hangout = hangout
    }
    
    @IBAction func confirmButton(sender: AnyObject)
    {
        //create a temp hangout
        let p_context = hangoutDataManager.privateContext()
        let hangoutid = selectedHangoutid!
        let hangout = Hangout.MR_findFirstByAttribute("hangoutid", withValue: NSNumber(integer: hangoutid), inContext: p_context)
        let me = hangout.getUser(xmppStream.myJID)
        me!.goingstatus = "going"
        
        let previoustime = hangout.getLatestTime()
        //time
        let hangouttime = HangoutTime.MR_createEntityInContext(p_context)
        hangouttime.startdate = previoustime?.startdate
        hangouttime.enddate = previoustime?.enddate
        hangouttime.timedescription = "Weekend"//based on the selection
        hangouttime.updatejid = xmppStream.myJID.bare()
        hangouttime.updatetime = NSDate()
        hangouttime.hangout = hangout
        
        //message
        let message = HangoutMessage.MR_createEntityInContext(p_context)
        message.updatetime = NSDate()
        message.updatejid = xmppStream.myJID.bare()
        message.hangout = hangout
        if ((alternativeMessage != nil) && (alternativeMessage != ""))
        {
            message.content = alternativeMessage
        }
        else
        {
            message.content = defaultConfirmMessage
        }
        hangoutmodule.updateHangout(hangout, sender: xmppStream.myJID)
    }
}

// MARK: - Table view data source
extension HangoutInitTableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {

        if (indexPath.section == 0)
        {
            return 70
        }
        else if(indexPath.section == 1)
        {
            return 50
        }
        else if(indexPath.section == 2)
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
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseTableViewCellIdentifier, forIndexPath: indexPath) as! DHCollectionTableViewCell
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsetsMake(0, leftmargin, 0, 0)
            layout.itemSize = CGSizeMake(cell.bounds.size.height - 10, cell.bounds.size.height - 10)
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
            cell.collectionView.collectionViewLayout = layout
            return cell
        }
        else if (indexPath.section == 1 )
        {
            let textcell = tableView.dequeueReusableCellWithIdentifier("MultiLineTextInputTableViewCell", forIndexPath: indexPath) as? MultiLineTextInputTableViewCell
            textcell!.textString = self.defaultMessage
            textcell!.textView!.editable = false
            return textcell!
        }
        else if (indexPath.section == 2)
        {
            let textcell = tableView.dequeueReusableCellWithIdentifier("MultiLineTextInputTableViewCell", forIndexPath: indexPath) as? MultiLineTextInputTableViewCell
            textcell!.textView!.placeholder = "Insert alternative message"
            textcell!.textView!.delegate = self
            textcell!.titleLabel?.text = ""
            textcell!.textString = ""
            return textcell!
        }
        else
        {
            if (selectedHangoutid == nil)
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("EditHangoutControlPanel")
                return cell!
            }
            else
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("ConfirmHangoutControlPanel")
                return cell!
            }
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (indexPath.section == 0)
        {
            let collectionCell: DHCollectionTableViewCell = cell as! DHCollectionTableViewCell
            collectionCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, index: indexPath.section)
            let index: NSInteger = collectionCell.collectionView.tag
            let value: AnyObject? = self.contentOffsetDictionary.valueForKey(index.description)
            let horizontalOffset: CGFloat = CGFloat(value != nil ? value!.floatValue : 0)
            collectionCell.collectionView.setContentOffset(CGPointMake(horizontalOffset, 0), animated: false)
        }
        cell.backgroundColor = UIColor.lightGrayColor()
    }
}

// MARK: - Collection View Data source and Delegate
extension HangoutInitTableViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCollectionViewCellIdentifier, forIndexPath: indexPath)
        var friendView: UIView? = nil
        if (indexPath.item == 0)
        {
            let me = rosterStorage.myUserForXMPPStream(xmppStream, managedObjectContext: rosterDBContext)
            friendView = FriendView.friendViewWithFriend(me) as? UIView;
        }
        else
        {
            friendView = FriendView.friendViewWithFriend(selectedHangoutFriend) as? UIView;
        }
        friendView!.frame = cell.bounds;
        cell.addSubview(friendView!)
        return cell
    }
    
   override func scrollViewDidScroll(scrollView: UIScrollView) {
        if !scrollView.isKindOfClass(UICollectionView) {
            return
        }
        let horizontalOffset: CGFloat = scrollView.contentOffset.x
        let collectionView: UICollectionView = scrollView as! UICollectionView
        self.contentOffsetDictionary.setValue(horizontalOffset, forKey: collectionView.tag.description)
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

extension HangoutInitTableViewController: UITextViewDelegate
{
    func textViewDidChange(textView: UITextView) {
        alternativeMessage = textView.text
        
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

extension HangoutInitTableViewController
{
    func xmppHangout(sender:XMPPHangout, didCreateHangout iq:XMPPIQ)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
}







