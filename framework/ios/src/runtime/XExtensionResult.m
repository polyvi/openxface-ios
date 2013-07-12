
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
//  XExtensionResult.m
//  xFace
//
//

#import "XExtensionResult.h"
#import "XExtensionResult_Privates.h"
#import "NSObject+JSONSerialization.h"

@implementation XExtensionResult

@synthesize status;
@synthesize message;
@synthesize keepCallback;

static NSArray *StatusMsgs;

+(void) initialize
{
	StatusMsgs = [[NSArray alloc] initWithObjects: @"No result",
                                            @"Progress changing",
                                            @"OK",
                                            @"Class not found",
                                            @"Illegal access",
                                            @"Instantiation error",
                                            @"Malformed url",
                                            @"IO error",
                                            @"Invalid action",
                                            @"JSON error",
                                            @"Error",
                                            nil];
}

+(XExtensionResult *) resultWithStatus:(STATUS)status
{
	return [[self alloc] initWithStatus:status message:[StatusMsgs objectAtIndex:status]];
}

+(XExtensionResult *) resultWithStatus:(STATUS)status messageAsObject:(id)theMessage
{
	return [[self alloc] initWithStatus:status message:theMessage];
}

+(XExtensionResult *) resultWithStatus:(STATUS)status messageAsInt:(int)theMessage
{
	return [[self alloc] initWithStatus:status message:[NSNumber numberWithInt:theMessage]];
}

+(XExtensionResult *) resultWithStatus:(STATUS)status messageAsDouble:(double)theMessage
{
	return [[self alloc] initWithStatus:status message:[NSNumber numberWithDouble:theMessage]];
}

+ (XExtensionResult *) resultWithStatus:(STATUS)status messageToErrorObject: (int) errorCode
{
    NSDictionary* errDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:errorCode] forKey:@"code"];
	return [[self alloc] initWithStatus:status message:errDict];
}

-(NSString *) toCallbackString:(NSString *)callbackId
{
    NSString *callbackString = nil;
    switch ([status intValue]) {
        case STATUS_OK:
            callbackString = [NSString stringWithFormat:@"xFace.callbackSuccess('%@',%@);", callbackId, [self getJSONString]];
            break;
        case STATUS_ERROR:
        case STATUS_CLASS_NOT_FOUND_EXCEPTION:
        case STATUS_ILLEGAL_ACCESS_EXCEPTION:
        case STATUS_INSTANTIATION_EXCEPTION:
        case STATUS_INVALID_ACTION:
        case STATUS_IO_EXCEPTION:
        case STATUS_JSON_EXCEPTION:
        case STATUS_MALFORMED_URL_EXCEPTION:
            callbackString = [NSString stringWithFormat:@"xFace.callbackError('%@',%@);", callbackId, [self getJSONString]];
            break;
        case STATUS_PROGRESS_CHANGING:
            callbackString = [NSString stringWithFormat:@"xFace.callbackStatusChanged('%@',%@);", callbackId, [self getJSONString]];
        case STATUS_NO_RESULT:
        default:
            break;
    }

    XLogI(@"ExtensionResult toCallbackString: %@", callbackString);
    return callbackString;
}

#pragma mark Privates

- (XExtensionResult*)initWithStatus:(STATUS)statusCode message:(id)theMessage
{
    self = [super init];
    if(self)
    {
        self->status = [NSNumber numberWithInt:statusCode];
        self->message = theMessage;
        self->keepCallback = NO;
    }
    return self;
}

- (NSString *)getJSONString{
    NSString *resultString = [[NSDictionary dictionaryWithObjectsAndKeys:
                               self.status, @"status",
                               self.message ? self.message : [NSNull null], @"message",
                               [NSNumber numberWithBool:self.keepCallback], @"keepCallback",
                               nil] JSONString];
    return resultString;
}

@end
