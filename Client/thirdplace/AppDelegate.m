//
//  AppDelegate.m
//  thirdplace
//
//  Created by David Lawson on 1/07/2014.
//  Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "HomeViewController.h"
#import "thirdplace-Swift.h"
#import "DBHeaderFile.h"
#import "XMPPvCardTemp.h"
#import "NSData+XMPP.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
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
{
    //local var
    NSMutableDictionary* buddyRequest;
    NSManagedObjectContext* privateContext;
}

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize xmppHangoutStorage;
@synthesize xmppHangout;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[[Crashlytics class]]];
    // Override point for customization after application launch.
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.backgroundColor = [UIColor blackColor];
    
    [NSDate mt_setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    application.applicationIconBadgeNumber = 0;
    [self setupXMPPStream];
    
    [MagicalRecord setupCoreDataStack];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UIViewController* rootviewcontroller = [storyboard instantiateInitialViewController];
    self.window.rootViewController = rootviewcontroller;
    [self.window makeKeyAndVisible];
    buddyRequest = [NSMutableDictionary dictionary];
    
    //push notification register
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        [Hangout MR_truncateAllInContext:localContext];
    }];
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loginXMPP:(void (^)(bool))completion
{
    if (AppConfig.hasLoginDetails)
    {
        completion([self connectXMPP:AppConfig.jid withPassword:AppConfig.password]);
        return;
    }
    
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary *user, NSError *error)
    {
        bool success = !error;
        
        if (success)
        {
            NSString *fbId = [user objectForKey:@"id"]; // App-scoped user id
            
            NSString *jid = [self stringToJID:fbId];
            NSString *password = [[self class] stringToXmppPassword:fbId];
            
            NSString *name = [user objectForKey:@"name"];
         //   NSString *fbLastName = [user objectForKey:@"last_name"];
         //   NSString *fbEmail = [user objectForKey:@"email"];
            
            NSString *fbFullName = name;
            
            [AppConfig updateDetails:jid withPassword:password withName:fbFullName withEmail:nil];
            
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
    
    // set up xmpp hangout
    xmppHangoutStorage = [XMPPHangoutDataManager singleInstance];
    xmppHangout = [[XMPPHangout alloc] initWithDb:xmppHangoutStorage];
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    [xmppHangout           activate:xmppStream];
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppHangout addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    [xmppStream setHostName:kXMPPHostName];
}

- (void)teardownXMPPStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    [xmppHangout removeDelegate:self];
    
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    [xmppHangout           deactivate];
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
    xmppHangoutStorage = nil;
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

- (NSString *)stringToJID:(NSString *) s
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
    application.applicationIconBadgeNumber = 0;
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
    
    if (!AppConfig.hasLoginDetails)
        return;
    
    NSString *password = AppConfig.password;
    
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *password = AppConfig.password;
    
    NSError *nserror = nil;
    
    NSMutableArray *elements = [NSMutableArray array];
    [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:[xmppStream myJID].user]];
    [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:password]];
    [elements addObject:[NSXMLElement elementWithName:@"name" stringValue:AppConfig.name]];
    [elements addObject:[NSXMLElement elementWithName:@"email" stringValue:AppConfig.email]];
    
    if (![xmppStream registerWithElements:elements error:&nserror])
    {
        DDLogError(@"Error registering: %@", nserror);
        return;
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    if ([iq isResultIQ])
    {
        NSXMLElement *query = [iq elementForName:@"vCard" xmlns:@"vcard-temp"];
        if (query)
        {
            // check if it's my own JID
            if ([[iq fromStr] isEqualToString:[[self.xmppStream myJID] bare]])
            {
                XMPPvCardTemp* vcard = [XMPPvCardTemp vCardTempFromElement:query];
                BOOL needsUpdate = false;
                if(vcard.formattedName == nil)
                {
                    [vcard setFormattedName:[AppConfig name]];
                    needsUpdate = true;
                }
                NSString* token = [vcard getNotificationToken];
                NSString* mytoken = [AppConfig notificationid];
                if (token == nil)
                {
                    if (mytoken != nil)
                    {
                        needsUpdate = true;
                        [vcard addNotificationToken:mytoken];
                    }
                }
                else
                {
                    if (mytoken != nil && ![token isEqualToString:mytoken])
                    {
                        needsUpdate = true;
                        [vcard addNotificationToken:mytoken];
                    }
                }
                if(needsUpdate)
                {
                    [xmppvCardTempModule updateMyvCardTemp:vcard];
                }
            }
            else
            {
                XMPPJID* jid = [buddyRequest objectForKey:[iq fromStr]];
                if (jid != nil)
                {
                    [buddyRequest removeObjectForKey:[iq fromStr]];
                    //consume the database
                    XMPPvCardTemp* vcard = [self.xmppvCardTempModule vCardTempForJID:jid shouldFetch:NO];
                    NSString* name = vcard.formattedName;
                    NSString* message =
                    [NSString stringWithFormat:@"Request from %@", name];
                    [self postAlert:@"Friend Request" body:message passobject:jid];
                }
            }
        }
    }
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

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSString *password = AppConfig.password;
    NSError *nserror = nil;
    if (![[self xmppStream] authenticateWithPassword:password error:&nserror])
    {
        DDLogError(@"Error authenticating: %@", nserror);
        return;
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //when registering fails, and if connection is open. Close connection.
    if([sender isConnected])
    {
        [self disconnect];
    }
}

- (void)disconnect
{
    [self goOffline];
    
    [xmppStream disconnect];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    XMPPJID* fromjid = presence.from;
    XMPPvCardTemp* vcard = [self.xmppvCardTempModule vCardTempForJID:fromjid shouldFetch:YES];
    if (vcard == nil)
    {
        [buddyRequest setObject:fromjid forKey:[fromjid bare]];
    }
    else
    {
        NSString* name = vcard.formattedName;
        NSString* message =
            [NSString stringWithFormat:@"Request from %@", name];
        [self postAlert:@"Friend Request" body:message passobject:fromjid];
    }
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item
{
    [privateContext MR_saveToPersistentStoreAndWait]; // push the temp fb info into persistent store.
    privateContext = nil;
}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [xmppRoster addMyJID:[[xmppStream myJID] bareJID] xmppStream:xmppStream];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIAlert
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)postAlert:(NSString*)displayName body:(NSString*)messagebody passobject:(XMPPJID*)jid
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        CustomUIAlertView *alertView = [[CustomUIAlertView alloc] initWithTitle:displayName
                                                            message:messagebody
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"deny",@"accept",nil];
        alertView.customobject = jid;
        [alertView show];
    }
    else
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Cancel";
        localNotification.alertBody = messagebody;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

