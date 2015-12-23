//
//  XMPPRosterExtension.swift
//  thirdplace
//
//  Created by Yang Yu on 23/11/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import Foundation

extension XMPPRoster{
    func acceptPresenceSubscriptionRequestFrom(jid:XMPPJID,  andAddToRoster flag:Bool, nickname name:String)
    {
        let element = XMPPPresence.init(type: "subscribed", to: jid)
        self.xmppStream.sendElement(element)
      
        // Add optionally user to our roster
        
        if (flag)
        {
           self.addUser(jid, withNickname: name)
        }
    }
}