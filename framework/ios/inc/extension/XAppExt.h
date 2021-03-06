
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
//  XAppExt.h
//  xFaceLib
//
//

#ifdef __XAppExt__

#import "XExtension.h"

@interface XAppExt : XExtension

/**
    调用系统自带的浏览器打开url
    @param arguments
        - 0 NSString* url          待打开的url
    @param options
      - 0 XJsCallback  *callback   js回调对象
      - 1 id<XApplication> app     关联的app
 */
- (void) openUrl:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    启动本地应用
    @param arguments
        - 0 NSString* appURL       app的URL
        - 1 NSString* parameter    app启动参数
   @param options
      - 0 XJsCallback  *callback   js回调对象
      - 1 id<XApplication> app     关联的app
 */
- (void) startNativeApp:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    获取渠道信息
    @param arguments 无参数
    @param options
      - 0 XJsCallback  *callback   js回调对象
      - 1 id<XApplication> app     关联的app
 */
- (void) getChannel:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif

