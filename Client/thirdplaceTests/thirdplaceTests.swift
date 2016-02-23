
//
//  thirdplaceTests.swift
//  thirdplaceTests
//
//  Created by Yang Yu on 26/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import XCTest

class thirdplaceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //MagicalRecord.setupCoreDataStack()
        NSDate.mt_setTimeZone(NSTimeZone(abbreviation: "GMT"))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        //MagicalRecord.cleanUp()
    }
    
    func testDate() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mma"
        let result2 = formatter.dateFromString("02/19/2016 7:00pm")
        let date = result2?.mt_dateDaysAfter(1)
        print(result2!.mt_weekdayOfWeek())
        print(date!.mt_weekdayOfWeek())
        print(date!.mt_endOfCurrentWeek())
        print(date!.mt_startOfNextWeek())
        
        let now = date!.mt_startOfCurrentDay()
        let sat = now!.mt_endOfCurrentWeek().mt_dateDaysBefore(1).mt_dateSecondsAfter(1)
        let sun = now!.mt_endOfCurrentWeek().mt_dateHoursAfter(24)
        print(sat)
        print(sun)
        
//
//        let nextsat = date!.getNextSaturday()!.mt_inTimeZone(NSTimeZone.localTimeZone())
//        let nextsats = result2!.getNextSaturday()!.mt_inTimeZone(NSTimeZone.localTimeZone())
//        let sunday =  nextsat!.mt_dateHoursAfter(24)
//        let nsunday =  nextsats!.mt_dateHoursAfter(24)
//        let d = date!.mt_endOfCurrentWeek()
//        let dd = date!.mt_startOfNextWeek()
//        let date2 = NSDate().mt_inTimeZone(NSTimeZone.localTimeZone())
//        print(date)
//        print(date2)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCafeAUData()
    {
        let path = NSBundle.mainBundle().pathForResource("cafe_au", ofType: "plist")
        let lists = NSArray(contentsOfFile: path!)
        for l in lists!
        {
            let locationdic = l as! NSDictionary
            let photopath = locationdic.objectForKey("photopath") as! String
            let image = UIImage(named: photopath)
            assert(image != nil)
        }
        
    }
    
}
