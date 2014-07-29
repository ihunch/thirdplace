//
// Created by David Lawson on 3/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "Line.h"


@implementation Line

+ (instancetype)lineWithOrigin:(CGPoint)origin destination:(CGPoint)destination
{
    Line *line = [[self alloc] init];
    line.origin = origin; line.destination = destination;
    return line;
}

@end