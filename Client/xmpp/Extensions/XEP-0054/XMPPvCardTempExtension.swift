//
//  XMPPvCardTempExtension.swift
//  thirdplace
//
//  Created by Yang Yu on 3/12/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import Foundation

extension XMPPvCardTemp
{
    func getNotificationToken() -> String?
    {
        if let t = self.elementForName("TOKEN")
        {
            return t.stringValue()
        }
        else
        {
            return nil
        }
    }
    
    func addNotificationToken(token : String)
    {
        if let tokenElement = self.elementForName("TOKEN")
        {
            tokenElement.setStringValue(token)
        }
        else
        {
            let tokenElement = DDXMLElement.elementWithName("TOKEN", stringValue: token) as! DDXMLElement
            self.addChild(tokenElement)
        }
    }
}