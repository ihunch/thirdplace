//
//  ErrorHandler.swift
//  thirdplace
//
//  Created by Yang Yu on 23/12/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class ErrorHandler: NSObject {
    class func showPopupMessage(view:UIView, text:String)
    {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = MBProgressHUDMode.Text
        hud.detailsLabelText = text
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue(), {
           MBProgressHUD.hideAllHUDsForView(view, animated: true)
        });
    }
}
