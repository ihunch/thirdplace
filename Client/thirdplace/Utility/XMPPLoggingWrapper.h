//
//  XMPPLoggingWrapper.h
//  thirdplace
//
//  Created by Yang Yu on 4/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMPPLoggingWrapper : NSObject
+ (void) XMPPLogTrace;
+ (void) XMPPLogVerbose:(NSString*)message;
@end
