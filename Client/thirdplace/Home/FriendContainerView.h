//
// Created by David Lawson on 1/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Friend;

@protocol FriendContainerViewDelegate

- (void)didTouchMe;
- (void)didTouchAddFriend;

- (void)didTouchFriend:(Friend *)friend rect:(CGRect)rect;

@end

@interface FriendContainerView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) Friend *me;
@property (nonatomic, weak) id<FriendContainerViewDelegate> delegate;

- (void)addFriend:(Friend *)friend;
- (void)removeFriend:(Friend *)friend;

- (void)updateLayout;
@end