// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RootEntity.m instead.

#import "_RootEntity.h"

const struct RootEntityAttributes RootEntityAttributes = {
};

const struct RootEntityRelationships RootEntityRelationships = {
	.events = @"events",
	.friends = @"friends",
	.me = @"me",
};

const struct RootEntityFetchedProperties RootEntityFetchedProperties = {
};

@implementation RootEntityID
@end

@implementation _RootEntity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RootEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RootEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RootEntity" inManagedObjectContext:moc_];
}

- (RootEntityID*)objectID {
	return (RootEntityID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic events;

	
- (NSMutableOrderedSet*)eventsSet {
	[self willAccessValueForKey:@"events"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"events"];
  
	[self didAccessValueForKey:@"events"];
	return result;
}
	

@dynamic friends;

	
- (NSMutableSet*)friendsSet {
	[self willAccessValueForKey:@"friends"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"friends"];
  
	[self didAccessValueForKey:@"friends"];
	return result;
}
	

@dynamic me;

	






@end
