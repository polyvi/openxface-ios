
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
//  XURLProtocol.h
//  xFaceLib
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "XApplication.h"

@interface XURLProtocol : NSURLProtocol
{
}

/**
    注册指定的app
    第一次调用时，将注册XURLProtocol，以使其对URL loading system可见
    @param app 待注册的app
 */
+ (void)registerApp:(id<XApplication>)app;

/**
    反注册指定的app
    @param app 待反注册的app
 */
+ (void)unregisterApp:(id<XApplication>)app;

@end
