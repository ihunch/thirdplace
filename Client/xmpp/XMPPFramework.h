//
//  This file is designed to be customized by YOU.
//  
//  As you pick and choose which parts of the framework you need for your application, add them to this header file.
//  
//  Various modules available within the framework optionally interact with each other.
//  E.g. The XMPPPing module will utilize the XMPPCapabilities module (if available) to advertise support XEP-0199.
// 
//  However, the modules can only interact if they're both added to your xcode project.
//  E.g. If XMPPCapabilities isn't a part of your xcode project, then XMPPPing shouldn't attempt to reference it.
// 
//  So how do the individual modules know if other modules are available?
//  Via this header file.
// 
//  If you #import "XMPPCapabilities.h" in this file, then _XMPP_CAPABILITIES_H will be defined for other modules.
//  And they can automatically take advantage of it.
//

#import "XMPP.h"

extern NSString* const kXMPPHostName;
extern NSString* const kXMPPServerName;

extern NSString* const kXMPPHasDetailsKey;
extern NSString* const kXMPPJIDKey;
extern NSString* const kXMPPPasswordKey;

// List the modules you're using here.

#import "XMPPReconnect.h"

#import "XMPPRoster.h"
#import "XMPPRosterCoreDataStorage.h"

#import "XMPPvCardTempModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "XMPPCapabilities.h"
#import "XMPPCapabilitiesCoreDataStorage.h"

@interface XMPPFramework : NSObject

+ (bool) hasLoginDetails;
+ (NSString *) jid;
+ (NSString *) password;

+ (void) updateLoginDetails:(NSString *)newJid withPassword:(NSString *)newPassword;
+ (void) clearLoginDetails;

@end