
/*
 This file was modified from or inspired by Apache Cordova.

 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.
*/

//
//  XExtension.m
//  xFace
//
//

#import "XExtension.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XJsCallback.h"
#import "XConstants.h"
#import "XLog.h"

@implementation XExtension
@synthesize viewController;

- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super init];
    if (self)
    {
        self->jsEvaluator = msgHandler;
    }

    return self;
}

- (BOOL) verifyArguments:(NSMutableArray*)arguments withExpectedCount:(NSUInteger)expectedCount andCallback:(XJsCallback *)callback callerFileName:(const char *)callerFileName callerFunctionName:(const char *)callerFunctionName
{
	NSUInteger argc = [arguments count];
	BOOL ok = (argc >= expectedCount); // allow for optional arguments

	if (!ok)
    {
		NSString* errorString = [NSString stringWithFormat:@"Incorrect no. of arguments for extension: was %d, expected %d", argc, expectedCount];
		if (callback)
        {
            XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject:errorString];
            [callback setExtensionResult:result];
            [self->jsEvaluator eval:callback];
		}
        else
        {
			NSString* fileName = [[[NSString alloc] initWithBytes:callerFileName length:strlen(callerFileName)
                                                         encoding:NSUTF8StringEncoding] lastPathComponent];
			XLogE(@"%@::%s - Error: %@", fileName, callerFunctionName, errorString);
		}
	}

	return ok;
}

- (void) sendAsyncResult:(XJsCallback *)callback
{
    [self->jsEvaluator performSelectorOnMainThread:@selector(eval:)
                                 withObject:callback waitUntilDone:NO];
}

- (BOOL) shouldExecuteInBackground:(NSString *)fullMethodName
{
    return NO;
}

- (void) onAppClosed:(NSString *)appId
{

}

- (void) onAppWillUninstall:(NSString *)appId
{

}

- (void) onPageStarted:(NSString*)appId
{

}

- (id<XApplication>) getApplication:(NSDictionary *)options
{
    return [options objectForKey:APPLICATION_KEY];
}

- (XJsCallback *) getJsCallback:(NSDictionary *)options
{
    return [options objectForKey:JS_CALLBACK_KEY];
}

@end
