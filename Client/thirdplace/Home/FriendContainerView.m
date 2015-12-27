//
// Created by David Lawson on 1/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "FriendContainerView.h"
#import "FriendView.h"
#import "LinesView.h"
#import "Line.h"
#import "thirdplace-Swift.h"
#import "XMPPFramework.h"
#import "DDLog.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


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
-(AppDelegate*)appDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

-(XMPPRosterCoreDataStorage*)rosterCoreDataStorage
{
    return [[self appDelegate] xmppRosterStorage];
}

-(XMPPStream*)xmppStream
{
    return [[self appDelegate] xmppStream];
}

-(NSManagedObjectContext*)rosterDBContext
{
    return [[self appDelegate] managedObjectContext_roster];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.friendViews = [NSMutableArray array];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"patternBackground"]];
    self.linesView = [[LinesView alloc] init];
    [self addSubview:self.linesView];

    self.addFriendView = [FriendView addFriendView];
    self.addFriendView.frame = CGRectMake(0, 0, 50, 50);
    self.addFriendView.delegate = self;
    [self addSubview:self.addFriendView];
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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecogniser
{
    CGPoint touchLocation = [gestureRecogniser locationInView:self];
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
    FriendContainerTableViewCell* cell =  (FriendContainerTableViewCell*)self.superview.superview;
    UITableView* tableview = (UITableView*)cell.superview.superview;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        tableview.scrollEnabled = NO;
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
        tableview.scrollEnabled = YES;
        FriendView *friendView = self.dragFriendView;
        self.dragFriendView = nil;
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            XMPPRosterFB* rfb = [[DataManager singleInstance] getXMPPUserFBInfo:friendView.friend.jid dbcontext:localContext];
            rfb.axisxValue = friendView.center.x;
            rfb.axisyValue = friendView.center.y;
        }];
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

- (void)addFriend:(XMPPUserCoreDataStorageObject *)friend
{
    DataManager* dbm = [DataManager singleInstance];
    FriendView *friendView = [FriendView friendViewWithFriend:friend];
    friendView.delegate = self;
    [self.friendViews addObject:friendView];
    XMPPRosterFB* rfb = [dbm getXMPPUserFBInfo:friend.jid dbcontext:nil];
    if (friend.photo == nil)
    {
        [dbm fetchFBPhoto:rfb.fbid :friend];
    }
    friendView.frame = CGRectMake(0, 0, 60, 60);
    friendView.center = CGPointMake(rfb.axisx.floatValue, rfb.axisy.floatValue);
    friendView.label.hidden = NO;
    [self addSubview:friendView];
    [self updateLines];
    
}

-(void)removeAllFriendViews
{
    for(FriendView* view in self.friendViews)
    {
        [view removeFromSuperview];
    }
    self.friendViews = [NSMutableArray array];
}

- (void)removeFriend:(XMPPUserCoreDataStorageObject *)friend
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

- (void)setMe:(XMPPUserCoreDataStorageObject *)me
{
    if (!self.meView)
    {
        self.meView = [FriendView friendViewWithFriend:me];
        self.meView.delegate = self;
        self.meView.frame = CGRectMake(0, 0, 75, 75);
        [self addSubview:self.meView];
    }
    else
    {
        [self.meView setFriend:me];
    }
}

- (void)updateLayout
{
    [self layoutIfNeeded];
    self.linesView.frame = self.bounds;
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

-(void)reloadFriendListData
{
    DDLogCVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self removeAllFriendViews];
    XMPPUserCoreDataStorageObject* me = [[self rosterCoreDataStorage] myUserForXMPPStream:[self xmppStream] managedObjectContext:[self rosterDBContext]];
    if (me != nil)
    {
        if (me.photo == nil)
        {
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *subfolder = [documentsDirectory stringByAppendingPathComponent:@"profile_pictures"];
            
            NSString *dest = [subfolder stringByAppendingPathComponent:[AppConfig loginUserPhotoPath]];
            
            UIImage* image = [UIImage imageWithContentsOfFile:dest];
            if (image != nil)
            {
                [self.rosterCoreDataStorage setFBPhoto:image forUserWithJID:me.jid xmppStream:[self xmppStream] managedObjectContext:self.rosterDBContext];
            }
        }
        self.me = me;
    }
    
    NSArray* friends = [[self rosterCoreDataStorage] rosterlistForJID:[XMPPJID jidWithString:[AppConfig jid]] xmppStream:[self xmppStream] managedObjectContext:[self rosterDBContext]];
    DDLogCVerbose(@"FRIEND: %lu", (unsigned long)friends.count);
    for (XMPPUserCoreDataStorageObject* u in friends)
    {
        if ([u.ask isEqualToString:@"subscribe"])
        {
            [self addFriend:u];
        }
        else
        {
            if(![u.subscription isEqualToString:@"none"])
            {
                [self addFriend:u];
            }
        }
    }
}
@end