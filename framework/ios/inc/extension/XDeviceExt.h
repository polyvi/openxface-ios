
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
//  XDeviceExt.h
//  xFace
//
//

#ifdef __XDeviceExt__

#import <Foundation/Foundation.h>
#import "XExtension.h"

@interface XDeviceExt : XExtension

/**
    获取Device 的信息
    @param arguments 参数列表
        - 0 XJsCallback* callback
    @param options 可选参数(本接口未使用)
 */
- (void)getDeviceInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
