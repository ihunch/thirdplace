//
//  XMPPLoggingWrapper.m
//  thirdplace
//
//  Created by Yang Yu on 4/10/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

#import "XMPPLoggingWrapper.h"
#import "XMPPLogging.h"

#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@implementation XMPPLoggingWrapper

+ (void) XMPPLogTrace
{
    XMPPLogTrace();
}

+ (void) XMPPLogVerbose:(NSString*)message
{
    XMPPLogVerbose(message,THIS_FILE);
}
@end
