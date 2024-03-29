//
//  DataManager.swift
//  thirdplace
//
//  Created by Yang Yu on 29/09/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import Foundation

private let _SingletonInstance = DataManager()
@objc(DataManager)
class DataManager: NSObject {
    private var localdbcontext : NSManagedObjectContext?
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
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

    class var singleInstance : DataManager
    {
        get {
            return _SingletonInstance
        }
    }
        
    //MARK: - Query Functions
    func getXMPPUserFBInfo(jid: XMPPJID, dbcontext: NSManagedObjectContext?) -> XMPPRosterFB?
    {
        var result:XMPPRosterFB? = nil
        let filter = NSPredicate(format: "jid == %@", jid.bare())
        if dbcontext != nil
        {
            result = XMPPRosterFB.MR_findFirstWithPredicate(filter, inContext: dbcontext)
        }
        else
        {
            result = XMPPRosterFB.MR_findFirstWithPredicate(filter)
        }
        if (result == nil)
        {
            result = createXMPPRosterMainContext(jid,dbcontext: dbcontext)
        }
        return result
    }
   
    func createXMPPRosterMainContext(jid: XMPPJID, dbcontext: NSManagedObjectContext?) -> XMPPRosterFB
    {
        let result = XMPPRosterFB.MR_createEntity()
        var x = arc4random_uniform(280)
        if (x < 30)
        {
            x+=30
        }
        var y = arc4random_uniform(300)
        if (y < 30)
        {
            y+=30
        }
        result!.axisx = NSNumber(unsignedInt: x)
        result!.axisy = NSNumber(unsignedInt: y)
        result!.jid = jid.bare()
        result!.fbid = jid.bare().componentsSeparatedByString("@")[0]
        dbcontext?.MR_saveToPersistentStoreAndWait()
        return result!

    }
    
    func createXMPPRoster(dbcontext: NSManagedObjectContext?, _ jid: XMPPJID) -> XMPPRosterFB
    {
        let result = XMPPRosterFB.MR_createEntityInContext(dbcontext)
        var x = arc4random_uniform(280)
        if (x < 30)
        {
            x+=30
        }
        var y = arc4random_uniform(300)
        if (y < 30)
        {
            y+=30
        }
        result!.axisx = NSNumber(unsignedInt: x)
        result!.axisy = NSNumber(unsignedInt: y)
        result!.jid = jid.bare()
        result!.fbid = jid.bare().componentsSeparatedByString("@")[0]
        return result!
    }
    
    func fetchFBPhoto(username: String, _ xmppuser:XMPPUserCoreDataStorageObject)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            let profilePictureURL = NSString(format: "https://graph.facebook.com/%@/picture?type=large", username)
            let profilePictureData = NSData(contentsOfURL: NSURL(string: profilePictureURL as String)!)
            if profilePictureData != nil
            {
                let image = UIImage(data: profilePictureData!)
                //set the image
                if (image != nil)
                {
                    self.rosterStorage.setPhoto(image, forUserWithJID: xmppuser.jid.bareJID(), xmppStream: self.xmppStream)
                }
            }
        })
    }
    
}