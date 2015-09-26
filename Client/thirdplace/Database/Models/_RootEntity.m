// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RootEntity.m instead.

#import "_RootEntity.h"

const struct RootEntityRelationships RootEntityRelationships = {
	.events = @"events",
	.friends = @"friends",
	.me = @"me",
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

@implementation _RootEntity (EventsCoreDataGeneratedAccessors)
- (void)addEvents:(NSOrderedSet*)value_ {
	[self.eventsSet unionOrderedSet:value_];
}
- (void)removeEvents:(NSOrderedSet*)value_ {
	[self.eventsSet minusOrderedSet:value_];
}
- (void)addEventsObject:(Event*)value_ {
	[self.eventsSet addObject:value_];
}
- (void)removeEventsObject:(Event*)value_ {
	[self.eventsSet removeObject:value_];
}
- (void)insertObject:(Event*)value inEventsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"events"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self events]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"events"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"events"];
}
- (void)removeObjectFromEventsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"events"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self events]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"events"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"events"];
}
- (void)insertEvents:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"events"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self events]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"events"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"events"];
}
- (void)removeEventsAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"events"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self events]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"events"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"events"];
}
- (void)replaceObjectInEventsAtIndex:(NSUInteger)idx withObject:(Event*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"events"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self events]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"events"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"events"];
}
- (void)replaceEventsAtIndexes:(NSIndexSet *)indexes withEvents:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"events"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self events]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"events"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"events"];
}
@end

