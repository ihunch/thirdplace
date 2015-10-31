//
// Created by David Lawson on 3/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPUserCoreDataStorageObject;
@class FriendView;

@protocol FriendViewDelegate

- (void)didTouchFriendView:(FriendView *)friendView;

@end

@interface FriendView : UIView

@property (nonatomic, strong) XMPPUserCoreDataStorageObject *friend;
@property (nonatomic, weak) id<FriendViewDelegate> delegate;

@property (nonatomic, strong) UILabel *label;

+ (id)addFriendView;

+ (id)friendViewWithFriend:(XMPPUserCoreDataStorageObject *)aFriend;

@end