
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
//  XWhitelist.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>

//TODO:需要对性能进行测试，如果导致页面切换速度变慢，可以考虑增加开关，以允许用户不关心whitelist时将其关掉

extern NSString *const XDefaultWhitelistRejectionString;

/**
    用于控制app的网络访问权限
 */
@interface XWhitelist : NSObject

/**
    初始化方法
    @param array 存储access属性值的数组
    @returns 成功返回XWhitelist对象，否则返回nil
 */
- (id)initWithArray:(NSArray *)array;

/**
    判断是否允许当前app加载指定url
    @param url 待判定的url
    @returns 允许加载返回YES,否则返回NO
 */
- (BOOL)isUrlAllowed:(NSURL *)url;

/**
    判断是否为允许加载的scheme类型
    @param scheme 待判定的url scheme
    @returns 为允许加载的scheme类型时返回YES,否则返回NO
 */
+ (BOOL)isSchemeAllowed:(NSString *)scheme;

/**
    根据url生成错误信息
    @param url 用于生成错误信息的url
    @returns 根据url生成的错误信息
 */
+ (NSString *)errorStringForUrl:(NSURL *)url;

@end
