//
//  FriendsCollectionViewController.m
//  SnapCoffee
//
//  Created by David Lawson on 30/06/2014.
//  Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "FriendsCollectionViewController.h"
#import "FriendCollectionViewCell.h"
#import "FriendView.h"

@interface FriendsCollectionViewController ()

@end

@implementation FriendsCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.delegate = self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.friends.count; // + 1
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[FriendCollectionViewCell reuseIdentifier] forIndexPath:indexPath];

    if (indexPath.row == self.friends.count)
    {
        FriendView *friendView = [FriendView addFriendView];
        friendView.frame = cell.bounds;
        [cell addSubview:friendView];
    }
    else
    {
        FriendView *friendView = [FriendView friendViewWithFriend:self.friends[(NSUInteger)indexPath.row]];
        friendView.frame = cell.bounds;
        [cell addSubview:friendView];
    }

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(82, 82);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}


@end
