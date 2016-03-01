//
// Created by David Lawson on 3/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "FriendView.h"
#import <NYXImagesKit/NYXImagesKit.h>
#import "XMPPFramework.h"
#import "AppConfig.h"
#import "CustomBadge.h"
#import "thirdplace-Swift.h"

@interface FriendView ()

@property (nonatomic) BOOL touching;

@end

@implementation FriendView

+ (id)addFriendView
{
    FriendView *friendView = [[self alloc] init];
    friendView.friendImage = [[UIImage imageNamed:@"plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    friendView.tintColor = [UIColor blueColor];
    return friendView;
}

+ (id)friendViewWithFriend:(XMPPUserCoreDataStorageObject *)friend
{
    FriendView *friendView = [[self alloc] init];
    friendView.friend = friend;
    return friendView;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.bounds = CGRectMake(0, 0, 100, 100);

        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 102, 100, 15)];
        self.label.font = [UIFont systemFontOfSize:11];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.minimumScaleFactor = 0.1;
        self.label.textColor = [UIColor lightGrayColor];
        self.label.hidden = YES;

        [self addSubview:self.label];
        
        self.badge = [CustomBadge customBadgeWithString:@"" withStyle:[BadgeStyle defaultStyle]];
        CGRect frame = self.badge.frame;
        self.badge.frame = CGRectMake(45, 0, frame.size.width, frame.size.height);
        self.badge.hidden = YES;
        [self addSubview:self.badge];
        
    }

    return self;
}

- (void)setFriend:(XMPPUserCoreDataStorageObject *)afriend
{
    if (afriend != _friend)
    {
        [_friend removeObserver:self forKeyPath:@"photo"];
        [_friend removeObserver:self forKeyPath:@"subscription"];
        _friend = afriend;
        [_friend addObserver:self forKeyPath:@"photo" options:NSKeyValueObservingOptionInitial context:nil];
        [_friend addObserver:self forKeyPath:@"subscription" options:NSKeyValueObservingOptionInitial context:nil];
    }
    self.label.text = afriend.nickname;
}

- (void)setXMPPRosterFB:(XMPPRosterFB*)fbroster
{
    if (fbroster != _fbprofile)
    {
        [_fbprofile removeObserver:self forKeyPath:@"unreadMessages"];
        _fbprofile = fbroster;
        [_fbprofile addObserver:self forKeyPath:@"unreadMessages" options:NSKeyValueObservingOptionInitial context:nil];
    }
}

- (UIImage *)styledFriendImage
{
    if (!_styledFriendImage)
    {
        int padding = 3;
        CGRect imageRect = CGRectMake(padding, padding, self.bounds.size.width - padding * 2, self.bounds.size.height - padding * 2);
        CGSize doubleSize = CGSizeMake(imageRect.size.width*2, imageRect.size.height*2);
        _styledFriendImage = [[self.friendImage scaleToCoverSize:doubleSize] cropToSize:doubleSize usingMode:NYXCropModeCenter];
    }
    return _styledFriendImage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self]))
        self.touching = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    self.touching = CGRectContainsPoint(self.bounds, [touch locationInView:self]);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touching)
    {
        [self.delegate didTouchFriendView:self];
    }

    self.touching = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touching = NO;
}

- (void)setTouching:(BOOL)touching
{
    _touching = touching;
    [self setNeedsDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"photo"] || [keyPath isEqualToString:@"subscription"])
    {
        if ([self.friend.jidStr isEqualToString:[AppConfig jid]])
        {
             self.friendImage = self.friend.photo;
        }
        else
        {
            if (![self.friend.subscription isEqualToString:@"none"])
            {
                self.friendImage = self.friend.photo;
            }
            else
            {
                self.friendImage = [self.friend.photo grayscale];
            }
        }
        [self setNeedsDisplay];
    }
    else if ([keyPath isEqualToString:@"unreadMessages"] )
    {
        NSNumber* unreadmessage = self.fbprofile.unreadMessages;
        if (unreadmessage.intValue > 0)
        {
            //NSString* message = [unreadmessage stringValue];
            self.badge.badgeText = @" ";//message;
            self.badge.hidden = NO;
        }
        else
        {
            self.badge.badgeText = nil;
            self.badge.hidden = YES;
        }
    }
}

- (void)dealloc
{
    [_friend removeObserver:self forKeyPath:@"photo"];
    [_friend removeObserver:self forKeyPath:@"subscription"];
    [_fbprofile removeObserver:self forKeyPath:@"unreadMessages"];
}

- (UIColor *)outlineColor
{
    return [UIColor whiteColor];//[UIColor colorWithRed:187.0/255.0 green:189.0/255.0 blue:192.0/255.0 alpha:1.0];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [self outlineColor].CGColor);
    CGContextFillEllipseInRect(ctx, rect);

    if (self.friendImage)
    {
        int padding = 3;
        CGRect imageRect = CGRectMake(padding, padding, rect.size.width - padding * 2, rect.size.height - padding * 2);

        CGContextAddEllipseInRect(ctx, imageRect);
        CGContextClip(ctx);

        [self.styledFriendImage drawInRect:imageRect];

        if (self.touching)
        {
            [[UIColor colorWithWhite:1 alpha:0.2] setFill];
            UIRectFillUsingBlendMode(rect, kCGBlendModeSourceAtop);
        }
    }
}

@end