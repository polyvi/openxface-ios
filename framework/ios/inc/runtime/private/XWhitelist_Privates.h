
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
//  XWhitelist_Privates.h
//  xFaceLib
//
//

#import "XWhitelist.h"

@interface XWhitelist ()

/**
    app.xml中的access属性值
 */
@property (nonatomic, readwrite, strong) NSArray *whitelist;

/**
    根据app.xml中的access属性值生成的网络访问权限白名单
 */
@property (nonatomic, readwrite, strong) NSArray *expandedWhitelist;

/**
    是否允许访问所有网络
 */
@property (nonatomic, readwrite, assign) BOOL allowAll;

/**
    根据app.xml中的access属性值来设置expandedWhitelist等值
 */
- (void)processWhitelist;

/**
    判断是否为IPv4地址
    @param externalHost 待判定的host
    @returns 是有效的IPv4地址时返回YES,否则返回NO
 */
- (BOOL)isIPv4Address:(NSString *)externalHost;

/**
    获取url中的host component
    @param url 用于获取host component的url
    @returns 如果url包含scheme,则返回host component,否则直接返回url
 */
- (NSString *)extractHostFromUrlString:(NSString *)url;

@end
