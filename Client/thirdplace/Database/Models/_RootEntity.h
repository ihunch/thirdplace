// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RootEntity.h instead.

#import <CoreData/CoreData.h>


extern const struct RootEntityAttributes {
} RootEntityAttributes;

extern const struct RootEntityRelationships {
	__unsafe_unretained NSString *events;
	__unsafe_unretained NSString *friends;
	__unsafe_unretained NSString *me;
} RootEntityRelationships;

extern const struct RootEntityFetchedProperties {
} RootEntityFetchedProperties;

@class Event;
@class Friend;
@class Friend;


@interface RootEntityID : NSManagedObjectID {}
@end

@interface _RootEntity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RootEntityID*)objectID;





@property (nonatomic, strong) NSOrderedSet *events;

- (NSMutableOrderedSet*)eventsSet;




@property (nonatomic, strong) NSSet *friends;

- (NSMutableSet*)friendsSet;




@property (nonatomic, strong) Friend *me;

//- (BOOL)validateMe:(id*)value_ error:(NSError**)error_;





@end

@interface _RootEntity (CoreDataGeneratedAccessors)

- (void)addEvents:(NSOrderedSet*)value_;
- (void)removeEvents:(NSOrderedSet*)value_;
- (void)addEventsObject:(Event*)value_;
- (void)removeEventsObject:(Event*)value_;

- (void)addFriends:(NSSet*)value_;
- (void)removeFriends:(NSSet*)value_;
- (void)addFriendsObject:(Friend*)value_;
- (void)removeFriendsObject:(Friend*)value_;

@end

@interface _RootEntity (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableOrderedSet*)primitiveEvents;
- (void)setPrimitiveEvents:(NSMutableOrderedSet*)value;



- (NSMutableSet*)primitiveFriends;
- (void)setPrimitiveFriends:(NSMutableSet*)value;



- (Friend*)primitiveMe;
- (void)setPrimitiveMe:(Friend*)value;


@end
