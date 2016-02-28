//
// Created by David Lawson on 3/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPUserCoreDataStorageObject;
@class FriendView;
@class CustomBadge;
@class XMPPRosterFB;

@protocol FriendViewDelegate

- (void)didTouchFriendView:(FriendView *)friendView;

@end

@interface FriendView : UIView

@property (nonatomic, strong) XMPPUserCoreDataStorageObject *friend;
@property (nonatomic, weak) id<FriendViewDelegate> delegate;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImage *friendImage;
@property (nonatomic, strong) UIImage *styledFriendImage;
@property (nonatomic, strong) CustomBadge* badge;
@property (nonatomic, strong) XMPPRosterFB* fbprofile;
+ (id)addFriendView;

+ (id)friendViewWithFriend:(XMPPUserCoreDataStorageObject *)aFriend;
- (void)setXMPPRosterFB:(XMPPRosterFB*)fbroster;
@end