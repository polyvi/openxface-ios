
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
//  XApplication.h
//  xFace
//
//

#import <Foundation/Foundation.h>
#import "XApplication.h"

/**
    用于描述一个web应用，包括关联的应用配置信息以及app view
 */
@interface XWebApplication : NSObject <XApplication>
{
    NSMutableDictionary *data;    /**< 用于存放XApp的通讯数据*/
}

@end
