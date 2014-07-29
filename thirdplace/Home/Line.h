//
// Created by David Lawson on 3/07/2014.
// Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Line : NSObject

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGPoint destination;

+ (instancetype)lineWithOrigin:(CGPoint)origin destination:(CGPoint)destination;

@end