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
    
    class var singleInstance : DataManager
    {
        get {
            return _SingletonInstance
        }
    }
    
    func getLocaldbContext() -> NSManagedObjectContext
    {
        if localdbcontext != nil
        {
           return localdbcontext!
        }
        else
        {
            localdbcontext = NSManagedObjectContext.MR_context()
            return localdbcontext!
        }
    }
    
    func releaseLocalContext()
    {
        localdbcontext = nil
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
        return result
    }
    
}