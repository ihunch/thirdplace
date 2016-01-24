//
//  AppConfig.m
//  thirdplace
//
//  Created by Yang Yu on 2/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//
#import "AppConfig.h"

NSString* const kXMPPHostName = @"52.62.24.227";
NSString* const kXMPPServerName = @"ip-172-31-1-174";
//NSString* const kXMPPHostName = @"192.168.0.14";
//NSString* const kXMPPServerName = @"macintosh.local";
NSString *const kXMPPHasDetailsKey = @"kXMPPHasDetails";
NSString *const kXMPPJIDKey = @"kXMPPJID";
NSString *const kXMPPPasswordKey = @"kXMPPPassword";
NSString *const kXMPPNameKey = @"kXMPPName";
NSString *const kXMPPEmailKey = @"kXMPPEmail";
NSString *const kNotificationKey = @"NotificationKey";
NSString *const kXMPPMessageId_InviteHangout = @"xmpp_msg_invite";
NSString *const kLoginUserPhotoPath = @"LoginUserPhotoPath";

@implementation AppConfig

+ (bool) hasLoginDetails { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPHasDetailsKey]; } }
+ (NSString *) jid { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPJIDKey]; } }
+ (NSString *) password { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPPasswordKey]; } }
+ (NSString *) name { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPNameKey]; } }
+ (NSString *) email { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPEmailKey]; } }

+ (NSString*) thirdplaceModule
{
    NSString* str = [NSString stringWithFormat:@"thirdplacehangout.%@",kXMPPServerName];
    return str;
}

+ (void) updateDetails:(NSString *)newJid withPassword:(NSString *)newPassword withName:(NSString *)newName withEmail:(NSString *)newEmail
{
    [self update:newJid withPassword:newPassword withName:newName withEmail:newEmail];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kXMPPHasDetailsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) clearDetails
{
    [self update:nil withPassword:nil withName:nil withEmail:nil];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kXMPPHasDetailsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void) update:(NSString *)newJid withPassword:(NSString *)newPassword withName:(NSString *)newName withEmail:(NSString *)newEmail
{
    if (newJid != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:newJid forKey:kXMPPJIDKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPJIDKey];
    }
    
    if (newPassword != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:newPassword forKey:kXMPPPasswordKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPPasswordKey];
    }
    
    if (newName != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:newName forKey:kXMPPNameKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPNameKey];
    }
    
    if (newEmail != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:newEmail forKey:kXMPPEmailKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPEmailKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*) notificationid
{
  @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kNotificationKey]; }
}

+ (void) updatenotificationid:(NSString*)notificationid
{
    [[NSUserDefaults standardUserDefaults] setObject:notificationid forKey:kNotificationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (UIColor*)themebgcolour
{
    //return [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:245.0/255.0 alpha:1.0];
    return [UIColor blackColor];
}

+ (UIColor*)blueColour
{
     return [UIColor colorWithRed:0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+ (NSString*)loginUserPhotoPath
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserPhotoPath];
}

+ (void)updateLoginUserPhotoPath:(NSString*)path
{
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:kLoginUserPhotoPath];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end