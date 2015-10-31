//
// Created by David Lawson on 4/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Friend;

@protocol AddFriendViewControllerDelegate
//- (void)didAddFriend:(Friend *)friend;
@end

@interface AddFriendViewController : UIViewController

@property (nonatomic, weak) id<AddFriendViewControllerDelegate> delegate;

@end