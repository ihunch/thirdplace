//
// Created by David Lawson on 15/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FriendsCollectionViewController;


@interface PlaceCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *friendsContainerView;
@property (nonatomic, strong) FriendsCollectionViewController *friendsCVC;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end