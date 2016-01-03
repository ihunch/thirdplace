// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to XMPPRosterFB.h instead.

@import CoreData;

extern const struct XMPPRosterFBAttributes {
	__unsafe_unretained NSString *axisx;
	__unsafe_unretained NSString *axisy;
	__unsafe_unretained NSString *fbid;
	__unsafe_unretained NSString *isloginowner;
	__unsafe_unretained NSString *jid;
} XMPPRosterFBAttributes;

@interface XMPPRosterFBID : NSManagedObjectID {}
@end

@interface _XMPPRosterFB : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) XMPPRosterFBID* objectID;

@property (nonatomic, strong) NSNumber* axisx;

@property (atomic) float axisxValue;
- (float)axisxValue;
- (void)setAxisxValue:(float)value_;

//- (BOOL)validateAxisx:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* axisy;

@property (atomic) float axisyValue;
- (float)axisyValue;
- (void)setAxisyValue:(float)value_;

//- (BOOL)validateAxisy:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* fbid;

//- (BOOL)validateFbid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isloginowner;

@property (atomic) BOOL isloginownerValue;
- (BOOL)isloginownerValue;
- (void)setIsloginownerValue:(BOOL)value_;

//- (BOOL)validateIsloginowner:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* jid;

//- (BOOL)validateJid:(id*)value_ error:(NSError**)error_;

@end

@interface _XMPPRosterFB (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveAxisx;
- (void)setPrimitiveAxisx:(NSNumber*)value;

- (float)primitiveAxisxValue;
- (void)setPrimitiveAxisxValue:(float)value_;

- (NSNumber*)primitiveAxisy;
- (void)setPrimitiveAxisy:(NSNumber*)value;

- (float)primitiveAxisyValue;
- (void)setPrimitiveAxisyValue:(float)value_;

- (NSString*)primitiveFbid;
- (void)setPrimitiveFbid:(NSString*)value;

- (NSNumber*)primitiveIsloginowner;
- (void)setPrimitiveIsloginowner:(NSNumber*)value;

- (BOOL)primitiveIsloginownerValue;
- (void)setPrimitiveIsloginownerValue:(BOOL)value_;

- (NSString*)primitiveJid;
- (void)setPrimitiveJid:(NSString*)value;

@end
