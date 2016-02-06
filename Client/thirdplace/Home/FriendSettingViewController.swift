//
//  FriendSettingViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 5/02/2016.
//  Copyright © 2016 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class FriendSettingViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var selectedHangoutFriend : XMPPUserCoreDataStorageObject?
    let content = ["Favourite Places (coming soon)","Interests (coming soon)","Report","Block and Delete from friend list"]
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBOutlet weak var settingtableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "showReportWebView")
        {
            
        }
    }
}

// MARK: - Table view data source
extension FriendSettingViewController {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if (indexPath.section == 0)
        {
            return 100
        }
        else
        {
            return 70
        }
    }
    
     func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            return 0
        }
        else
        {
            return 17.0
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
            return 0
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (indexPath.section == 0)
        {
            let cell:FriendViewTableViewCell = tableView.dequeueReusableCellWithIdentifier("FriendViewTableViewCell") as! FriendViewTableViewCell
            cell.friendImageView.image = selectedHangoutFriend?.photo
            cell.namelabel.text = selectedHangoutFriend?.displayName
            return cell
        }
        else
        {
            
            let cell:OneLabelTableViewCell = tableView.dequeueReusableCellWithIdentifier("OneLabelTableViewCell") as! OneLabelTableViewCell
            cell.label.text = content[indexPath.section - 1]
            if (indexPath.section == 4)
            {
                cell.label.textColor = UIColor.redColor()
            }
            else
            {
                cell.label.textColor = UIColor.blackColor()
            }
            if (indexPath.section == 1 || indexPath.section == 2)
            {
                cell.arrow.hidden = true
            }
            else
            {
                 cell.arrow.hidden = false
            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.backgroundColor = UIColor.whiteColor()//AppConfig.themebgcolour()
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.lightGrayColor()//AppConfig.themebgcolour()
        return view
    }
    
     func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 3 || indexPath.section == 4)
        {
            self.performSegueWithIdentifier("showReportWebView", sender: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
