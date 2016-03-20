//
//  thirdplaceTests.swift
//  thirdplaceTests
//
//  Created by Yang Yu on 19/03/2016.
//  Copyright © 2016 Hunch Pty Ltd. All rights reserved.
//

import XCTest
@testable import thirdplace

class thirdplaceTests: XCTestCase {
    
    let hangout_message_detail_xmlns = "hangout:message:detail"
    let hangout_lists_xmlns = "hangout:iq:list"
    let singledata = "<message xmlns=\"jabber:client\" from=\"10156721529090294@ip-172-31-1-174/4fcf9489\" to=\"1135473216471032@ip-172-31-1-174\" id=\"858013B5-E0C3-4430-9B92-147C09DD507B\"><hangout xmlns=\"hangout:message:detail\"><hangoutid>201</hangoutid><createUser>10156721529090294@ip-172-31-1-174</createUser><startdate>2016-03-19 00:00</startdate><enddate>2016-03-20 23:59</enddate><description>Want to catch up this weekend?</description><timedescription>This Weekend</timedescription><message>Want to catch up this weekend?</message><messageid>870</messageid><preferredlocation>1,0,4</preferredlocation></hangout><delay xmlns=\"urn:xmpp:delay\" from=\"ip-172-31-1-174\" stamp=\"2016-03-17T23:15:52.843Z\"/><x xmlns=\"jabber:x:delay\" from=\"ip-172-31-1-174\" stamp=\"20160317T23:15:52\"/></message>"
    let hangoutlistdata = "<iq xmlns=\"jabber:client\" type=\"result\" id=\"F92F6A75-AD4C-42A2-B657-EC192CEB031A\" from=\"thirdplacehangout.ip-172-31-1-174\" to=\"1135473216471032@ip-172-31-1-174/7a0b0516\"><result xmlns=\"hangout:iq:list\"><hangout id=\"201\"><createUser>10156721529090294@ip-172-31-1-174</createUser><preferredlocation>1,0,4</preferredlocation><createTime>2016-03-17 23:15</createTime><description>Want to catch up this weekend?</description><time><timedescription>This Weekend</timedescription><startdate>2016-03-19 00:00</startdate><enddate>2016-03-20 23:59</enddate><createUser>10156721529090294@ip-172-31-1-174</createUser><createTime>2016-03-17 23:15</createTime></time><messages><message><content>Want to catch up this weekend?</content><messageid>870</messageid><createUser>10156721529090294@ip-172-31-1-174</createUser><createTime>2016-03-17 23:15</createTime></message></messages><users><user jid=\"10156721529090294@ip-172-31-1-174\" goingstatus=\"going\"/><user jid=\"1135473216471032@ip-172-31-1-174\" goingstatus=\"pending\"/></users></hangout></result></iq>"
    
    var hangoutlists: XMPPIQ?
    var message: XMPPMessage?
    var xmppstream: XMPPStream?
    var myjid: XMPPJID?
    var senderjid: XMPPJID?
    var homescreenview: HomeScreenViewController!
    
    override func setUp()
    {
        super.setUp()
        NSDate.mt_setTimeZone(NSTimeZone(abbreviation: "GMT"))
        MagicalRecord.setupCoreDataStack()
        hangoutlists = try? XMPPIQ(XMLString: hangoutlistdata)
        message = try? XMPPMessage(XMLString: singledata)
        myjid = XMPPJID.jidWithString("1135473216471032@ip-172-31-1-174/7a0b0516")
        senderjid = XMPPJID.jidWithString("10156721529090294@ip-172-31-1-174/4fcf9489")
        xmppstream = XMPPStream()
        xmppstream!.myJID = myjid!
        
        homescreenview = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("HomeViewController") as! HomeScreenViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
    
    func testHangoutDataSave()
    {
        let queue = dispatch_queue_create("com.aj.serial.queue", DISPATCH_QUEUE_SERIAL)
    
        homescreenview?.view
        let tableview = homescreenview?.hometablelistview
        homescreenview._hangoutFetchedResultsController = nil
        tableview?.reloadData()
        let m = self.message!
        let list = self.hangoutlists!
        let stream = self.xmppstream!
        let sjid = self.senderjid!
        
        dispatch_async(queue,{
            let db = XMPPHangoutDataManager.singleInstance
            let hangoutquery = m.elementForName("hangout", xmlns: self.hangout_message_detail_xmlns)
            db.handleHangout(hangoutquery!, stream: stream, fromjid: sjid)
        })
        
        dispatch_async(queue,{
            let db = XMPPHangoutDataManager.singleInstance
            let listQuery = list.elementForName("result", xmlns: self.hangout_lists_xmlns)
            if (listQuery != nil)
            {
                //feed the data into hangout message
                let lists = listQuery.elementsForName("hangout")
                db.handleHangoutLists(lists, stream: stream)
            }
        })
        NSThread.sleepForTimeInterval(10)
        let now = NSDate().mt_inTimeZone(NSTimeZone.localTimeZone())
        let filter = NSPredicate(format: "Any self.user.jidstr == %@ && Any self.time.enddate >= %@", myjid!.bare(), now)
        let request = Hangout.MR_requestAllWithPredicate(filter)
        
        let sort = NSSortDescriptor(key: "sorttime", ascending: true)
        request.sortDescriptors = [sort]
        let results2  = try? NSManagedObjectContext.MR_defaultContext().executeFetchRequest(request)
        let results = Hangout.MR_findAll()
        XCTAssertEqual(1, results.count)
        XCTAssertEqual(1, results2!.count)
        homescreenview._hangoutFetchedResultsController = nil
        tableview?.reloadData()
        tableview?.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))
        XCTAssertEqual(2,  tableview?.dataSource?.numberOfSectionsInTableView!(tableview!))
        XCTAssertEqual(1,  tableview?.dataSource?.tableView(   (tableview)!, numberOfRowsInSection: 0))
        XCTAssertEqual(1,  tableview?.dataSource?.tableView(   (tableview)!, numberOfRowsInSection: 1))
    }
    
    func testHangoutRemove()
    {
        MagicalRecord.saveWithBlockAndWait({ (localContext : NSManagedObjectContext!) in
        
            let array = [1,2]
            let db = XMPPHangoutDataManager.singleInstance
            let result = db.removeHangouts(array, dbcontext: localContext)
            XCTAssertEqual(1, result.count)
        })
       
    }
    
}
