//
//  XMPPHangoutDataManager.swift
//  thirdplace
//
//  Created by Yang Yu on 3/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import Foundation

@objc protocol XMPPHangoutStorage
{
    func handleHangout(item: DDXMLElement, stream: XMPPStream, fromjid: XMPPJID)
}

private let _SingletonInstance = XMPPHangoutDataManager()
@objc class XMPPHangoutDataManager : NSObject, XMPPHangoutStorage
{
    private var privatecontext : NSManagedObjectContext?
    class var singleInstance : XMPPHangoutDataManager
        {
        get {
            return _SingletonInstance
        }
    }
    
    func privateContext() -> NSManagedObjectContext
    {
        if privatecontext != nil
        {
            return privatecontext!
        }
        else
        {
            privatecontext = NSManagedObjectContext.MR_context()
            return privatecontext!
        }
    }
    
    func resetPrivateContext()
    {
        privatecontext = nil
    }
    
    func handleHangout(item: DDXMLElement, stream: XMPPStream, fromjid: XMPPJID)
    {
        //hangoutid
        let hangoutid = Int(item.elementForName(HangoutConfig.hangoutkey).stringValue())
        let startdatestr = item.elementForName(HangoutConfig.startdatekey).stringValue()
        let enddatestr = item.elementForName(HangoutConfig.enddatekey).stringValue()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let startdate = dateFormatter.dateFromString(startdatestr)!.mt_inTimeZone(NSTimeZone.localTimeZone())
        let enddate = dateFormatter.dateFromString(enddatestr)!.mt_inTimeZone(NSTimeZone.localTimeZone())
        let description = item.elementForName(HangoutConfig.descriptionkey).stringValue()
        let timedescription = item.elementForName(HangoutConfig.timedescriptionkey).stringValue()
        let message = item.elementForName(HangoutConfig.messagekeykey).stringValue()
        let locationid = Int(item.elementForName(HangoutConfig.locationidkey).stringValue())
        
        MagicalRecord.saveWithBlockAndWait({ (localContext : NSManagedObjectContext!) in
            
            let hangout = Hangout.MR_findFirstByAttribute("hangoutid", withValue:  NSNumber(integer: hangoutid!), inContext: localContext)
            if hangout == nil
            {
                let newhangout = Hangout.MR_createEntityInContext(localContext)
                newhangout.hangoutid = NSNumber(integer: hangoutid!)
                newhangout.hangoutdescription = description
                newhangout.createtime = NSDate()
                newhangout.createUserJID = fromjid.bare()
                
                let hangoutmessage = HangoutMessage.MR_createEntityInContext(localContext)
                hangoutmessage.content = message
                hangoutmessage.updatetime = NSDate()
                hangoutmessage.updatejid = fromjid.bare()
                hangoutmessage.hangout = newhangout
                
                let hangouttime = HangoutTime.MR_createEntityInContext(localContext)
                hangouttime.hangout = newhangout
                hangouttime.startdate = startdate
                hangouttime.enddate = enddate
                hangouttime.timedescription = timedescription
                hangouttime.updatetime = NSDate()
                
                let hangoutUser = HangoutUser.MR_createEntityInContext(localContext)
                hangoutUser.goingstatus = "maybe"
                hangoutUser.username = fromjid.bare()
                hangoutUser.jidstr = fromjid.bare()
                hangoutUser.hangout = newhangout
                
                let me = HangoutUser.MR_createEntityInContext(localContext)
                me.goingstatus = "maybe"
                me.username = stream.myJID.bare()
                me.jidstr =  stream.myJID.bare()
                me.hangout = newhangout
                
                let hangoutlocation = HangoutLocation.MR_createEntityInContext(localContext)
                hangoutlocation.updatetime = NSDate()
                hangoutlocation.updatejid = fromjid.bare()
                hangoutlocation.locationid = NSNumber(integer: locationid!)
                hangoutlocation.hangout = newhangout
            }
            else
            {
                //TODO ADD HANGOUT + UPDATE
                let hangoutmessage = HangoutMessage.MR_createEntityInContext(localContext)
                hangoutmessage.content = message
                hangoutmessage.updatetime = NSDate()
                hangoutmessage.updatejid = fromjid.bare()
                hangoutmessage.hangout = hangout
                
                let hangouttime = HangoutTime.MR_createEntityInContext(localContext)
                hangouttime.hangout = hangout
                hangouttime.startdate = startdate
                hangouttime.enddate = enddate
                hangouttime.timedescription = timedescription
                hangouttime.updatetime = NSDate()
                
                let hangoutlocation = HangoutLocation.MR_createEntityInContext(localContext)
                hangoutlocation.updatetime = NSDate()
                hangoutlocation.updatejid = fromjid.bare()
                hangoutlocation.locationid = NSNumber(integer: locationid!)
                hangoutlocation.hangout = hangout
            }
        })
    }
}
//MARK: Public methods
extension XMPPHangoutDataManager
{
    func getHangoutListRequest(myjid: XMPPJID?) -> NSFetchRequest
    {
        let now = NSDate()
        let filter = NSPredicate(format: "Any self.user.jidstr == %@ && Any self.time.enddate >= %@", myjid!.bare(), now)
        return Hangout.MR_requestAllSortedBy("hangoutid", ascending: true, withPredicate: filter)
    }
    
    //to check if the hangout dialog is active
    //active is based on the the date
    func hasActiveHangout(senderjid: XMPPJID, xmppstream: XMPPStream) -> Hangout?
    {
        let now = NSDate()
        let filter = NSPredicate(format: "Any self.user.jidstr == %@ && Any self.time.enddate >= %@", senderjid.bare(), now)
        let lists = Hangout.MR_findAllWithPredicate(filter)
        if (lists.count == 1)
        {
            return lists.last as? Hangout
        }
        else if (lists.count > 1)
        {
            assertionFailure("active hangout shall only return one data")
            return nil
        }
        else
        {
            return nil
        }
    }
}
//MARK: UTILITY
extension XMPPHangoutDataManager
{
    class func initHangoutDayData() -> [Hangout_Day]{
        return [Hangout_Day(day_description: "Weekend",dayvalue: 8),Hangout_Day(day_description: "Saturday", dayvalue:7),Hangout_Day(day_description: "Sunday",dayvalue:1)]
    }
    
    class func  initHangoutTimeData() -> [Hangout_Time]
    {
        return [Hangout_Time(time_description: "Brunch", time: 10),Hangout_Time(time_description: "Lunch", time: 12),Hangout_Time(time_description: "Afvo", time: 14)]
    }
}
class Hangout_Day
{
    var day_description: String?
    var dayvalue: Int
    init(day_description:String, dayvalue: Int)
    {
        self.day_description = day_description
        self.dayvalue = dayvalue
    }
}

class Hangout_Time
{
    init(time_description:String, time:Float)
    {
        self.time_description = time_description
        self.time = time
    }
    
    var time_description: String?
    var time: Float?
}

struct HangoutConfig {
    static var tempHangoutID = -1
    static var hangoutkey = "hangoutid"
    static var startdatekey = "startdate"
    static var enddatekey = "enddate"
    static var descriptionkey = "description"
    static var timedescriptionkey = "timedescription"
    static var messagekeykey = "message"
    static var locationidkey = "locationid"
}