//
// Created by David Lawson on 15/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "PlaceCell.h"
#import "FriendsCollectionViewController.h"


@implementation PlaceCell

- (void)setFriendsContainerView:(UIView *)friendsContainerView
{
    _friendsContainerView = friendsContainerView;

    self.friendsCVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FriendsCollectionViewController"];
    self.friendsCVC.view.frame = CGRectMake(0, 0, 320, 102);
    [friendsContainerView addSubview:self.friendsCVC.view];
}

@end