//
//  NSDate_Extension.swift
//  thirdplace
//
//  Created by Yang Yu on 26/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import Foundation

extension NSDate
{
    func calculateSundayMidnightTime() -> NSDate
    {
        let day = self.mt_components().weekday
        if (day == Weekday.Sun.rawValue)
        {
            let year = self.mt_components().year
            let month = self.mt_components().month
            let day = self.mt_components().day
            return NSDate.mt_dateFromYear(year, month: month, day: day)
        }
        else
        {
            let sundaytime = self.mt_dateDaysAfter(1)
            let year = sundaytime.mt_components().year
            let month = sundaytime.mt_components().month
            let day = sundaytime.mt_components().day
            return NSDate.mt_dateFromYear(year, month: month, day: day)
        }
    }
}