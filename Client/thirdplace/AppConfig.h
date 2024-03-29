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
extern NSString* const serverdateFormat;

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
+ (UIColor*)themebgcolour;
+ (UIColor*)blueColour;
+ (NSString*)loginUserPhotoPath;
+ (void)updateLoginUserPhotoPath:(NSString*)path;
+ (NSString*)thirdplaceReportURL;
+ (NSString*)thirdplaceBlockURL;
@end