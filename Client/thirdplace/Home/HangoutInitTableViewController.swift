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
    let p_context = NSManagedObjectContext.MR_context()
    
    @IBOutlet weak var declinebutton: UIButton!
    @IBOutlet weak var confirmbutton: UIButton!
    @IBOutlet weak var pagebackbutton: UIButton!
    @IBOutlet weak var sendbutton: UIButton!
    
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    var defaultMessage: String {
        get
        {
            return String(format: "Want to catch up this weekend?")
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
    
    @IBAction func declineButton(sender: AnyObject)
    {
        self.showloadscreen()
        //lookup a temp hangout
        let hangoutid = selectedHangoutid!
        let hangout = Hangout.MR_findFirstByAttribute("hangoutid", withValue: NSNumber(integer: hangoutid), inContext: p_context)
        let me = hangout.getUser(xmppStream.myJID)
        me!.goingstatus = "notgoing"
        hangoutmodule.cancelHangoutInvitation(hangout, sender: xmppStream.myJID)
    }
    
    func sendHangout()
    {
        self.showloadscreen()
        let createtime = NSDate().mt_inTimeZone(NSTimeZone.localTimeZone())
        //create a temp hangout
        let hangout = Hangout.MR_createEntityInContext(p_context)
        if ((alternativeMessage != nil) && (alternativeMessage != ""))
        {
            hangout.hangoutdescription = alternativeMessage
        }
        else
        {
            hangout.hangoutdescription = defaultMessage
        }
        hangout.createtime = createtime
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
        let now = createtime
        if (now.mt_weekdayOfWeek() == Weekday.Sat.rawValue)
        {
            let startdate = now.mt_startOfCurrentDay()
            let enddate = now.mt_endOfNextDay()
            hangouttime.startdate = startdate
            hangouttime.enddate = enddate
            hangout.sorttime = startdate
        }
        else if(now.mt_weekdayOfWeek() == Weekday.Sun.rawValue)
        {
            let startdate = now.mt_startOfPreviousDay()
            let enddate = now.mt_endOfCurrentDay()
            hangouttime.startdate = startdate
            hangouttime.enddate = enddate
        }
        else
        {
            let sat = now.mt_endOfCurrentWeek().mt_dateDaysBefore(1).mt_dateSecondsAfter(1)
            let sun = now.mt_endOfCurrentWeek().mt_dateHoursAfter(24)
            hangouttime.startdate = sat
            hangouttime.enddate = sun
        }
        hangouttime.timedescription = "This Weekend"
        hangouttime.updatejid = xmppStream.myJID.bare()
        hangouttime.updatetime = createtime
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
        message.updatetime = createtime
        message.updatejid = xmppStream.myJID.bare()
        message.hangout = hangout
    }
    @IBAction func sendButton(sender: AnyObject)
    {
       self.sendHangout()
    }
    
    @IBAction func confirmButton(sender: AnyObject)
    {
        self.showloadscreen()
        let createtime = NSDate().mt_inTimeZone(NSTimeZone.localTimeZone())
        
        //lookup a temp hangout
        let hangoutid = selectedHangoutid!
        let hangout = Hangout.MR_findFirstByAttribute("hangoutid", withValue: NSNumber(integer: hangoutid), inContext: p_context)
        let me = hangout.getUser(xmppStream.myJID)
        me!.goingstatus = "going"
        
        let previoustime = hangout.getLatestTime()
        //time
        let hangouttime = HangoutTime.MR_createEntityInContext(p_context)
        hangouttime.startdate = previoustime?.startdate
        hangouttime.enddate = previoustime?.enddate
        hangouttime.timedescription = "This Weekend"//based on the selection
        hangouttime.updatejid = xmppStream.myJID.bare()
        hangouttime.updatetime = createtime
        hangouttime.hangout = hangout
        
        //message
        let message = HangoutMessage.MR_createEntityInContext(p_context)
        message.updatetime = createtime
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
            return 110
        }
        else if(indexPath.section == 1)
        {
            return UITableViewAutomaticDimension
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
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 17.0
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0)
        {
            return 80
        }
        else{
            return 0
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseTableViewCellIdentifier, forIndexPath: indexPath) as! DHCollectionTableViewCell
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 25
            layout.sectionInset = UIEdgeInsetsMake(0, leftmargin, 0, 0)
            layout.itemSize = CGSizeMake(cell.bounds.size.height - 10, cell.bounds.size.height - 10)
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
            cell.collectionView.collectionViewLayout = layout
            cell.frameView.hidden = true
            cell.collectionView.backgroundColor = UIColor.clearColor()
            return cell
        }
        else if (indexPath.section == 1 )
        {
            let textcell = tableView.dequeueReusableCellWithIdentifier("MultiLineTextInputTableViewCell", forIndexPath: indexPath) as? MultiLineTextInputTableViewCell
            var fullnamearray: NSArray?
            if (selectedHangoutid != nil)
            {
                let hangoutid = selectedHangoutid!
                let hangout = Hangout.MR_findFirstByAttribute("hangoutid", withValue: NSNumber(integer: hangoutid), inContext: p_context)
                let message = hangout.getLatestMessage()
                let sender = message!.updatejid!
                if (sender == AppConfig.jid())
                {
                    fullnamearray = AppConfig.name().characters.split{$0 == " "}.map(String.init)
                    if (fullnamearray != nil)
                    {
                        textcell!.textString = "\(fullnamearray![0]): \(message!.content!)"
                    }

                }
                else
                {
                    let senderjid = XMPPJID.jidWithString(sender as String)
                    let xmppuser = self.rosterStorage.userForJID(senderjid, xmppStream: self.xmppStream, managedObjectContext: rosterDBContext)
                    if (xmppuser != nil && xmppuser.nickname != nil)
                    {
                        fullnamearray = xmppuser.nickname.characters.split{$0 == " "}.map(String.init)
                    }
                    textcell!.textString = "\(fullnamearray![0]): \(message!.content!)"
                }
            }
            else
            {
                fullnamearray = AppConfig.name().characters.split{$0 == " "}.map(String.init)
                textcell!.textString = "\(fullnamearray![0]): \(self.defaultMessage)"
            }            
            textcell!.textView!.editable = false
            textcell!.bgview.selectiveBorderFlag = UInt(AUISelectiveBordersFlagTop | AUISelectiveBordersFlagBottom | AUISelectiveBordersFlagLeft | AUISelectiveBordersFlagRight)
            textcell!.bgview.selectiveBordersColor = UIColor.lightGrayColor()
            textcell!.bgview.selectiveBordersWidth = 0
            textcell!.bgview.layer.shadowColor = UIColor.grayColor().CGColor
            textcell!.bgview.layer.shadowOffset = CGSizeMake(1,3)
            textcell!.bgview.layer.shadowOpacity = 1
            textcell!.bgview.layer.shadowRadius = 2.0
            textcell!.bgview.layer.masksToBounds = false
            return textcell!
        }
        else if (indexPath.section == 2)
        {
            let textcell = tableView.dequeueReusableCellWithIdentifier("MultiLineTextInputTableViewCell", forIndexPath: indexPath) as? MultiLineTextInputTableViewCell
            textcell!.textView!.placeholder = "Insert alternative message"
            textcell!.textView!.delegate = self
            textcell!.textString = ""
            textcell!.bgview.selectiveBorderFlag = UInt(AUISelectiveBordersFlagTop | AUISelectiveBordersFlagBottom | AUISelectiveBordersFlagLeft | AUISelectiveBordersFlagRight)
            textcell!.bgview.selectiveBordersColor = UIColor.lightGrayColor()
            textcell!.bgview.selectiveBordersWidth = 0
            
            textcell!.bgview.layer.shadowColor = UIColor.grayColor().CGColor
            textcell!.bgview.layer.shadowOffset = CGSizeMake(1,3)
            textcell!.bgview.layer.shadowOpacity = 1
            textcell!.bgview.layer.shadowRadius = 2.0
            textcell!.bgview.layer.masksToBounds = false
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
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
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
        cell.backgroundColor = UIColor.whiteColor()//AppConfig.themebgcolour()
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
            friendView = FriendNormalView.friendViewWithFriend(selectedHangoutFriend) as? UIView;
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if (text != "\n")
        {
            return true
        }
        else
        {
            self.sendHangout()
            return false
        }
    }
}

extension HangoutInitTableViewController
{
    func xmppHangout(sender:XMPPHangout, didCreateHangout createquery:DDXMLElement)
    {
        let hangout = Hangout.MR_findFirstByAttribute("hangoutid", withValue: NSNumber(integer: HangoutConfig.tempHangoutID), inContext: p_context)
        let newid = createquery.stringValue()
        hangout.hangoutid = Int(newid)
        p_context.MR_saveToPersistentStoreAndWait()
        self.dismissloadscreen()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func xmppHangout(sender:XMPPHangout, didCloseHangout iq:XMPPIQ)
    {
        p_context.MR_saveToPersistentStoreAndWait()
        self.dismissloadscreen()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func xmppHangout(sender:XMPPHangout, didUpdateHangout iq:XMPPIQ)
    {
        p_context.MR_saveToPersistentStoreAndWait()
        self.dismissloadscreen()
        self.navigationController?.popViewControllerAnimated(true)
    }
}







