//
//  XMPPRosterCoreDataStorage+Additions.m
//  thirdplace
//
//  Created by Yang Yu on 2/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//
#import "XMPPRosterCoreDataStorage+Additions.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPP.h"
#import "XMPPLogging.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_INFO; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

#define AssertPrivateQueue() \
NSAssert(dispatch_get_specific(storageQueueTag), @"Private method: MUST run on storageQueue");


@implementation XMPPRosterCoreDataStorage (Additions)

- (NSArray*)rosterlistForJID:(XMPPJID*)jid
                  xmppStream:(XMPPStream*)stream
        managedObjectContext:(NSManagedObjectContext *)moc
{
    // This is a public method, so it may be invoked on any thread/queue.
    
    XMPPLogTrace();
    
    if (jid == nil) return nil;
    if (moc == nil) return nil;
    
    
    NSString *fullJIDStr = [jid full];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    NSPredicate *predicate;
    if (stream == nil)
        predicate = [NSPredicate predicateWithFormat:@"jidStr != %@", fullJIDStr];
    else
        predicate = [NSPredicate predicateWithFormat:@"jidStr != %@ AND streamBareJidStr == %@",
                     fullJIDStr, [[self myJIDForXMPPStream:stream] bare]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    return results;
}

#pragma mark - XMPPRoster Custom Method
- (void)addMyJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream  managedObjectContext:(NSManagedObjectContext *)moc
{
    XMPPUserCoreDataStorageObject* user = [self myUserForXMPPStream:stream managedObjectContext:moc];
    if (user == nil)
    {
        [self scheduleBlock:^{
            
            XMPPUserCoreDataStorageObject* me =[XMPPUserCoreDataStorageObject insertInManagedObjectContext:moc withJID:jid streamBareJidStr:[[self myJIDForXMPPStream:stream] bare]];
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *subfolder = [documentsDirectory stringByAppendingPathComponent:@"profile_pictures"];
            
            NSString *dest = [subfolder stringByAppendingPathComponent:[AppConfig loginUserPhotoPath]];
            
            UIImage* image = [UIImage imageWithContentsOfFile:dest];
            if (image != nil)
            {
                me.photo = image;
            }
        }];
    }
}


- (void)setFBPhoto:(UIImage *)image forUserWithJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
managedObjectContext:(NSManagedObjectContext *)moc
{
    XMPPLogTrace();
    [self scheduleBlock:^{
        XMPPUserCoreDataStorageObject *user = [self userForJID:jid xmppStream:stream managedObjectContext:moc];
        
        if (user)
        {
            user.photo = image;
        }
    }];
}
@end
