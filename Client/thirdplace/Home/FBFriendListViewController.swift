//
//  FBFriendListViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 18/11/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import Foundation

class FBFriendListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var fblists: UITableView!
    
    @IBOutlet weak var inviteButton: UIBarButtonItem!
    
    var selectfb: NSMutableDictionary = NSMutableDictionary()
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    var rosterDBContext : NSManagedObjectContext?
    var friendlists : NSArray? = nil
    
    var xmppRoster: XMPPRoster{
        get{
            return self.appDelegate!.xmppRoster
        }
    }
    
    var rosterStorage: XMPPRosterCoreDataStorage{
        get{
            return self.appDelegate!.xmppRosterStorage
        }
    }
    var xmppStream: XMPPStream{
        get{
            return self.appDelegate!.xmppStream
        }
    }
    
    override func viewDidLoad()
    {
        rosterDBContext = self.appDelegate!.managedObjectContext_roster()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBarHidden = false
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.navigationBarHidden = true
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.friendlists != nil
        {
            return self.friendlists!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "fbfriendcell")
        let fbdata = friendlists!.objectAtIndex(indexPath.row) as! FBGraphObject
        cell.textLabel?.text = fbdata["name"] as? String
        cell.detailTextLabel?.text = ""
        let fid = fbdata["id"] as? String
        let jidstr = self.appDelegate!.stringToJID(fid)
        let jid = XMPPJID.jidWithString(jidstr)
        let xmppuser = rosterStorage.userForJID(jid, xmppStream: self.xmppStream, managedObjectContext: rosterDBContext)
        if (xmppuser != nil)
        {
            if (xmppuser.subscription == "both")
            {
                cell.detailTextLabel?.text = "invited"
            }
            else
            {
                cell.detailTextLabel?.text = "pending"
            }
        }
        else
        {
            cell.detailTextLabel?.text = "uninvited"     
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //Invite uninvited user
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let fbdata = friendlists!.objectAtIndex(indexPath.row) as! FBGraphObject
        let fid = fbdata["id"] as? String
        let jidstr = self.appDelegate!.stringToJID(fid)
        let jid = XMPPJID.jidWithString(jidstr)
        let xmppuser = rosterStorage.userForJID(jid, xmppStream: self.xmppStream, managedObjectContext: rosterDBContext)
        if (xmppuser == nil || xmppuser.subscription != "both")
        {
            if (selectfb.objectForKey(indexPath.row) == nil)
            {
                selectfb.setObject(jid, forKey: indexPath.row)
                cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            else
            {
                selectfb.removeObjectForKey(indexPath.row)
                cell!.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    @IBAction func inviteFriend(sender: AnyObject)
    {
        for key in selectfb.allKeys
        {
            let jid = selectfb.objectForKey(key) as! XMPPJID
            let k = key as! NSNumber
            let fbuser = friendlists?.objectAtIndex(k.integerValue) as! FBGraphObject
            let user = rosterStorage.userForJID(jid, xmppStream: self.xmppStream, managedObjectContext: self.rosterDBContext)
            if (user == nil )
            {
                let name =  fbuser["name"] as! String
                self.xmppRoster.addUser(jid, withNickname: name)
                let maincontext = NSManagedObjectContext.MR_defaultContext()
                DataManager.singleInstance.createXMPPRosterMainContext(jid, dbcontext: maincontext)
            }
            else
            {
                if (user.subscription != "from")
                {
                    self.xmppRoster.subscribePresenceToUser(jid)
                }
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}