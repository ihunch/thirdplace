//
//  HomeScreenViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 16/09/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendContainerViewDelegate, AddFriendViewControllerDelegate {

    @IBOutlet weak var hometablelistview: UITableView!
    
    override func viewDidLoad() {
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendContainerTableViewCell") as? FriendContainerTableViewCell
            return cell!
        }
        else
        {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0
        {
            let c = cell as? FriendContainerTableViewCell
            c!.setNeedsLayout()
            c!.setDelegate(self)
            c!.friendContainerView.updateLayout()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section != 0)
        {
            return 30
        }
        else
        {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0)
        {
            return 400
        }
        else
        {
            return 80
        }
    }
    
    func didTouchAddFriend() {
        
    }
    // MARK: FriendContainerDelegate
    func didTouchFriend(friend: Friend!, rect: CGRect) {
        self.displayCreateHangoutView()
    }
    
    func didTouchMe() {
        self.performSegueWithIdentifier("ProfileViewController", sender: nil)
    }
    // MARK: AddFriendViewDelegate
    func didAddFriend(friend: Friend!) {
        
    }
    
    func displayCreateHangoutView()
    {
        let dashboardController = self.storyboard?.instantiateViewControllerWithIdentifier("HangoutTableViewController") as! HangoutTableViewController?
        dashboardController?.title = "Hangout"
        if dashboardController != nil
        {
            self.navigationController?.pushViewController(dashboardController!, animated: true)
        }
    }
}
