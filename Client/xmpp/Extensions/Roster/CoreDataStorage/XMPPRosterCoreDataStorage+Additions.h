//
//  XMPPRosterCoreDataStorage+Additions.h
//  thirdplace
//
//  Created by Yang Yu on 2/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

#import "XMPPRosterCoreDataStorage.h"

@interface XMPPRosterCoreDataStorage (Additions)

- (NSArray*)rosterlistForJID:(XMPPJID*)jid
                  xmppStream:(XMPPStream*)stream
        managedObjectContext:(NSManagedObjectContext *)moc;

- (void)addMyJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream  managedObjectContext:(NSManagedObjectContext *)moc;

- (void)setFBPhoto:(UIImage *)image forUserWithJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
managedObjectContext:(NSManagedObjectContext *)moc;

-(void)updateUneadMessage:(NSInteger)unmessages user:(XMPPUserCoreDataStorageObject *)user xmppStream:(XMPPStream *)stream managedObjectContext:(NSManagedObjectContext *)moc;
@end
