//
//  RandomGeneration.m
//  thirdplace
//
//  Created by Stephen Karpinskyj on 22/02/15.
//  Copyright (c) 2015 Hunch Pty Ltd. All rights reserved.
//

#import "RandomGeneration.h"

@implementation RandomGeneration

NSString *const letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 !#$%&'()*+-./;<=>?@[\\]^`{|}~";

// Source: http://stackoverflow.com/questions/2633801/generate-a-random-alphanumeric-string-in-cocoa
+ (NSString *)generateString:(int)length {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    
    for (int i = 0; i < length; i++) {
        uint sourceLength = (uint)[letters length];
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform(sourceLength)]];
    }
    
    return randomString;
}

@end