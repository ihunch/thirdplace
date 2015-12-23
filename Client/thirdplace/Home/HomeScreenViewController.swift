//
//  HomeScreenViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 16/09/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

protocol HomeScreenDelegate
{
    func didFBLoginSuccess()
}

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendContainerViewDelegate,HomeScreenDelegate,NSFetchedResultsControllerDelegate {

    @IBAction func touch(sender: AnyObject)
    {
        MagicalRecord.saveWithBlockAndWait({ (localContext : NSManagedObjectContext!) in
            Hangout.MR_truncateAllInContext(localContext)
        })
        _hangoutFetchedResultsController = nil
        hometablelistview.reloadData()
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
        }
        xmppStream = appDelegate!.xmppStream
        xmppHangout = appDelegate!.xmppHangout
        appDelegate!.xmppRoster.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        xmppHangout!.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        hometablelistview.estimatedRowHeight = 44.0
        locationlists = XMPPHangoutDataManager.initLocationData()
    }
    
    deinit
    {
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
            let indexpath = NSIndexPath(forRow: indexPath.row, inSection: 0)
            let hangout = self.hangoutFetchedRequestControler!.objectAtIndexPath(indexpath) as! Hangout
            let message = hangout.getLatestMessage()
            let time = hangout.getLatestTime()
            let otheruser = hangout.getUser(xmppStream!.myJID)
            if (otheruser!.goingstatus != "notgoing")
            {
                hangoutcell.messageLabel.text = message?.content
                hangoutcell.dateLabel.text = time?.timedescription
            }
            else
            {
                hangoutcell.dateLabel.text = time?.timedescription
                if (hangout.createUserJID != xmppStream!.myJID.bare())
                {
                    hangoutcell.messageLabel.text = "You are not avaiable"
                }
                else
                {
                    let jid = XMPPJID.jidWithString(otheruser?.jidstr)
                    if let user = rosterStorage.userForJID(jid, xmppStream: xmppStream!, managedObjectContext: rosterDBContext)
                    {
                        if (user.nickname != nil)
                        {
                            hangoutcell.messageLabel.text = "\(user.nickname) can not catch up this weekend"
                        }
                    }
                }
            }

            hangoutcell.collectionView.indexPath = indexpath
            if let location = hangout.getLatestLocation() as HangoutLocation?
            {
                hangoutcell.locationViewContainer.hidden = false
                if let locationdic = locationlists!.objectAtIndex((location.locationid?.integerValue)!) as? NSDictionary
                {
                    let address = locationdic.objectForKey("address") as! String
                    let photopath = locationdic.objectForKey("photopath") as! String
                    hangoutcell.placeLabel.text = address
                    if (otheruser!.goingstatus != "notgoing")
                    {
                        hangoutcell.bgimageview.image = UIImage(named: photopath)
                    }
                    else
                    {
                        hangoutcell.bgimageview.image = UIImage(named: photopath)?.grayscale()
                    }
                }
            }
            else
            {
                hangoutcell.locationViewContainer.hidden = true
                if (otheruser!.goingstatus != "notgoing")
                {
                    hangoutcell.bgimageview.image = UIImage(named: "bbb.jpg")
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
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section != 0)
        {
            if (self.hangoutFetchedRequestControler != nil)
            {
                let sectionInfo = self.hangoutFetchedRequestControler!.sections
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
            return 400
        }
        else
        {
            return UITableViewAutomaticDimension
        }
    }
    
    var _hangoutFetchedResultsController: NSFetchedResultsController? = nil
    var hangoutFetchedRequestControler : NSFetchedResultsController?
    {
        if _hangoutFetchedResultsController != nil{
            return _hangoutFetchedResultsController!
        }
        let request =  xmppHangoutDB.getHangoutListRequest(xmppStream!.myJID)
        if (request != nil)
        {
            let afetchedController = NSFetchedResultsController(fetchRequest: request!, managedObjectContext: NSManagedObjectContext.MR_context(), sectionNameKeyPath: nil, cacheName: nil)
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
    
    // MARK: Action View
    func displayCreateHangoutView(friend:XMPPUserCoreDataStorageObject)
    {
        //TODO: check the database and decide which view shall be called
        let activeHangout = xmppHangoutDB.hasActiveHangout(friend.jid, xmppstream: xmppStream!)
        if (activeHangout != nil)
        {
            let otheruser = activeHangout!.getUser(xmppStream!.myJID)
            if otheruser?.goingstatus == "notgoing"
            {
                ErrorHandler.showPopupMessage(self.view, text: "Try another time")
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
// MARK: FriendContainerDelegate
    
    func didTouchFriend(friend: XMPPUserCoreDataStorageObject!, rect: CGRect)
    {
        if (friend.subscription  == "both")
        {
            self.displayCreateHangoutView(friend)
        }
        else
        {
            ErrorHandler.showPopupMessage(self.view, text: "Waiting for friend invitation  response")
        }
    }
    
    func didTouchAddFriend()
    {
        let fbrequest = FBRequest.requestForMyFriends()
        fbrequest.startWithCompletionHandler {
            (connection:FBRequestConnection!,   result:AnyObject!, error:NSError!) -> Void in
            let fblists = result.objectForKey("data") as? NSArray
            let fbviewcontroller = self.storyboard?.instantiateViewControllerWithIdentifier("FBFriendListViewController") as! FBFriendListViewController?
            fbviewcontroller!.friendlists = fblists
            self.navigationController?.pushViewController(fbviewcontroller!, animated: true)
        }
    }

    func didTouchMe()
    {
        self.performSegueWithIdentifier("ProfileViewController", sender: nil)
    }
    
    //Mark: XMPPRosterDelegate
    func xmppRosterDidEndPopulating(sender:XMPPRoster)
    {
        hometablelistview.reloadData()
    }
    
    func xmppRoster(sender:XMPPRoster, didReceiveRosterPush iq:XMPPIQ)
    {
        hometablelistview.reloadData()
    }
    
    //Mark: XMPPHangoutDelegate
    func xmppHangout(sender:XMPPHangout, didCreateHangout iq:XMPPIQ)
    {
        XMPPLoggingWrapper.XMPPLogTrace()
        _hangoutFetchedResultsController = nil
        hometablelistview.reloadData()
    }
    
    func xmppHangout(sender:XMPPHangout, didReceiveMessage message:XMPPMessage)
    {
        XMPPLoggingWrapper.XMPPLogTrace()
        _hangoutFetchedResultsController = nil
        hometablelistview.reloadData()
    }
    
    func xmppHangout(sender:XMPPHangout, didCloseHangout iq:XMPPIQ)
    {
        XMPPLoggingWrapper.XMPPLogTrace()
        _hangoutFetchedResultsController = nil
        hometablelistview.reloadData()
    }
    
    func xmppHangout(sender:XMPPHangout, didUpdateHangout iq:XMPPIQ)
    {
        XMPPLoggingWrapper.XMPPLogTrace()
        _hangoutFetchedResultsController = nil
        hometablelistview.reloadData()
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
                let hangout = self.hangoutFetchedRequestControler!.objectAtIndexPath(cellindexpath) as! Hangout
                let otheruser = XMPPJID.jidWithString(hangout.getUser(me.jid)!.jidstr!)
                let friend = rosterStorage.userForJID(otheruser, xmppStream: self.xmppStream, managedObjectContext: rosterDBContext)
                friendView = FriendView.friendViewWithFriend(friend) as? UIView
            }
            else{
                friendView = FriendView.friendViewWithFriend(nil) as? UIView
            }
        }
        friendView!.frame = cell.bounds;
        cell.addSubview(friendView!)
        return cell
    }
}