#pragma mark UIAlertDelegate
- (void)alertView:(CustomUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    XMPPJID* fromjid = alertView.customobject;
    
    if (buttonIndex == 1)
    {
        XMPPvCardTemp* vcard = [self.xmppvCardTempModule vCardTempForJID:fromjid shouldFetch:NO];
        NSString* name = vcard.formattedName;
        [[self xmppRoster] acceptPresenceSubscriptionRequestFrom:fromjid andAddToRoster:YES nickname:name];
        [self createTempXMPPFBUser:fromjid];                                            
    }
    else
    {
        [[self xmppRoster] rejectPresenceSubscriptionRequestFrom:fromjid];
    }
}

-(void)createTempXMPPFBUser:(XMPPJID*)fromjid
{
    if (privateContext == nil)
    {
        privateContext = [NSManagedObjectContext MR_context];
    }
    [[DataManager singleInstance] createXMPPRoster:privateContext :fromjid];
}

#pragma mark UINotificationDelegate
// Called if registration is successful
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* devicetoken = [deviceToken xmpp_hexStringValue];
    [AppConfig updatenotificationid:devicetoken];
    DDLogVerbose(@"Device Registration %@", devicetoken);
}

// Called if we fail to register for a device token
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogVerbose(@"Error in registration. Error: %@", error);
}

// Called if notification is received while app is active
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    DDLogVerbose(@"Received Notification (Active): %@", userInfo);
}
/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    DDLogVerbose(@"Received Notification (Active): %@", userInfo);
}
 */
@end
