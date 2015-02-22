//
//  AppDelegate.h
//  thirdplace
//
//  Created by David Lawson on 1/07/2014.
//  Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMPPFramework.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, XMPPRosterDelegate>
{
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    bool isXmppConnected;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

@end
