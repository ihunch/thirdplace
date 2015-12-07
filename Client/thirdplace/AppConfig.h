//
//  AppConfig.h
//  thirdplace
//
//  Created by Yang Yu on 2/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//


extern NSString* const kXMPPHostName;
extern NSString* const kXMPPServerName;

extern NSString* const kXMPPHasDetailsKey;
extern NSString* const kXMPPJIDKey;
extern NSString* const kXMPPPasswordKey;

extern NSString* const kXMPPMessageId_InviteHangout;

@interface AppConfig : NSObject

+ (bool) hasLoginDetails;
+ (NSString *) jid;
+ (NSString *) password;
+ (NSString *) name;
+ (NSString *) email;
+ (void) updateDetails:(NSString *)newJid withPassword:(NSString *)newPassword withName:(NSString *)newName withEmail:(NSString *)newEmail;
+ (void) clearDetails;
+ (NSString*) thirdplaceModule;
+ (NSString*) notificationid;
+ (void) updatenotificationid:(NSString*)notificationid;

@end