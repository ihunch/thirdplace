//
//  FriendNormalView.h
//  thirdplace
//
//  Created by Yang Yu on 1/01/2016.
//  Copyright © 2016 Hunch Pty Ltd. All rights reserved.
//

#import "FriendView.h"

@class XMPPUserCoreDataStorageObject;

@interface FriendNormalView : FriendView
+ (id)friendViewWithFriend:(XMPPUserCoreDataStorageObject *)friend;
@end
