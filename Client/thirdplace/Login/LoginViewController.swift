//
//  LoginViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 27/09/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,FBLoginViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginView: FBLoginView!
    var pagecontentController: UIPageViewController!
    var delegate: HomeScreenDelegate!
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    // Create the data model
    let pageTitles = ["Welcome Thirdplace", "page2", "page3", "page4"]
    let pageImages = ["page1", "page2", "page3", "page4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginView.delegate = self;
        self.loginView.readPermissions = ["public_profile", "email", "user_friends"];
        activityIndicatorView.center = loginView.center;
        activityIndicatorView.hidesWhenStopped = true
        self.view.addSubview(activityIndicatorView)
        if (pagecontentController == nil)
        {
            pagecontentController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginPageViewController") as? UIPageViewController
            pagecontentController.delegate = self
            pagecontentController.dataSource = self
            
            let contentview = self.viewControllerAtIndex(0)
            let viewControllers = [contentview]
            pagecontentController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
            self.addChildViewController(pagecontentController!)
            self.view.addSubview(pagecontentController.view)
            self.pagecontentController.didMoveToParentViewController(self)
        }
        self.view.bringSubviewToFront(activityIndicator)
        self.view.bringSubviewToFront(loginView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser)
  {
        loginView.hidden = true
        activityIndicatorView.startAnimating()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
           let profilePictureURL = NSString(format: "https://graph.facebook.com/%@/picture?type=large", user.objectID)
           let profilePictureData = NSData(contentsOfURL: NSURL(string: profilePictureURL as String)!)
            if (profilePictureData != nil)
            {
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as NSString
                let subfolder = documentsDirectory.stringByAppendingPathComponent("profile_pictures") as NSString
                
                do
                {
                    try NSFileManager.defaultManager().createDirectoryAtPath(subfolder as String, withIntermediateDirectories: true, attributes: nil)
                    let filename = NSProcessInfo.processInfo().globallyUniqueString
                    let dest = subfolder.stringByAppendingPathComponent(filename)
                    profilePictureData!.writeToFile(dest, atomically: true)
                    AppConfig.updateLoginUserPhotoPath(filename)
                }
                catch let error as NSError
                {
                   error.description
                }
            }
        })
        
        dispatch_async(dispatch_get_main_queue(),
        {
            self.delegate.didFBLoginSuccess()
            loginView.hidden = true
        })
    }
    
    func loginView(loginView : FBLoginView!, error: NSError)
    {
        var alertMessage: String? = nil
        //var alertTitle: String? = nil
        
        // If the user should perform an action outside of you app to recover,
        // the SDK will provide a message for the user, you just need to surface it.
        // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
        if (FBErrorUtility.shouldNotifyUserForError(error))
        {
             //alertTitle = "Facebook Error"
             alertMessage = FBErrorUtility.userMessageForError(error)
            // This code will handle session closures that happen outside of the app
            // You can take a look at our error handling guide to know more about it
            // https://developers.facebook.com/docs/ios/errors
        }
        else if (FBErrorUtility.errorCategoryForError(error) == FBErrorCategory.AuthenticationReopenSession)
        {
            //alertTitle = "Session Error";
            alertMessage = "Your current session is no longer valid. Please log in again."
        }
        else
        {
            //alertTitle  = "Something went wrong"
            alertMessage = "Please try again later."
            NSLog("Unexpected error:%@", error);
        }
        if (alertMessage != nil)
        {
            ErrorHandler.showPopupMessage(self.view, text: alertMessage!)
        }
        print("error")
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!)
    {
        print("User Logged Out")
    }
    
    // MARK: Page View Controller
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        if let pcontroller = viewController as? LoginContentViewController
        {
            var index = pcontroller.pageIndex
            if (index == 0  || index == NSNotFound) {
                return nil
            }
            index--
            return self.viewControllerAtIndex(index)
        }
        return nil
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let pcontroller = viewController as? LoginContentViewController
        {
            var index = pcontroller.pageIndex
            if (index == NSNotFound) {
                return nil;
            }
            index++
            if (index == self.pageImages.count) {
                return nil;
            }
            return self.viewControllerAtIndex(index)
        }
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func viewControllerAtIndex(index:Int) -> LoginContentViewController
    {
        let contentController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginContentViewController") as? LoginContentViewController
        contentController!.imageFile = pageImages[index]
        contentController!.pageIndex = index
        return contentController!
    }

}
