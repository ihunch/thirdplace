//
// Created by David Lawson on 3/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "LinesView.h"
#import "Line.h"


@implementation LinesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }

    return self;
}


- (void)setLines:(NSArray *)lines
{
    _lines = lines;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSetLineCap(ctx, kCGLineCapSquare);
    CGContextSetGrayStrokeColor(ctx, 1, 1);
    CGContextSetLineWidth(ctx, 3.0);

    for (Line *line in self.lines)
    {
        CGContextMoveToPoint(ctx, line.origin.x, line.origin.y);
        CGContextAddLineToPoint(ctx, line.destination.x, line.destination.y);
        CGContextStrokePath(ctx);
    }
}


@end