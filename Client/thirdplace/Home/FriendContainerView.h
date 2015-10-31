//
// Created by David Lawson on 1/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMPPUserCoreDataStorageObject;

@protocol FriendContainerViewDelegate

- (void)didTouchMe;
- (void)didTouchAddFriend;
- (void)didTouchFriend:(XMPPUserCoreDataStorageObject *)friend rect:(CGRect)rect;

@end

@interface FriendContainerView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) XMPPUserCoreDataStorageObject *me;
@property (nonatomic, weak) id<FriendContainerViewDelegate> delegate;

- (void)addFriend:(XMPPUserCoreDataStorageObject *)friend;
- (void)removeFriend:(XMPPUserCoreDataStorageObject *)friend;
- (void)updateLayout;
- (void)reloadFriendListData;
@end