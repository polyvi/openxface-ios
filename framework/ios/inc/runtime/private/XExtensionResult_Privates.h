
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
//  XExtensionResult_Privates.h
//  xFaceLib
//
//

#import "XExtensionResult.h"

@interface XExtensionResult ()

/**
    初始化方法
    @param status js执行结果状态码
    @param theMessage js执行结果返回值
    @returns 成功返回XExtensionResult对象，否则返回nil
 */
- (XExtensionResult*)initWithStatus:(STATUS)status message:(id)theMessage;

/**
    获取执行结果的json字符串
    @returns 获取到的json字符串
 */
- (NSString *)getJSONString;

@end
