
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
//  XConfiguration.h
//  xFace
//
//

#import <Foundation/Foundation.h>

@protocol XSystemConfigFileOperator;

@class XSystemConfigInfo;

/**
    负责准备工作空间以及提供系统配置信息
 */
@interface XConfiguration : NSObject

/**
    用于获取系统配置文件中的配置信息
 */
@property (strong, nonatomic, readonly) XSystemConfigInfo *systemConfigInfo;

/**
    系统工作空间.
    player的系统工作空间路径形如：<Applilcation_Home>/Documents/xface_player/
    非player的系统工作空间路径形如：<Applilcation_Home>/Documents/xface3/
 */
@property (strong, nonatomic, readonly) NSString *systemWorkspace;

/**
    应用安装目录
    路径形如：<Applilcation_Home>/Documents/xface3/apps/
 */
@property (strong, nonatomic, readonly) NSString *appInstallationDir;

/**
    应用图标所在目录
    路径形如：<Applilcation_Home>/Documents/xface3/app_icons/
 */
@property (strong, nonatomic, readonly) NSString *appIconsDir;

/**
    记录用户已安装应用信息的文件所在路径
    路径形如：<Applilcation_Home>/Documents/xface3/userApps.xml
 */
@property (strong, nonatomic, readonly) NSString *userAppsFilePath;

/**
    获取所有预安装应用对应的ID
 */
@property (strong, nonatomic, readonly) NSMutableArray *preinstallApps;

/**
    获取XConfiguration唯一实例
    @returns 获取到的XConfiguration实例
 */
+ (XConfiguration *) getInstance;

/**
    加载系统配置信息.
    通过解析系统配置文件，加载配置信息：如预置应用，系统默认扩展等.
    @returns 成功返回YES,失败返回NO
 */
- (BOOL) loadConfiguration;

/**
    准备系统工作空间
    @returns 成功返回YES,失败返回NO
 */
- (BOOL) prepareSystemWorkspace;

@end
