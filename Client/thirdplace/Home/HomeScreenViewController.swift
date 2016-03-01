//
//  HomeScreenViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 16/09/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices

protocol HomeScreenDelegate
{
    func didFBLoginSuccess()
}

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendContainerViewDelegate,HomeScreenDelegate,NSFetchedResultsControllerDelegate {

    @IBOutlet weak var LoadingScreen: UIView!
    @IBAction func touchMapbutton(sender: UIButton, hangout: Hangout)
    {
        let row = sender.tag
        let indexpath = NSIndexPath(forRow: row, inSection: 0)
        let hangout = hangoutFetchedRequestsControler!.objectAtIndexPath(indexpath) as! Hangout
        if let location = hangout.getLatestLocation() as HangoutLocation?
        {
            if let locationdic = locationlists!.objectAtIndex((location.locationid?.integerValue)!) as? NSDictionary
            {
                let name = locationdic.objectForKey("address") as! String
                let map =  MapViewController(nibName: "MapViewController", bundle: nil)
                map.address = name
                self.navigationController?.pushViewController(map, animated: true)
            }
        }
    }
    
    @IBOutlet weak var hometablelistview: UITableView!
    
    var rosterStorage: XMPPRosterCoreDataStorage{
        get{
            return self.appDelegate!.xmppRosterStorage
        }
    }
    
    var rosterDBContext : NSManagedObjectContext{
        get{
            return self.appDelegate!.managedObjectContext_roster()
        }
    }
    
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    let xmppHangoutDB = XMPPHangoutDataManager.singleInstance
    var xmppStream: XMPPStream?
    var xmppHangout: XMPPHangout?
    var locationlists: NSArray?
    var fbloginview: Bool = false
    
    override func viewDidLoad()
    {
        if (appDelegate!.isFbLoggedIn())
        {
            appDelegate!.loginXMPP()
        }
        else
        {
            //show login screen
            let loginController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController
            loginController?.delegate = self
            self.presentViewController(loginController!, animated: false, completion: nil)
            LoadingScreen.removeFromSuperview()
            fbloginview = true
        }
        xmppStream = appDelegate!.xmppStream
        xmppHangout = appDelegate!.xmppHangout
        appDelegate!.xmppRoster.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        xmppHangout!.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        hometablelistview.estimatedRowHeight = 44.0
        locationlists = XMPPHangoutDataManager.initLocationData()
        self.view.backgroundColor = UIColor.blackColor()//UIColor(patternImage: UIImage(named: "patternBackground")!)
        appDelegate!.xmppStream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        let dummyViewHeight: CGFloat = 70.0
        let dummyView = UIView(frame: CGRectMake(0, 0, self.hometablelistview.bounds.size.width, dummyViewHeight))
        self.hometablelistview.tableHeaderView = dummyView;
        self.hometablelistview.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
    }
    
    deinit
    {
        appDelegate!.xmppStream.removeDelegate(self)
        appDelegate!.xmppRoster.removeDelegate(self)
        xmppHangout!.removeDelegate(self)
    }

    
    override func viewDidLayoutSubviews()
    {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendContainerTableViewCell") as? FriendContainerTableViewCell
            return cell!
        }
        else
        {
            let hangoutcell :HangoutListTableViewCell = tableView.dequeueReusableCellWithIdentifier("HangoutListTableViewCell") as!HangoutListTableViewCell
            hangoutcell.mapheightconstraint.constant = 50
            hangoutcell.topvalueconstraint.constant = 0
            hangoutcell.bgimageview.alpha = 1.0
            let indexpath = NSIndexPath(forRow: indexPath.row, inSection: 0)
            let hangout = hangoutFetchedRequestsControler!.objectAtIndexPath(indexpath) as! Hangout
            hangoutcell.mapbutton.tag = indexPath.row
            let message = hangout.getLatestMessage()
            let time = hangout.getLatestTime()
            let otheruser = hangout.getOtherUser(xmppStream!.myJID)
            let me = hangout.getUser(xmppStream!.myJID)
            if (otheruser!.goingstatus != "notgoing")
            {
                hangoutcell.dateLabel.text = time?.timedescription
                if (me!.goingstatus == "notgoing")
                {
                     hangoutcell.messageLabel.text = "You are not available"
                }
                else
                {
                    var fullnamearray: NSArray?
                    let sender = message!.updatejid!
                    if (sender == AppConfig.jid())
                    {
                        fullnamearray = AppConfig.name().characters.split{$0 == " "}.map(String.init)
                    }
                    else
                    {
                        let senderjid = XMPPJID.jidWithString(sender as String)
                        let xmppuser = rosterStorage.userForJID(senderjid, xmppStream: self.xmppStream, managedObjectContext: rosterDBContext)
                        if (xmppuser != nil && xmppuser.nickname != nil)
                        {
                            fullnamearray = xmppuser.nickname.characters.split{$0 == " "}.map(String.init)
                        }
                    }
                    if (fullnamearray != nil)
                    {
                        if (message!.content != nil)
                        {
                            hangoutcell.messageLabel.text = "\(fullnamearray![0]): \(message!.content!)"
                        }
                        else
                        {
                            hangoutcell.messageLabel.text = "\(fullnamearray![0]): "
                        }
                    }
                }
            }
            else
            {
                hangoutcell.dateLabel.text = time?.timedescription
                let jid = XMPPJID.jidWithString(otheruser?.jidstr)
                if let user = rosterStorage.userForJID(jid, xmppStream: xmppStream!, managedObjectContext: rosterDBContext)
                {
                    if (user.nickname != nil)
                    {
                        hangoutcell.messageLabel.text = "\(user.nickname) can not catch up this weekend"
                    }
                }
            }
            
            hangoutcell.collectionView.indexPath = indexpath
            if let location = hangout.getLatestLocation() as HangoutLocation?
            {
                hangoutcell.mapbutton.hidden = false
                hangoutcell.placeLabel.hidden = false
                if let locationdic = locationlists!.objectAtIndex((location.locationid?.integerValue)!) as? NSDictionary
                {
                    let name = locationdic.objectForKey("name") as! String
                    let photopath = locationdic.objectForKey("photopath") as! String
                    hangoutcell.placeLabel.text = name
                    if (otheruser!.goingstatus != "notgoing")
                    {
                        if (me!.goingstatus == "notgoing")
                        {
                            hangoutcell.bgimageview.image = UIImage(named: photopath)?.grayscale()
                        }
                        else
                        {
                            hangoutcell.bgimageview.image = UIImage(named: photopath)
                        }
                    }
                    else
                    {
                        hangoutcell.bgimageview.image = UIImage(named: photopath)?.grayscale()
                    }
                }
            }
            else
            {
                hangoutcell.mapbutton.hidden = true
                hangoutcell.placeLabel.hidden = true
                hangoutcell.mapheightconstraint.constant = 0
                hangoutcell.topvalueconstraint.constant = 0
                if (otheruser!.goingstatus != "notgoing")
                {
                    if (me!.goingstatus == "notgoing")
                    {
                        hangoutcell.bgimageview.image = UIImage(named: "bbb.jpg")?.grayscale()
                    }
                    else
                    {
                        if (hangout.createUserJID == xmppStream!.myJID.bare())
                        {
                            if (hangout.message.count == 1)
                            {
                                hangoutcell.bgimageview.image = UIImage(named: "bbb.jpg")
                                hangoutcell.bgimageview.alpha = 0.4
                            }
                            else
                            {
                                hangoutcell.bgimageview.image = UIImage(named: "bbb.jpg")
                            }
                        }
                        else
                        {
                            if (hangout.message.count == 1)
                            {
                                hangoutcell.bgimageview.image = UIImage(named: "bbb.jpg")
                                hangoutcell.bgimageview.alpha = 0.4
                            }
                            else
                            {
                                hangoutcell.bgimageview.image = UIImage(named: "bbb.jpg")
                            }
                        }
                    }
                }
                else
                {
                    hangoutcell.bgimageview.image = UIImage(named: "bbb.jpg")?.grayscale()
                }
            }
            return hangoutcell
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0
        {
            let c = cell as? FriendContainerTableViewCell
            cell.backgroundColor = UIColor.blackColor()
            c!.friendContainerView.reloadFriendListData()
            c!.setNeedsLayout()
            c!.setDelegate(self)
            c!.friendContainerView.updateLayout()
        }
        else
        {
            let collectionCell: HangoutListTableViewCell = cell as! HangoutListTableViewCell
            collectionCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, index: indexPath.section)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if (self.hangoutFetchedRequestsControler != nil)
        {
            let sectionInfo = hangoutFetchedRequestsControler!.sections
            if (sectionInfo != nil)
            {
                let sections = sectionInfo![0]
                if ( sections.numberOfObjects > 0)
                {
                    return 2
                }
            }
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0)
        {
            return 0
        }
        else
        {
            return 70
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            return UIView()
        }
        else
        {
            let rect = CGRectMake(0, 0, tableView.frame.size.width, 70)
            let labelrect = CGRectMake(10, 0, tableView.frame.size.width, 70)
            let view = UIView(frame: rect)
            view.backgroundColor = UIColor.blackColor()
            let label = UILabel(frame: labelrect)
            label.text = "Hangouts↓"
            label.textColor = UIColor.whiteColor()
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont (name: "HelveticaNeue-Thin", size: 48)
            view.addSubview(label)
            return view
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section != 0)
        {
            if (self.hangoutFetchedRequestsControler != nil)
            {
                let sectionInfo = self.hangoutFetchedRequestsControler!.sections
                if (sectionInfo != nil)
                {
                    let sections = sectionInfo![0]
                    return sections.numberOfObjects
                }
                else
                {
                    return 0
                }
            }
            return 0
        }
        else
        {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if (indexPath.section == 0)
        {
            return 350
        }
        else
        {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if (indexPath.section == 1)
        {
            if (self.xmppStream!.isConnected())
            {
                let indexpath = NSIndexPath(forRow: indexPath.row, inSection: 0)
                let hangout = hangoutFetchedRequestsControler?.objectAtIndexPath(indexpath) as! Hangout
                var users = hangout.user.allObjects.filter{
                    $0.jidstr != xmppStream!.myJID.bare()
                }
                if (users.count > 0)
                {
                    let jidstr = users[0].jidstr
                    let jid = XMPPJID.jidWithString(jidstr)
                    let xmppuser = rosterStorage.userForJID(jid, xmppStream: xmppStream!, managedObjectContext: rosterDBContext)
                    if (xmppuser != nil)
                    {
                        self.displayCreateHangoutView(xmppuser, activeHangout: hangout)
                    }
                }
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            else{
                ErrorHandler.showPopupMessage(self.view, text: "Please wait for connection")
                
            }
        }
    }
    
    var _hangoutFetchedResultsController: NSFetchedResultsController? = nil
    var hangoutFetchedRequestsControler : NSFetchedResultsController?
    {
        if _hangoutFetchedResultsController != nil{
            return _hangoutFetchedResultsController!
        }
        let request =  xmppHangoutDB.getHangoutListRequest(xmppStream!.myJID)
        if (request != nil)
        {
            let afetchedController = NSFetchedResultsController(fetchRequest: request!, managedObjectContext: NSManagedObjectContext.MR_defaultContext(), sectionNameKeyPath: nil, cacheName: nil)
            afetchedController.delegate = self
            _hangoutFetchedResultsController = afetchedController
            
            var error:NSError? = nil
            do{
                try _hangoutFetchedResultsController!.performFetch()
            }
            catch let error1 as NSError{
                error = error1
                print("Unresolved error \(error) \(error?.userInfo)")
            }

        }
        return _hangoutFetchedResultsController
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        XMPPLoggingWrapper.XMPPLogTrace()
        _hangoutFetchedResultsController = nil
        hometablelistview.reloadData()
    }
    
    // MARK: Action View
    func displayCreateHangoutView(friend:XMPPUserCoreDataStorageObject, activeHangout: Hangout?)
    {
        MagicalRecord.saveWithBlockAndWait({ (localContext : NSManagedObjectContext!) in
            
            let fbroster = DataManager.singleInstance.getXMPPUserFBInfo(friend.jid, dbcontext: localContext)
            if (fbroster != nil)
            {
                fbroster!.updateUnReadMessage(0)
            }
        })
    
        if (activeHangout != nil)
        {
            let otheruser = activeHangout!.getOtherUser(xmppStream!.myJID)
            let me = activeHangout!.getUser(xmppStream!.myJID)
            if otheruser?.goingstatus == "notgoing"
            {
                ErrorHandler.showPopupMessage(self.view, text: "Try another time")
                return
            }
            if me?.goingstatus == "notgoing"
            {
                ErrorHandler.showPopupMessage(self.view, text: "You are not available")
                return
            }
            
            if (activeHangout!.createUserJID == xmppStream!.myJID.bare())
            {
                if (activeHangout!.message.count == 1)
                {
                    ErrorHandler.showPopupMessage(self.view, text: "Please wait your friend response")
                    return
                }
                let hangoutviewcontroller = self.storyboard?.instantiateViewControllerWithIdentifier("HangoutTableViewController") as! HangoutTableViewController?
                hangoutviewcontroller?.title = "Hangout"
                hangoutviewcontroller?.selectedHangoutID = activeHangout!.hangoutid?.integerValue
                hangoutviewcontroller?.selectedHangoutFriend = friend
                if hangoutviewcontroller != nil
                {
                    self.navigationController?.pushViewController(hangoutviewcontroller!, animated: true)
                }
            }
            else
            {
                //check if it's the first message
                if (activeHangout!.message.count == 1)
                {
                    let hangoutviewcontroller = self.storyboard?.instantiateViewControllerWithIdentifier("HangoutInitTableViewController") as! HangoutInitTableViewController?
                    hangoutviewcontroller?.title = "Hangout"
                    hangoutviewcontroller?.selectedHangoutid = activeHangout!.hangoutid?.integerValue
                    hangoutviewcontroller?.selectedHangoutFriend = friend
                    if hangoutviewcontroller != nil
                    {
                        self.navigationController?.pushViewController(hangoutviewcontroller!, animated: true)
                    }
                }
                else
                {
                    let hangoutviewcontroller = self.storyboard?.instantiateViewControllerWithIdentifier("HangoutTableViewController") as! HangoutTableViewController?
                    hangoutviewcontroller?.title = "Hangout"
                    hangoutviewcontroller?.selectedHangoutID = activeHangout!.hangoutid?.integerValue
                    hangoutviewcontroller?.selectedHangoutFriend = friend
                    if hangoutviewcontroller != nil
                    {
                        self.navigationController?.pushViewController(hangoutviewcontroller!, animated: true)
                    }
                }
            }
        }
        else
        {
            let hangoutviewcontroller = self.storyboard?.instantiateViewControllerWithIdentifier("HangoutInitTableViewController") as! HangoutInitTableViewController?
            hangoutviewcontroller?.title = "Hangout"
            hangoutviewcontroller?.selectedHangoutFriend = friend
            if hangoutviewcontroller != nil
            {
                self.navigationController?.pushViewController(hangoutviewcontroller!, animated: true)
            }
        }
    }

    // MARK: HomeScreenDelegate
    func didFBLoginSuccess()
    {
        appDelegate!.loginXMPP()
    }
    
// MARK: FriendContainerDelegate
    
    func didTouchFriend(friend: XMPPUserCoreDataStorageObject!, rect: CGRect)
    {
        if (self.xmppStream!.isConnected())
        {
            if (friend != nil && friend.subscription  != "none")
            {
                let hangout = xmppHangoutDB.hasActiveHangout(friend.jid, xmppstream: xmppStream!)
                self.displayCreateHangoutView(friend, activeHangout:hangout)
            }
            else
            {
                ErrorHandler.showPopupMessage(self.view, text: "Waiting for friend invitation response")
            }
        }
        else
        {
            ErrorHandler.showPopupMessage(self.view, text: "Please wait for connection")
        }
    }
    
    func didTouchAddFriend()
    {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.hide(true, afterDelay: 10.0)
        
        let fbrequest =  FBRequest.requestForMyFriends()
        fbrequest.startWithCompletionHandler {
            (connection:FBRequestConnection!,   result:AnyObject!, error:NSError!) -> Void in
            if (error == nil)
            {
                let fblists = result.objectForKey("data") as? NSArray
                let fbviewcontroller = self.storyboard?.instantiateViewControllerWithIdentifier("FBFriendListViewController") as! FBFriendListViewController?
                fbviewcontroller!.friendlists = fblists
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.navigationController?.pushViewController(fbviewcontroller!, animated: true)
            }
        }
    }

    func didTouchMe()
    {
        //self.performSegueWithIdentifier("ProfileViewController", sender: nil)
    }
    
    func fadeoutloadingscreen()
    {
        if (fbloginview)
        {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        UIView.animateWithDuration(1.0, animations: {
            if (self.LoadingScreen != nil)
            {
                self.LoadingScreen.alpha = 0.0
            }
        }, completion:{ finished in
            if (self.LoadingScreen != nil)
            {
                self.LoadingScreen.removeFromSuperview()
            }
        })
    }
    
    //Mark: XMPPRosterDelegate
    func xmppRosterDidEndPopulating(sender:XMPPRoster)
    {
        self.fadeoutloadingscreen()
        hometablelistview.reloadData()
    }
    
    func xmppRoster(sender:XMPPRoster, didReceiveRosterPush iq:XMPPIQ)
    {
        self.fadeoutloadingscreen()
        hometablelistview.reloadData()
    }
    
    //Mark: XMPPHangoutDelegate
    func xmppHangout(sender:XMPPHangout, didReceiveMessage message:XMPPMessage)
    {
        XMPPLoggingWrapper.XMPPLogTrace()
        _hangoutFetchedResultsController = nil
        hometablelistview.reloadData()
       
        MagicalRecord.saveWithBlockAndWait({ (localContext : NSManagedObjectContext!) in
            let jid = message.from()
            let fbroster = DataManager.singleInstance.getXMPPUserFBInfo(jid, dbcontext: localContext)
            if (fbroster != nil)
            {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                var unreadmessage = fbroster!.unreadMessages!.integerValue
                unreadmessage++
                fbroster!.updateUnReadMessage(unreadmessage)
            }
       })
    }
    
    func xmppHangout(sender:XMPPHangout, didHangoutLists iq:XMPPIQ)
    {
        
    }
    
    func xmppStreamDidConnect(sender: XMPPStream)
    {

    }
}

// MARK: - Collection View Data source and Delegate
extension HomeScreenViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    
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
            if let me = rosterStorage.myUserForXMPPStream(xmppStream, managedObjectContext: rosterDBContext)
            {
                let dhcollectionview = collectionView as! DHIndexedCollectionView
                let cellindexpath = dhcollectionview.indexPath
                let hangout = hangoutFetchedRequestsControler!.objectAtIndexPath(cellindexpath) as! Hangout
                let otheruser = XMPPJID.jidWithString(hangout.getOtherUser(me.jid)!.jidstr!)
                let friend = rosterStorage.userForJID(otheruser, xmppStream: self.xmppStream, managedObjectContext: rosterDBContext)
                friendView = FriendNormalView.friendViewWithFriend(friend) as? UIView
            }
            else
            {
                friendView = FriendView.friendViewWithFriend(nil) as? UIView
            }
        }
        friendView!.frame = cell.bounds;
        cell.addSubview(friendView!)
        return cell
    }
}
