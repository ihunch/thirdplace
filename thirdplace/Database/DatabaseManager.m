//
//  DatabaseManager.m
//  thirdplace
//
//  Created by David Lawson on 3/07/2014.
//  Copyright (c) 2014 Hunch Pty Ltd. All rights reserved.
//

#import "DatabaseManager.h"
#import "RootEntity.h"
#import "Friend.h"

@implementation DatabaseManager

+ (void)setup
{
    [MagicalRecord setupCoreDataStack];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"populatedDatabase"])
    {
        [self populateDatabase];
        [defaults setBool:YES forKey:@"populatedDatabase"];
        [defaults synchronize];
    }
}

+ (void)populateDatabase
{
    RootEntity *rootEntity = [RootEntity MR_createEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+ (void)cleanUp
{
    [MagicalRecord cleanUp];
}

@end
