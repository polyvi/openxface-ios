
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
//  XEchoExt.h
//  xFaceLib
//
//

#ifdef __XEchoExt__

#import "XExtension.h"

@interface XEchoExt : XExtension
{
}

/**
    将输入参数传回给回调函数
    @param arguments 待传回给回调函数的message
    @param options
      - 0 XJsCallback  *callback  js回调对象
      - 1 id<XApplication> app     关联的app
 */
- (void)echo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    将输入参数传回给回调函数(异步)
    @param arguments 待传回给回调函数的message
    @param options
      - 0 XJsCallback  *callback  js回调对象
      - 1 id<XApplication> app     关联的app
 */
- (void)echoAsync:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
