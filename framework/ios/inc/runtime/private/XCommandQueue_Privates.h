
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
//  XCommandQueue_Privates.h
//  xFaceLib
//
//

#import "XCommandQueue.h"

@interface XCommandQueue ()

/**
    执行queue中的command
 */
- (void)executePending;

/**
    执行指定的command
    @param command 待执行的command
    @returns 成功返回YES，失败返回NO
 */
- (BOOL)execute:(XCommand*)command;

/**
    判断与指定webview相关的request是否已经被flush过
    @param requestId   与待判定request对应的id
    @returns 已经被flush过，返回YES，否则返回NO
 */
- (BOOL)isRequestFlushed:(NSInteger)requestId;

@end
