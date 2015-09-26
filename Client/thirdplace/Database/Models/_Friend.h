// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Friend.h instead.

@import CoreData;

extern const struct FriendAttributes {
	__unsafe_unretained NSString *discoverNewPlaces;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *imagePath;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *mobileNumber;
	__unsafe_unretained NSString *travelDistance;
	__unsafe_unretained NSString *x;
	__unsafe_unretained NSString *y;
} FriendAttributes;

extern const struct FriendRelationships {
	__unsafe_unretained NSString *meRootEntity;
	__unsafe_unretained NSString *rootEntity;
} FriendRelationships;

@class RootEntity;
@class RootEntity;

@interface FriendID : NSManagedObjectID {}
@end

@interface _Friend : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) FriendID* objectID;

@property (nonatomic, strong) NSNumber* discoverNewPlaces;

@property (atomic) BOOL discoverNewPlacesValue;
- (BOOL)discoverNewPlacesValue;
- (void)setDiscoverNewPlacesValue:(BOOL)value_;

//- (BOOL)validateDiscoverNewPlaces:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* email;

//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* firstName;

//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* imagePath;

//- (BOOL)validateImagePath:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* lastName;

//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* mobileNumber;

//- (BOOL)validateMobileNumber:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* travelDistance;

@property (atomic) float travelDistanceValue;
- (float)travelDistanceValue;
- (void)setTravelDistanceValue:(float)value_;

//- (BOOL)validateTravelDistance:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* x;

@property (atomic) float xValue;
- (float)xValue;
- (void)setXValue:(float)value_;

//- (BOOL)validateX:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* y;

@property (atomic) float yValue;
- (float)yValue;
- (void)setYValue:(float)value_;

//- (BOOL)validateY:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) RootEntity *meRootEntity;

//- (BOOL)validateMeRootEntity:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) RootEntity *rootEntity;

//- (BOOL)validateRootEntity:(id*)value_ error:(NSError**)error_;

@end

@interface _Friend (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveDiscoverNewPlaces;
- (void)setPrimitiveDiscoverNewPlaces:(NSNumber*)value;

- (BOOL)primitiveDiscoverNewPlacesValue;
- (void)setPrimitiveDiscoverNewPlacesValue:(BOOL)value_;

- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;

- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;

- (NSString*)primitiveImagePath;
- (void)setPrimitiveImagePath:(NSString*)value;

- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;

- (NSString*)primitiveMobileNumber;
- (void)setPrimitiveMobileNumber:(NSString*)value;

- (NSNumber*)primitiveTravelDistance;
- (void)setPrimitiveTravelDistance:(NSNumber*)value;

- (float)primitiveTravelDistanceValue;
- (void)setPrimitiveTravelDistanceValue:(float)value_;

- (NSNumber*)primitiveX;
- (void)setPrimitiveX:(NSNumber*)value;

- (float)primitiveXValue;
- (void)setPrimitiveXValue:(float)value_;

- (NSNumber*)primitiveY;
- (void)setPrimitiveY:(NSNumber*)value;

- (float)primitiveYValue;
- (void)setPrimitiveYValue:(float)value_;

- (RootEntity*)primitiveMeRootEntity;
- (void)setPrimitiveMeRootEntity:(RootEntity*)value;

- (RootEntity*)primitiveRootEntity;
- (void)setPrimitiveRootEntity:(RootEntity*)value;

@end
