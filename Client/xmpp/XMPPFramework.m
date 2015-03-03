//
//  XMPPFramework.m
//  thirdplace
//
//  Created by Stephen Karpinskyj on 22/02/15.
//  Copyright (c) 2015 Hunch Pty Ltd. All rights reserved.
//

#import "XMPPFramework.h"

NSString* const kXMPPHostName = @"54.206.75.197";
NSString* const kXMPPServerName = @"ip-172-31-1-174";

NSString *const kXMPPHasDetailsKey = @"kXMPPHasDetails";
NSString *const kXMPPJIDKey = @"kXMPPJID";
NSString *const kXMPPPasswordKey = @"kXMPPPassword";
NSString *const kXMPPNameKey = @"kXMPPName";
NSString *const kXMPPEmailKey = @"kXMPPEmail";

@implementation XMPPFramework

+ (bool) hasLoginDetails { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPHasDetailsKey]; } }
+ (NSString *) jid { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPJIDKey]; } }
+ (NSString *) password { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPPasswordKey]; } }
+ (NSString *) name { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPNameKey]; } }
+ (NSString *) email { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPEmailKey]; } }

+ (void) updateDetails:(NSString *)newJid withPassword:(NSString *)newPassword withName:(NSString *)newName withEmail:(NSString *)newEmail
{
    [self update:newJid withPassword:newPassword withName:newName withEmail:newEmail];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kXMPPHasDetailsKey];
}

+ (void) clearDetails
{
    [self update:nil withPassword:nil withName:nil withEmail:nil];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kXMPPHasDetailsKey];
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
}

@end