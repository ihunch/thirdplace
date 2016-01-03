//
//  CALayer+Additions.m
//  thirdplace
//
//  Created by Yang Yu on 2/01/2016.
//  Copyright © 2016 Hunch Pty Ltd. All rights reserved.
//

#import "CALayer+Additions.h"
@implementation CALayer (Additions)

-(void)setBorderColorIB:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderColorIB
{
    return [UIColor colorWithCGColor:self.borderColor];
}

-(void)setShadowColorIB:(UIColor*)color
{
    self.shadowColor = color.CGColor;
}

-(UIColor*)shadowColorIB
{
    return [UIColor colorWithCGColor:self.shadowColor];
}

@end
