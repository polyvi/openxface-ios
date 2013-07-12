
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
//  XCommand.m
//  xFace
//
//

#import "XCommand.h"
#import "NSObject+JSONSerialization.h"

@implementation XCommand

@synthesize arguments;
@synthesize callbackId;
@synthesize className;
@synthesize methodName;

+ (XCommand*)commandFromJson:(NSArray*)jsonEntry
{
    return [[XCommand alloc] initFromJson:jsonEntry];
}

- (id)initFromJson:(NSArray*)jsonEntry
{
    NSString* cbId          = [jsonEntry objectAtIndex:0]; //FIXME:当callback id为NSNull null时，是否应转换为nil?
    NSString* extClassName  = [jsonEntry objectAtIndex:1];
    NSString* extMethodName = [jsonEntry objectAtIndex:2];
    NSMutableArray* args    = [jsonEntry objectAtIndex:3];

    return [self initWithArguments:args
                        callbackId:cbId
                         className:extClassName
                        methodName:extMethodName];
}

- (id)initWithArguments:(NSArray*)args
             callbackId:(NSString*)cbId
              className:(NSString*)extClassName
             methodName:(NSString*)extMethodName
{
    self = [super init];
    if (self != nil) {
        self->arguments  = args;
        self->callbackId = cbId;
        self->className  = extClassName;
        self->methodName = extMethodName;
    }
    return self;
}

@end
