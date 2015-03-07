//
//  AppDelegate.m
//  thirdplace
//
//  Created by David Lawson on 1/07/2014.
//  Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "Friend.h"
#import "RootEntity.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AppDelegate

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
    [self setupXMPPStream];
    
    [DatabaseManager setup];
    [FBLoginView class];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UINavigationController *navigationController = [storyboard instantiateInitialViewController];
    self.window.rootViewController = navigationController;

    if ([self isFbLoggedIn])
    {
        [self loginXMPP];
    }
    else
    {
        [navigationController setViewControllers:@[[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"]]];
        // TODO: Call [self loginXMPP] after fb login process
    }
    
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)dealloc
{
    [self teardownXMPPStream];
}

- (void)loginXMPP
{
    [self loginXMPP:^(bool success)
     {
         if (!success)
         {
             // TODO: Handle
             return;
         }
         
         [self openHomeView];
     }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (bool)isFbLoggedIn
{
    if (FBSession.activeSession.isOpen)
    {
        return YES;
    }
    else
    {
        FBSession *session = [[FBSession alloc] initWithPermissions:@[@"public_profile", @"email", @"user_friends"]];
        [FBSession setActiveSession:session];
        return [FBSession openActiveSessionWithAllowLoginUI:NO];
    }
}

- (void)loginXMPP:(void (^)(bool))completion
{
    if (XMPPFramework.hasLoginDetails)
    {
        completion([self connectXMPP:XMPPFramework.jid withPassword:XMPPFramework.password]);
        return;
    }
    
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary *user, NSError *error)
    {
        bool success = !error;
        
        if (success)
        {
            NSString *fbId = [user objectForKey:@"id"]; // App-scoped user id
            
            NSString *jid = [[self class] stringToJID:fbId];
            NSString *password = [[self class] stringToXmppPassword:fbId];
            
            NSString *fbFirstName = [user objectForKey:@"first_name"];
            NSString *fbLastName = [user objectForKey:@"last_name"];
            NSString *fbEmail = [user objectForKey:@"email"];
            
            NSString *fbFullName = [NSString stringWithFormat:@"%@ %@", fbFirstName, fbLastName];
            
            [XMPPFramework updateDetails:jid withPassword:password withName:fbFullName withEmail:fbEmail];
            
            success = [self connectXMPP:jid withPassword:password];
        }
        
        completion(success);
    }];
}

- (void)setupXMPPStream
{
    NSAssert(xmppStream == nil, @"Method setupXMPPStream invoked multiple times");
    
    // Setup xmpp stream
    
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Setup capabilities
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    [xmppStream setHostName:kXMPPHostName];
}

- (void)teardownXMPPStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
}

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit

    [[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}

// TODO: Call this when if/when necessary after disconnectXMPP is called
- (BOOL)connectXMPP:(NSString *)jid withPassword:(NSString *)password
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:jid]];
    
    NSError *error = nil;
    
    if ([xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
        return YES;
    
    return NO;
}

// TODO: Call this when necessary
- (void)disconnectXMPP
{
    [self goOffline];
    [xmppStream disconnect];
}

+ (NSString *) stringToJID:(NSString *) s
{
    NSString * converted = [s stringByReplacingOccurrencesOfString:@"@" withString:@"___"];
    
    NSMutableString *jid = [[NSMutableString alloc] init];
    [jid appendFormat:@"%@@%@", converted, kXMPPServerName];
    
    return jid;
}

+ (NSString *) stringToXmppPassword:(NSString *) s
{
    // TODO: Find better way of generating pw for user for quick login (this method does allow login on any device)
    return [NSString stringWithFormat:@"%u", (uint)s.hash];
}

- (void)openHomeView
{
    // TODO: SK: Fix view transitioning + figure out why this was here
    //[navigationController setViewControllers:@[[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"]]];
}

- (void)addFbFriends
{
    // NOTE: This only gets friends who are already using the app
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        
        for (NSDictionary<FBGraphUser>* fbFriend in friends) {
            XMPPJID *jid = [XMPPJID jidWithString: [[self class] stringToJID:fbFriend.objectID]];
            XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:jid xmppStream:xmppStream managedObjectContext:[self managedObjectContext_roster]];

            if (user == nil)
            {
                // TODO: This "auto-fill" is temp, the found FB friends should be easily addable to friends list from the add friends screen
                Friend *friend = [Friend MR_createEntity];
                friend.firstName = fbFriend.first_name;
                friend.lastName = fbFriend.last_name;
                friend.email = jid.description; // TODO: Add proper JID field to DB
                
                int x = arc4random_uniform(250);
                int y = arc4random_uniform(400);
                friend.xValue = x; friend.yValue = y;
                
                [[RootEntity rootEntity].friendsSet addObject:friend];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                
                [xmppRoster addUser:jid withNickname:nil];
            }
        }
    }];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIApplicationDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];

    // You can add your app-specific url handling code here if needed

    return wasHandled;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [DatabaseManager cleanUp];
    
    [self teardownXMPPStream];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (!XMPPFramework.hasLoginDetails)
        return;
    
    NSString *password = XMPPFramework.password;
    
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
    
    [self addFbFriends];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *password = XMPPFramework.password;
    
    NSError *nserror = nil;
    
    NSMutableArray *elements = [NSMutableArray array];
    [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:[xmppStream myJID].user]];
    [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:password]];
    [elements addObject:[NSXMLElement elementWithName:@"name" stringValue:XMPPFramework.name]];
    [elements addObject:[NSXMLElement elementWithName:@"email" stringValue:XMPPFramework.email]];
    
    if (![xmppStream registerWithElements:elements error:&nserror])
    {
        DDLogError(@"Error registering: %@", nserror);
        return;
    }
    
    if (![[self xmppStream] authenticateWithPassword:password error:&nserror])
    {
        DDLogError(@"Error authenticating: %@", nserror);
        return;
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
}

@end
