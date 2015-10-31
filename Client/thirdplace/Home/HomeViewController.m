//
//  HomeViewController.m
//  thirdplace
//
//  Created by David Lawson on 1/07/2014.
//  Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "HomeViewController.h"
#import "FriendContainerView.h"
#import "CreateEventViewController.h"
#import "CreateEventTableViewController.h"
#import "PresentingAnimator.h"

@interface HomeViewController () <FriendContainerViewDelegate, UIViewControllerTransitioningDelegate,
    UITableViewDataSource, UITableViewDelegate>
@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//
//    self.friendContainerView.me = [RootEntity rootEntity].me;
//    for (Friend *friend in [RootEntity rootEntity].friends)
//        [self.friendContainerView addFriend:friend];
//
//    self.friendContainerView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   // [self.friendContainerView updateLayout];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddFriendViewController"])
    {
//        AddFriendViewController *dest = segue.destinationViewController;
//        dest.delegate = self;
    }
    else if ([segue.identifier  isEqualToString:@"CreateEventTableViewController"])
    {
        CreateEventTableViewController *dest = segue.destinationViewController;
       // dest.friends = @[[RootEntity rEntity].me, sender];
    }
}

- (void)didAddFriend:(XMPPUserCoreDataStorageObject *)friend
{
    //[self.friendContainerView addFriend:friend];
}

- (void)didTouchMe
{
    [self performSegueWithIdentifier:@"ProfileViewController" sender:nil];
}

- (void)didTouchAddFriend
{
    [self performSegueWithIdentifier:@"AddFriendViewController" sender:nil];
}

- (void)didTouchFriend:(XMPPUserCoreDataStorageObject *)friend rect:(CGRect)rect
{
    [self performSegueWithIdentifier:@"CreateEventTableViewController" sender:friend];

    return;
    UINavigationController *nvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NavigationController"];
    nvc.transitioningDelegate = self;
    nvc.modalPresentationStyle = UIModalPresentationCustom;

    CreateEventTableViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CreateEventTableViewController"];
    //vc.friends = @[[RootEntity rEntity].me, friend];
    // vc.view.frame = [self.view convertRect:rect fromView:self.friendContainerView];
    nvc.viewControllers = @[vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [PresentingAnimator new];
}


@end
