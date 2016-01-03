// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to XMPPRosterFB.m instead.

#import "_XMPPRosterFB.h"

const struct XMPPRosterFBAttributes XMPPRosterFBAttributes = {
	.axisx = @"axisx",
	.axisy = @"axisy",
	.fbid = @"fbid",
	.isloginowner = @"isloginowner",
	.jid = @"jid",
};

@implementation XMPPRosterFBID
@end

@implementation _XMPPRosterFB

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"XMPPRosterFB" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"XMPPRosterFB";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"XMPPRosterFB" inManagedObjectContext:moc_];
}

- (XMPPRosterFBID*)objectID {
	return (XMPPRosterFBID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"axisxValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"axisx"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"axisyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"axisy"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isloginownerValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isloginowner"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic axisx;

- (float)axisxValue {
	NSNumber *result = [self axisx];
	return [result floatValue];
}

- (void)setAxisxValue:(float)value_ {
	[self setAxisx:@(value_)];
}

- (float)primitiveAxisxValue {
	NSNumber *result = [self primitiveAxisx];
	return [result floatValue];
}

- (void)setPrimitiveAxisxValue:(float)value_ {
	[self setPrimitiveAxisx:@(value_)];
}

@dynamic axisy;

- (float)axisyValue {
	NSNumber *result = [self axisy];
	return [result floatValue];
}

- (void)setAxisyValue:(float)value_ {
	[self setAxisy:@(value_)];
}

- (float)primitiveAxisyValue {
	NSNumber *result = [self primitiveAxisy];
	return [result floatValue];
}

- (void)setPrimitiveAxisyValue:(float)value_ {
	[self setPrimitiveAxisy:@(value_)];
}

@dynamic fbid;

@dynamic isloginowner;

- (BOOL)isloginownerValue {
	NSNumber *result = [self isloginowner];
	return [result boolValue];
}

- (void)setIsloginownerValue:(BOOL)value_ {
	[self setIsloginowner:@(value_)];
}

- (BOOL)primitiveIsloginownerValue {
	NSNumber *result = [self primitiveIsloginowner];
	return [result boolValue];
}

- (void)setPrimitiveIsloginownerValue:(BOOL)value_ {
	[self setPrimitiveIsloginowner:@(value_)];
}

@dynamic jid;

@end

