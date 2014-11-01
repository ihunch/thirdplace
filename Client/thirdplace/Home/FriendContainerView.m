//
// Created by David Lawson on 1/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "FriendContainerView.h"
#import "FriendView.h"
#import "LinesView.h"
#import "Line.h"
#import "Friend.h"

@interface FriendContainerView () <FriendViewDelegate>

@property (nonatomic, strong) NSMutableArray *friendViews;
@property (nonatomic, strong) FriendView *meView;
@property (nonatomic, strong) FriendView *dragFriendView;
@property (nonatomic, strong) FriendView *addFriendView;

@property (nonatomic, strong) LinesView *linesView;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation FriendContainerView

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.friendViews = [NSMutableArray array];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"patternBackground"]];

    self.linesView = [[LinesView alloc] initWithFrame:self.bounds];
    [self addSubview:self.linesView];

    self.addFriendView = [FriendView addFriendView];
    self.addFriendView.frame = CGRectMake(0, 0, 50, 50);
    self.addFriendView.delegate = self;
    [self addSubview:self.addFriendView];
    [self updateLines];

    [self setupGestureRecognizers];
}

- (void)setupGestureRecognizers
{
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressGestureRecognizer.delegate = self;
    self.longPressGestureRecognizer.cancelsTouchesInView = YES;
    [self addGestureRecognizer:self.longPressGestureRecognizer];

    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGestureRecognizer.delegate = self;
    self.panGestureRecognizer.cancelsTouchesInView = YES;
    [self addGestureRecognizer:self.panGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchLocation = [gestureRecognizer locationInView:self];
    for (FriendView *friendView in self.friendViews)
    {
        if (CGRectContainsPoint(friendView.frame, touchLocation))
        {
            return YES;
        }
    }

    return NO;
}


- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint touchLocation = [gestureRecognizer locationInView:self];

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        for (FriendView *friendView in self.friendViews)
        {
            if (CGRectContainsPoint(friendView.frame, touchLocation))
            {
                self.dragFriendView = friendView;
                [self bringSubviewToFront:friendView];

                __weak typeof(self) weakSelf = self;
                [UIView animateWithDuration:0.3 animations:^{
                    friendView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                    [weakSelf updateLines];
                }];

                break;
            }
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        FriendView *friendView = self.dragFriendView;
        self.dragFriendView = nil;

        friendView.friend.xValue = friendView.center.x;
        friendView.friend.yValue = friendView.center.y;
        [friendView.friend.managedObjectContext MR_saveToPersistentStoreWithCompletion:nil];

        [UIView animateWithDuration:0.3 animations:^{
            friendView.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gestureRecognizer translationInView:self];
        self.dragFriendView.center = CGPointMake(self.dragFriendView.center.x + translation.x, self.dragFriendView.center.y + translation.y);
        [self updateLines];
    }

    [gestureRecognizer setTranslation:CGPointZero inView:self];
}

- (void)addFriend:(Friend *)friend
{
    FriendView *friendView = [FriendView friendViewWithFriend:friend];
    friendView.delegate = self;
    [self.friendViews addObject:friendView];

    friendView.frame = CGRectMake(0, 0, 60, 60);
    friendView.center = CGPointMake(friend.xValue, friend.yValue);

    friendView.label.hidden = NO;

    [self addSubview:friendView];

    [self updateLines];
}

- (void)removeFriend:(Friend *)friend
{
    for (unsigned i = 0; i < self.friendViews.count; i++)
    {
        FriendView *friendView = self.friendViews[i];
        if (friendView.friend == friend)
        {
            [friendView removeFromSuperview];
            [self.friendViews removeObjectAtIndex:i];
            break;
        }
    }
}

- (void)setMe:(Friend *)friend
{
    if (!self.meView)
    {
        self.meView = [FriendView friendViewWithFriend:friend];
        self.meView.delegate = self;
        self.meView.frame = CGRectMake(0, 0, 75, 75);
        [self addSubview:self.meView];
    }
    else
    {
        [self.meView setFriend:friend];
    }
}

- (void)updateLayout
{
    self.meView.center = CGPointMake(self.center.x, self.center.y - 50);
    self.addFriendView.center = CGPointMake(self.center.x, self.center.y + 50);
    [self updateLines];
}

- (void)updateLines
{
    NSMutableArray *lines = [NSMutableArray array];
    for (FriendView *friendView in self.friendViews)
        [lines addObject:[Line lineWithOrigin:self.meView.center destination:friendView.center]];
    [lines addObject:[Line lineWithOrigin:self.meView.center destination:self.addFriendView.center]];
    self.linesView.lines = lines;
}

- (void)didTouchFriendView:(FriendView *)friendView
{
    if (friendView == self.meView)
    {
        [self.delegate didTouchMe];
    }
    else if (friendView == self.addFriendView)
    {
        [self.delegate didTouchAddFriend];
    }
    else
    {
        [self.delegate didTouchFriend:friendView.friend rect:friendView.frame];
    }
}

@end