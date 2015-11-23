//
//  UIAlertExtension.swift
//  thirdplace
//
//  Created by Yang Yu on 23/11/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import Foundation

public class CustomUIAlertView: UIAlertView{
    var _customobject:AnyObject?
    var customobject:AnyObject?{
        get{
            return _customobject
        }
        set(newvalue)
        {
            _customobject = newvalue
        }
    }
}