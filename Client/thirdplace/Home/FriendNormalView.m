//
//  FriendNormalView.m
//  thirdplace
//
//  Created by Yang Yu on 1/01/2016.
//  Copyright © 2016 Hunch Pty Ltd. All rights reserved.
//

#import "FriendNormalView.h"
#import "CustomBadge.h"
@implementation FriendNormalView

+ (id)friendViewWithFriend:(XMPPUserCoreDataStorageObject *)friend
{
    FriendNormalView *friendView = [[self alloc] init];
    friendView.friend = friend;
    return friendView;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self.badge removeFromSuperview];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    // Drawing code
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
    }
}

- (UIColor *)outlineColor
{
    return [UIColor whiteColor];//[UIColor colorWithRed:187.0/255.0 green:189.0/255.0 blue:192.0/255.0 alpha:1.0];
}

-(void)setViewDelegate:(id<FriendViewDelegate>)delegate
{
    self.delegate = delegate;
}


@end
