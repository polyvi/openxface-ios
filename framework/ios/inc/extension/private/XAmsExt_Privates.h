
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
//  XAmsExt_Privates.h
//  xFaceLib
//
//

#import "XAmsExt.h"
#import "XAmsConstants.h"

@class XAppInfo;

@interface XAmsExt()

/**
 构造用于应用安装、更新、卸载的相关参数
 @param type 操作类型：INSTALL UPDATE UNINSTALL
 @param pkgPath 应用安装包路径，操作类型为UNINSTALL时，此参数无效
 @param appId 用于标识待卸载应用的id，操作类型为INSTALL UPDATE时，此参数无效
 @param callback js回调对象
 @returns 成功时返回构造的参数，失败时返回nil
 */
- (NSArray *) buildArgsWithOperationType:(OPERATION_TYPE)type packagePath:(NSString *)pkgPath appId:(NSString *)appId callback:(XJsCallback *)callback;

@end
