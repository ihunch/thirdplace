//
//  MapAnnotation.m
//  iPhoneXMPP
//
//  Created by Yang Yu on 12/14/10.
//  Copyright 2010 WN China. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

@synthesize currentTitle;
@synthesize subTitle;
@synthesize locationAttribute;
@synthesize coordinate;
@synthesize annotationID;

#pragma mark -
- (NSString *)title {
    return currentTitle;
}

-(NSString*)subtitle
{
    return subTitle;
}

@end
