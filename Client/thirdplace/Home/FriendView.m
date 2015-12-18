//
// Created by David Lawson on 3/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "FriendView.h"
#import <NYXImagesKit/NYXImagesKit.h>
#import "XMPPFramework.h"

@interface FriendView ()

@property (nonatomic, strong) UIImage *friendImage;
@property (nonatomic, strong) UIImage *styledFriendImage;

@property (nonatomic) BOOL touching;

@end

@implementation FriendView

+ (id)addFriendView
{
    FriendView *friendView = [[self alloc] init];
    friendView.friendImage = [UIImage imageNamed:@"plus"];
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

        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 102, 100, 10)];
        self.label.font = [UIFont systemFontOfSize:11];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.minimumScaleFactor = 0.1;
        self.label.textColor = [UIColor lightGrayColor];

        self.label.hidden = YES;

        [self addSubview:self.label];
    }

    return self;
}

- (void)setFriend:(XMPPUserCoreDataStorageObject *)friend
{
    if (_friend)
        [friend removeObserver:self forKeyPath:@"photo"];

    _friend = friend;
    [friend addObserver:self forKeyPath:@"photo" options:NSKeyValueObservingOptionInitial context:nil];

    self.label.text = friend.nickname;
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
    if ([keyPath isEqualToString:@"photo"])
    {
        self.friendImage = self.friend.photo;
        [self setNeedsDisplay];
    }
}

- (void)dealloc
{
    [self.friend removeObserver:self forKeyPath:@"photo"];
}

- (UIColor *)outlineColor
{
    return [UIColor whiteColor];
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