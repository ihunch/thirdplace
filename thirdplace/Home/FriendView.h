//
// Created by David Lawson on 3/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Friend;
@class FriendView;

@protocol FriendViewDelegate

- (void)didTouchFriendView:(FriendView *)friendView;

@end

@interface FriendView : UIView

@property (nonatomic, strong) Friend *friend;
@property (nonatomic, weak) id<FriendViewDelegate> delegate;

@property (nonatomic, strong) UILabel *label;

+ (id)addFriendView;

+ (id)friendViewWithFriend:(Friend *)aFriend;

@end