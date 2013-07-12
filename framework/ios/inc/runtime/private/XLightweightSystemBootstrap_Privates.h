
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
//  XLightweightSystemBootstrap_Privates.h
//  xFaceLib
//
//

#import "XLightweightSystemBootstrap.h"

#define APPLICATION_PREPACKED_PACKAGE_NAME       @"xFaceInstalledPackage.zip"
#define BUNDLE_VERSION_KEY                       @"CFBundleVersion"
#define USER_DEFAULTS_SAVED_VERSION_KEY          @"savedXFaceVersion"

@interface XLightweightSystemBootstrap ()

/**
    标识ipa包是否更新，即引擎是否更新
 */
@property (nonatomic) BOOL isIpaUpdated;

/**
    根据版本号判断ipa是否更新
    @returns ipa更新返回YES,否则返回NO
 */
- (BOOL) ipaUpdated;

/**
    保存ipa版本号
 */
- (void) saveIpaVersion;

/**
    采用免解压过程的方式异步安装所有预置应用
    安装（更新）所有预置应用后，启动默认应用.
    @param appManagement 用于安装预置应用的应用管理器
 */
- (void) preinstallInBackground:(XAppManagement *)appManagement;

/**
    安装所有预置应用
    @param appManagement 应用管理器
 */
- (void) preinstall:(XAppManagement *)appManagement;

/**
    所有预置应用安装完成后，由后台线程调用
    @param appManagement 应用管理器
 */
- (void) onPostPreinstall:(XAppManagement *)appManagement;

/**
    启动default app
    @param appManagement 应用管理器
 */
- (void) startDefaultApp:(XAppManagement *)appManagement;

@end
