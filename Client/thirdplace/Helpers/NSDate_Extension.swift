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
    func getNextSaturday() -> NSDate?
    {
        let calendar = NSCalendar.currentCalendar()
        let saturday = NSDateComponents()
        saturday.weekday = 7
        return calendar.nextDateAfterDate(self, matchingComponents: saturday, options: NSCalendarOptions.MatchNextTime)
    }
}