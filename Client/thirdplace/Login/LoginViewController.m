//
// Created by David Lawson on 3/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "RootEntity.h"
#import "Friend.h"

@interface LoginViewController () <FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    self.loginView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id <FBGraphUser>)user
{
    loginView.hidden = YES;
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = loginView.center;
    [self.view addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];

    RootEntity *rootEntity = [RootEntity rootEntity];
    if (!rootEntity.me)
        rootEntity.me = [Friend MR_createEntity];

    rootEntity.me.firstName = user.first_name;
    rootEntity.me.lastName = user.last_name;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        NSString *profilePictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", user.objectID];
        NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
        if (profilePictureData)
        {
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *subfolder = [documentsDirectory stringByAppendingPathComponent:@"profile_pictures"];

            NSError *error;
            BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:subfolder withIntermediateDirectories:YES attributes:nil error:&error];

            if (success)
            {
                NSString *dest = [subfolder stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
                success = [profilePictureData writeToFile:dest atomically:YES];
                if (success)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        rootEntity.me.imagePath = dest;
                    });
                }
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [self performSegueWithIdentifier:@"LoggedIn" sender:nil];
        });
    });
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSString *alertMessage, *alertTitle;

    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook Error";
        alertMessage = [FBErrorUtility userMessageForError:error];

        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";

        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");

        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }

    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


@end