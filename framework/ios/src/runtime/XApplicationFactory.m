
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
//  XApplicationFactory.m
//  xFaceLib
//
//

#import "XApplicationFactory.h"
#import "XAppInfo.h"
#import "XWebApplication.h"
#import "XNativeApplication.h"
#import "XConstants.h"

@implementation XApplicationFactory

+ (id<XApplication>)create:(XAppInfo *)appInfo
{
    id<XApplication> app = nil;
    if ( [[appInfo type] isEqualToString:APP_TYPE_NAPP] )
    {
        app = [[XNativeApplication alloc] initWithAppInfo:appInfo];
    }
    else
    {
        // FIXME:考虑到之前app.xml并没有定义"xapp",故此处没有验证app类型
        app = [[XWebApplication alloc] initWithAppInfo:appInfo];
    }
    return app;
}

@end
