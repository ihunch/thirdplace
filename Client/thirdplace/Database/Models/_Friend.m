// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Friend.m instead.

#import "_Friend.h"

const struct FriendAttributes FriendAttributes = {
	.discoverNewPlaces = @"discoverNewPlaces",
	.email = @"email",
	.firstName = @"firstName",
	.imagePath = @"imagePath",
	.lastName = @"lastName",
	.mobileNumber = @"mobileNumber",
	.travelDistance = @"travelDistance",
	.x = @"x",
	.y = @"y",
};

const struct FriendRelationships FriendRelationships = {
	.meRootEntity = @"meRootEntity",
	.rootEntity = @"rootEntity",
};

const struct FriendFetchedProperties FriendFetchedProperties = {
};

@implementation FriendID
@end

@implementation _Friend

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Friend";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:moc_];
}

- (FriendID*)objectID {
	return (FriendID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"discoverNewPlacesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"discoverNewPlaces"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"travelDistanceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"travelDistance"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"xValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"x"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"yValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"y"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic discoverNewPlaces;



- (BOOL)discoverNewPlacesValue {
	NSNumber *result = [self discoverNewPlaces];
	return [result boolValue];
}

- (void)setDiscoverNewPlacesValue:(BOOL)value_ {
	[self setDiscoverNewPlaces:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDiscoverNewPlacesValue {
	NSNumber *result = [self primitiveDiscoverNewPlaces];
	return [result boolValue];
}

- (void)setPrimitiveDiscoverNewPlacesValue:(BOOL)value_ {
	[self setPrimitiveDiscoverNewPlaces:[NSNumber numberWithBool:value_]];
}





@dynamic email;






@dynamic firstName;






@dynamic imagePath;






@dynamic lastName;






@dynamic mobileNumber;






@dynamic travelDistance;



- (float)travelDistanceValue {
	NSNumber *result = [self travelDistance];
	return [result floatValue];
}

- (void)setTravelDistanceValue:(float)value_ {
	[self setTravelDistance:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveTravelDistanceValue {
	NSNumber *result = [self primitiveTravelDistance];
	return [result floatValue];
}

- (void)setPrimitiveTravelDistanceValue:(float)value_ {
	[self setPrimitiveTravelDistance:[NSNumber numberWithFloat:value_]];
}





@dynamic x;



- (float)xValue {
	NSNumber *result = [self x];
	return [result floatValue];
}

- (void)setXValue:(float)value_ {
	[self setX:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveXValue {
	NSNumber *result = [self primitiveX];
	return [result floatValue];
}

- (void)setPrimitiveXValue:(float)value_ {
	[self setPrimitiveX:[NSNumber numberWithFloat:value_]];
}





@dynamic y;



- (float)yValue {
	NSNumber *result = [self y];
	return [result floatValue];
}

- (void)setYValue:(float)value_ {
	[self setY:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveYValue {
	NSNumber *result = [self primitiveY];
	return [result floatValue];
}

- (void)setPrimitiveYValue:(float)value_ {
	[self setPrimitiveY:[NSNumber numberWithFloat:value_]];
}





@dynamic meRootEntity;

	

@dynamic rootEntity;

	






@end
