//
//  XMPPHangout.swift
//  thirdplace
//
//  Created by Yang Yu on 3/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit
@objc protocol XMPPHangoutDelegate
{
    func xmppHangout(sender:XMPPHangout, didCreateHangout iq:XMPPIQ);
    func xmppHangout(sender:XMPPHangout, didUpdateHangout iq:XMPPIQ);
    func xmppHangout(sender:XMPPHangout, didCloseHangout iq:XMPPIQ);
    func xmppHangout(sender:XMPPHangout, didReceiveMessage message:XMPPMessage);
}

class XMPPHangout: XMPPModule
{
    let dbmanager: XMPPHangoutStorage
    let hangout_xmlns = "hangout:iq:detail"
    let hangout_message_detail_xmlns = "hangout:message:detail"
    
    init(db: XMPPHangoutStorage)
    {
        self.dbmanager = db
        super.init(dispatchQueue: nil)
    }
    
    override func activate(aXmppStream: XMPPStream!) -> Bool
    {
        XMPPLoggingWrapper.XMPPLogTrace()
        if (super.activate(aXmppStream))
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    override func deactivate() {
        XMPPLoggingWrapper.XMPPLogTrace()
        super.deactivate()
    }
    
    func sendHangoutInvitation(hangout:Hangout, sender:XMPPJID)
    {
        let block = {
            autoreleasepool {
                let create = DDXMLElement(name: "create", xmlns: self.hangout_xmlns)
                let iq = XMPPIQ.iqWithType("set", elementID: self.xmppStream.generateUUID())
                iq.addAttributeWithName("from", stringValue: sender.bare())
                iq.addAttributeWithName("to", stringValue:AppConfig.thirdplaceModule())
                 //hangout
                let hangoutElement = DDXMLElement(name: "hangout")
                let descriptionElement = DDXMLElement(name: "description", stringValue: hangout.hangoutdescription)
                let usersElement = DDXMLElement(name: "users")
                let user = DDXMLElement(name: "user", stringValue: hangout.getUser(sender)?.jidstr)
                usersElement.addChild(user)
                let hangoutlatesttime = hangout.getLatestTime()
                let startElement = DDXMLElement(name: "startdate", stringValue: hangout.getLatestTime()?.startdate?.convertToString("yyyy-MM-dd HH:mm"))
                let endElement = DDXMLElement(name: "enddate", stringValue: hangoutlatesttime!.enddate?.convertToString("yyyy-MM-dd HH:mm"))
                let timedescription = DDXMLElement(name: "timedescription", stringValue:  hangoutlatesttime!.timedescription)
                if (hangout.getLatestMessage() != nil)
                {
                    let message = DDXMLElement(name: "message", stringValue: hangout.getLatestMessage()!.content)
                    hangoutElement.addChild(message)
                }
                let preferlocation = DDXMLElement(name: "preferredlocation", stringValue: hangout.preferedlocation)
                hangoutElement.addChild(usersElement)
                hangoutElement.addChild(startElement)
                hangoutElement.addChild(endElement)
                hangoutElement.addChild(descriptionElement)
                hangoutElement.addChild(timedescription)
                hangoutElement.addChild(preferlocation)
                create.addChild(hangoutElement)
                iq.addChild(create)
                self.xmppStream.sendElement(iq)
            }
        }
        if (dispatch_get_specific(moduleQueueTag) != nil)
        {
            block()
        }
        else
        {
            dispatch_async(moduleQueue, block)
        }
    }
    
    func updateHangout(hangout:Hangout, sender:XMPPJID)
    {
        let block = {
            autoreleasepool {
                let update = DDXMLElement(name: "update", xmlns: self.hangout_xmlns)
                let iq = XMPPIQ.iqWithType("set", elementID: self.xmppStream.generateUUID())
                iq.addAttributeWithName("from", stringValue: sender.bare())
                iq.addAttributeWithName("to", stringValue:AppConfig.thirdplaceModule())
                //hangout
                let hangoutElement = DDXMLElement(name: "hangout")
                hangoutElement.addAttributeWithName("id", stringValue: hangout.hangoutid!.stringValue)
                let descriptionElement = DDXMLElement(name: "description", stringValue: hangout.hangoutdescription)
                let usersElement = DDXMLElement(name: "users")
                let user = DDXMLElement(name: "user", stringValue: hangout.getUser(sender)?.jidstr)
                usersElement.addChild(user)
                let hangoutlatesttime = hangout.getLatestTime()
                let timeElement = DDXMLElement(name: "time")
                
                let startElement = DDXMLElement(name: "startdate", stringValue: hangout.getLatestTime()?.startdate?.convertToString("yyyy-MM-dd HH:mm"))
                let endElement = DDXMLElement(name: "enddate", stringValue: hangoutlatesttime!.enddate?.convertToString("yyyy-MM-dd HH:mm"))
                let timedescription = DDXMLElement(name: "timedescription", stringValue:  hangoutlatesttime!.timedescription)
                let timeconfirm = DDXMLElement(name: "timeconfirm", stringValue: "false")
                timeElement.addChild(startElement)
                timeElement.addChild(endElement)
                timeElement.addChild(timedescription)
                timeElement.addChild(timeconfirm)
                if (hangout.getLatestMessage() != nil)
                {
                    let message = DDXMLElement(name: "message", stringValue: hangout.getLatestMessage()!.content)
                    hangoutElement.addChild(message)
                }
                if let locationHangout = hangout.getLatestLocation()
                {
                    let locationElement = DDXMLElement(name: "location")
                    let locationid = DDXMLElement(name: "locationid", stringValue: locationHangout.locationid!.stringValue)
                    let locationconfirm = DDXMLElement(name: "locationconfirm", stringValue: "false")
                    locationElement.addChild(locationid)
                    locationElement.addChild(locationconfirm)
                    hangoutElement.addChild(locationElement)
                }
                hangoutElement.addChild(usersElement)
                hangoutElement.addChild(timeElement)
                hangoutElement.addChild(descriptionElement)
                update.addChild(hangoutElement)
                iq.addChild(update)
                self.xmppStream.sendElement(iq)
            }
        }
        if (dispatch_get_specific(moduleQueueTag) != nil)
        {
            block()
        }
        else
        {
            dispatch_async(moduleQueue, block)
        }
    }
    
    func cancelHangoutInvitation(hangout:Hangout, sender:XMPPJID)
    {
        let block = {
            autoreleasepool {
                let close = DDXMLElement(name: "close", xmlns: self.hangout_xmlns)
                let iq = XMPPIQ.iqWithType("set", elementID: self.xmppStream.generateUUID())
                iq.addAttributeWithName("from", stringValue: sender.bare())
                iq.addAttributeWithName("to", stringValue:AppConfig.thirdplaceModule())
                //hangout
                let hangoutElement = DDXMLElement(name: "hangout")
                hangoutElement.addAttributeWithName("id", stringValue: hangout.hangoutid!.stringValue)
                let usersElement = DDXMLElement(name: "users")
                let user = DDXMLElement(name: "user", stringValue: hangout.getUser(sender)?.jidstr)
                usersElement.addChild(user)
                hangoutElement.addChild(usersElement)
                close.addChild(hangoutElement)
                iq.addChild(close)
                self.xmppStream.sendElement(iq)
            }
        }
        if (dispatch_get_specific(moduleQueueTag) != nil)
        {
            block()
        }
        else
        {
            dispatch_async(moduleQueue, block)
        }
    }
    
    func xmppStream(sender:XMPPStream, didReceiveIQ iq: XMPPIQ) -> Bool
    {
        XMPPLoggingWrapper.XMPPLogTrace()
        let createquery = iq.elementForName("create", xmlns: self.hangout_xmlns)
        if (createquery != nil)
        {
            if(iq.isResultIQ())
            {
                let pcontext = XMPPHangoutDataManager.singleInstance.privateContext()
                let hangout = Hangout.MR_findFirstByAttribute("hangoutid", withValue: NSNumber(integer: HangoutConfig.tempHangoutID), inContext: pcontext)
                let newid = createquery.stringValue()
                hangout.hangoutid = Int(newid)
                pcontext.MR_saveToPersistentStoreAndWait()
                XMPPHangoutDataManager.singleInstance.resetPrivateContext()
                self.multicastDelegate().xmppHangout(self, didCreateHangout: iq);
                return true
            };
        }
        let updateQuery = iq.elementForName("update", xmlns: self.hangout_xmlns)
        if (updateQuery != nil)
        {
            let pcontext = XMPPHangoutDataManager.singleInstance.privateContext()
            pcontext.MR_saveToPersistentStoreAndWait()
            XMPPHangoutDataManager.singleInstance.resetPrivateContext()
            self.multicastDelegate().xmppHangout(self, didUpdateHangout: iq);
            return true
        }
        let closeQuery = iq.elementForName("close", xmlns: self.hangout_xmlns)
        if (closeQuery != nil)
        {
            let pcontext = XMPPHangoutDataManager.singleInstance.privateContext()
            pcontext.MR_saveToPersistentStoreAndWait()
            XMPPHangoutDataManager.singleInstance.resetPrivateContext()
            self.multicastDelegate().xmppHangout(self, didCloseHangout: iq);
            return true
        }
        return false
    }
    
    func xmppStream(sender: XMPPStream, didReceiveMessage message:XMPPMessage)
    {
        XMPPLoggingWrapper.XMPPLogTrace()
        let jidfrom = message.from()
        let hangoutquery = message.elementForName("hangout", xmlns: hangout_message_detail_xmlns)
        dbmanager.handleHangout(hangoutquery, stream: sender, fromjid: jidfrom)
        self.multicastDelegate().xmppHangout(self, didReceiveMessage: message);
    }
}
