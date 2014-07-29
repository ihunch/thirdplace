//
//  FriendsCollectionViewController.h
//  SnapCoffee
//
//  Created by David Lawson on 30/06/2014.
//  Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendsCVCDelegate

- (void)didSelectFriends:(NSArray *)friends;
- (void)pressedAddFriend;

@end

@interface FriendsCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<FriendsCVCDelegate> delegate;
@property (nonatomic, strong) NSArray *friends;

@end
