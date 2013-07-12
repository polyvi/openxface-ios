
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
//  XConsoleExt.h
//  xFace
//
//

#ifdef __XConsoleExt__

#import "XExtension.h"

@interface XConsoleExt : XExtension

/**
  在控制台打印log信息
  @param arguments 参数列表
        -0 callback js回调对象
        -1 要打印的log信息
  @param options 可选参数项，存储要打印log信息的logLevel
 */
- (void)log:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
