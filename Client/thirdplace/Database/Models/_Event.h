// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Event.h instead.

@import CoreData;

extern const struct EventAttributes {
	__unsafe_unretained NSString *date;
} EventAttributes;

extern const struct EventRelationships {
	__unsafe_unretained NSString *friends;
	__unsafe_unretained NSString *rootEntity;
} EventRelationships;

@class Friend;
@class RootEntity;

@interface EventID : NSManagedObjectID {}
@end

@interface _Event : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) EventID* objectID;

@property (nonatomic, strong) NSDate* date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *friends;

- (NSMutableSet*)friendsSet;

@property (nonatomic, strong) RootEntity *rootEntity;

//- (BOOL)validateRootEntity:(id*)value_ error:(NSError**)error_;

@end

@interface _Event (FriendsCoreDataGeneratedAccessors)
- (void)addFriends:(NSSet*)value_;
- (void)removeFriends:(NSSet*)value_;
- (void)addFriendsObject:(Friend*)value_;
- (void)removeFriendsObject:(Friend*)value_;

@end

@interface _Event (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;

- (NSMutableSet*)primitiveFriends;
- (void)setPrimitiveFriends:(NSMutableSet*)value;

- (RootEntity*)primitiveRootEntity;
- (void)setPrimitiveRootEntity:(RootEntity*)value;

@end
