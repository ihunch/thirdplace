#import "XMPPModule.h"
#import "XMPPStream.h"
#import "XMPPLogging.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


@implementation XMPPModule

/**
 * Standard init method.
**/
- (id)init
{
	return [self initWithDispatchQueue:NULL];
}

/**
 * Designated initializer.
**/
- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
	if ((self = [super init]))
	{
		if (queue)
		{
			moduleQueue = queue;
			#if !OS_OBJECT_USE_OBJC
			dispatch_retain(moduleQueue);
			#endif
		}
		else
		{
			const char *moduleQueueName = [[self moduleName] UTF8String];
			moduleQueue = dispatch_queue_create(moduleQueueName, NULL);
		}
		
		moduleQueueTag = &moduleQueueTag;
		dispatch_queue_set_specific(moduleQueue, moduleQueueTag, moduleQueueTag, NULL);
		
		multicastDelegate = [[GCDMulticastDelegate alloc] init];
	}
	return self;
}

- (void)dealloc
{
	#if !OS_OBJECT_USE_OBJC
	dispatch_release(moduleQueue);
	#endif
}

/**
 * The activate method is the point at which the module gets plugged into the xmpp stream.
 *
 * It is recommended that subclasses override didActivate, instead of this method,
 * to perform any custom actions upon activation.
**/
- (BOOL)activate:(XMPPStream *)aXmppStream
{
	__block BOOL result = YES;
	
	dispatch_block_t block = ^{
		
		if (xmppStream != nil)
		{
			result = NO;
		}
		else
		{
			xmppStream = aXmppStream;
			
			[xmppStream addDelegate:self delegateQueue:moduleQueue];
			[xmppStream registerModule:self];
			
			[self didActivate];
		}
	};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_sync(moduleQueue, block);
	
	return result;
}

/**
 * It is recommended that subclasses override this method (instead of activate:)
 * to perform tasks after the module has been activated.
 * 
 * This method is only invoked if the module is successfully activated.
 * This method is always invoked on the moduleQueue.
**/
- (void)didActivate
{
	// Override me to do custom work after the module is activated
}

/**
 * The deactivate method unplugs a module from the xmpp stream.
 * When this method returns, no further delegate methods on this module will be dispatched.
 * However, there may be delegate methods that have already been dispatched.
 * If this is the case, the module will be properly retained until the delegate methods have completed.
 * If your custom module requires that delegate methods are not run after the deactivate method has been run,
 * then simply check the xmppStream variable in your delegate methods.
 *
 * It is recommended that subclasses override didDeactivate, instead of this method,
 * to perform any custom actions upon deactivation.
**/
- (void)deactivate
{
	dispatch_block_t block = ^{
		
		if (xmppStream)
		{
			[self willDeactivate];
			
			[xmppStream removeDelegate:self delegateQueue:moduleQueue];
			[xmppStream unregisterModule:self];
			
			xmppStream = nil;
		}
	};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_sync(moduleQueue, block);
}

/**
 * It is recommended that subclasses override this method (instead of deactivate:)
 * to perform tasks after the module has been deactivated.
 *
 * This method is only invoked if the module is transitioning from activated to deactivated.
 * This method is always invoked on the moduleQueue.
**/
- (void)willDeactivate
{
	// Override me to do custom work after the module is deactivated
}

- (dispatch_queue_t)moduleQueue
{
	return moduleQueue;
}

- (void *)moduleQueueTag
{
	return moduleQueueTag;
}

- (XMPPStream *)xmppStream
{
	if (dispatch_get_specific(moduleQueueTag))
	{
		return xmppStream;
	}
	else
	{
		__block XMPPStream *result;
		
		dispatch_sync(moduleQueue, ^{
			result = xmppStream;
		});
		
		return result;
	}
}

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
	// Asynchronous operation (if outside xmppQueue)
	
	dispatch_block_t block = ^{
		[multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
	};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_async(moduleQueue, block);
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue synchronously:(BOOL)synchronously
{
	dispatch_block_t block = ^{
		[multicastDelegate removeDelegate:delegate delegateQueue:delegateQueue];
	};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else if (synchronously)
		dispatch_sync(moduleQueue, block);
	else
		dispatch_async(moduleQueue, block);
	
}
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
	// Synchronous operation (common-case default)
	
	[self removeDelegate:delegate delegateQueue:delegateQueue synchronously:YES];
}

- (void)removeDelegate:(id)delegate
{
	// Synchronous operation (common-case default)
	
	[self removeDelegate:delegate delegateQueue:NULL synchronously:YES];
}

- (NSString *)moduleName
{
	// Override me (if needed) to provide a customized module name.
	// This name is used as the name of the dispatch_queue which could aid in debugging.
	
	return NSStringFromClass([self class]);
}

-(id)multicastDelegate
{
    return multicastDelegate;
}

@end
