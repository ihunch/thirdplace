//
//  LoginViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 27/09/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,FBLoginViewDelegate {

    @IBOutlet weak var loginView: FBLoginView!
    var delegate: HomeScreenDelegate!
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginView.delegate = self;
        self.loginView.readPermissions = ["public_profile", "email", "user_friends"];
        activityIndicatorView.center = loginView.center;
        activityIndicatorView.hidesWhenStopped = true
        self.view.addSubview(activityIndicatorView)
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
        })
    }
    
    func loginView(loginView : FBLoginView!, error: NSError)
    {
//        NSString *alertMessage, *alertTitle;
//        
//        // If the user should perform an action outside of you app to recover,
//        // the SDK will provide a message for the user, you just need to surface it.
//        // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
//        if ([FBErrorUtility shouldNotifyUserForError:error]) {
//            alertTitle = @"Facebook Error";
//            alertMessage = [FBErrorUtility userMessageForError:error];
//            
//            // This code will handle session closures that happen outside of the app
//            // You can take a look at our error handling guide to know more about it
//            // https://developers.facebook.com/docs/ios/errors
//        } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
//            alertTitle = @"Session Error";
//            alertMessage = @"Your current session is no longer valid. Please log in again.";
//            
//            // If the user has cancelled a login, we will do nothing.
//            // You can also choose to show the user a message if cancelling login will result in
//            // the user not being able to complete a task they had initiated in your app
//            // (like accessing FB-stored information or posting to Facebook)
//        } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
//            NSLog(@"user cancelled login");
//            
//            // For simplicity, this sample handles other errors with a generic message
//            // You can checkout our error handling guide for more detailed information
//            // https://developers.facebook.com/docs/ios/errors
//        } else {
//            alertTitle  = @"Something went wrong";
//            alertMessage = @"Please try again later.";
//            NSLog(@"Unexpected error:%@", error);
//        }
//        
//        if (alertMessage) {
//            [[[UIAlertView alloc] initWithTitle:alertTitle
//                message:alertMessage
//                delegate:nil
//                cancelButtonTitle:@"OK"
//                otherButtonTitles:nil] show];
//        }
        print("error")
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!)
    {
        print("User Logged Out")
    }
}
