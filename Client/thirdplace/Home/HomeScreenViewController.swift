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

@objc class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendContainerViewDelegate,HomeScreenDelegate,NSFetchedResultsControllerDelegate {

    @IBAction func touch(sender: AnyObject)
    {
        MagicalRecord.saveWithBlockAndWait({ (localContext : NSManagedObjectContext!) in
            Hangout.MR_truncateAllInContext(localContext)
        })
        _hangoutFetchedResultsController = nil
        hometablelistview.reloadData()
    }
    
    @IBOutlet weak var hometablelistview: UITableView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    let xmppHangoutDB = XMPPHangoutDataManager.singleInstance
    var xmppStream: XMPPStream?
    var xmppHangout: XMPPHangout?
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
            let hangoutcell = tableView.dequeueReusableCellWithIdentifier("HangoutListTableViewCell") as? HangoutListTableViewCell
            let indexpath = NSIndexPath(forRow: indexPath.row, inSection: 0)
            let hangout = self.hangoutFetchedRequestControler.objectAtIndexPath(indexpath) as! Hangout
            let message = hangout.getLatestMessage()
            hangoutcell!.mainLabel.text = message?.content
            return hangoutcell!
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
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section != 0)
        {
            let sectionInfo = self.hangoutFetchedRequestControler.sections
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
            return 80
        }
    }
    
    var _hangoutFetchedResultsController: NSFetchedResultsController? = nil
    var hangoutFetchedRequestControler : NSFetchedResultsController
    {
        if _hangoutFetchedResultsController != nil{
            return _hangoutFetchedResultsController!
        }
        let request =  xmppHangoutDB.getHangoutListRequest(xmppStream!.myJID)
        let afetchedController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: NSManagedObjectContext.MR_context(), sectionNameKeyPath: nil, cacheName: nil)
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
        return _hangoutFetchedResultsController!
    }
    
    // MARK: Action View
    func displayCreateHangoutView(friend:XMPPUserCoreDataStorageObject)
    {
        //TODO: check the database and decide which view shall be called
        let activeHangout = xmppHangoutDB.hasActiveHangout(friend.jid, xmppstream: xmppStream!)
        if (activeHangout != nil)
        {
            if (activeHangout!.createUserJID == xmppStream!.myJID.bare())
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
    
    func didTouchFriend(friend: XMPPUserCoreDataStorageObject!, rect: CGRect) {
        self.displayCreateHangoutView(friend)
    }
    
    func didTouchAddFriend() {
        
    }

    func didTouchMe() {
        self.performSegueWithIdentifier("ProfileViewController", sender: nil)
    }
    
    // MARK: AddFriendViewDelegate
//    func didAddFriend(friend: Friend!) {
//        
//    }
    
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
}
