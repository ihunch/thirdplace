//
//  NSDateAdditions.swift
//  thirdplace
//
//  Created by Yang Yu on 11/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import Foundation

extension NSDate
{
    func convertToString(format: String) -> String
    {
        let dateformat = NSDateFormatter()
        dateformat.dateFormat = format
        dateformat.timeZone = NSTimeZone(abbreviation: "GMT")
        return dateformat.stringFromDate(self)
    }
}