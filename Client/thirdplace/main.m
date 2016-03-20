//
//  main.m
//  thirdplace
//
//  Created by David Lawson on 1/07/2014.
//  Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char * argv[])
{
    int returnValue;
    @autoreleasepool {

        BOOL inTests = (NSClassFromString(@"SenTestCase") != nil
                        || NSClassFromString(@"XCTest") != nil);
        
        if (inTests) {
            //use a special empty delegate when we are inside the tests
            returnValue = UIApplicationMain(argc, argv, nil, @"AppDelegate");
        }
        else {
            //use the normal delegate
            returnValue = UIApplicationMain(argc, argv, nil, @"AppDelegate");
        }
    }
    return returnValue;
}
