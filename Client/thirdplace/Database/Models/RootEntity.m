#import "RootEntity.h"

@interface RootEntity ()

// Private interface goes here.

@end

@implementation RootEntity

// Custom logic goes here.
+ (RootEntity *)rEntity
{
    return [self MR_findFirst];
}
@end
