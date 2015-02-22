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

@implementation XMPPFramework

+ (bool) hasLoginDetails { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPHasDetailsKey]; } }
+ (NSString *) jid { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPJIDKey]; } }
+ (NSString *) password { @synchronized(self) { return [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPPasswordKey]; } }

+ (void) updateLoginDetails:(NSString *)newJid withPassword:(NSString *)newPassword
{
    [self update:newJid withPassword:newPassword];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kXMPPHasDetailsKey];
}

+ (void) clearLoginDetails
{
    [self update:nil withPassword:nil];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kXMPPHasDetailsKey];
}

+(void) update:(NSString *)newJid withPassword:(NSString *)newPassword
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
}

@end