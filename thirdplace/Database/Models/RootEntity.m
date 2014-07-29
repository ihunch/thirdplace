#import "RootEntity.h"


@interface RootEntity ()

// Private interface goes here.

@end


@implementation RootEntity

+ (RootEntity *)rootEntity
{
    return [self MR_findFirst];
}

@end
