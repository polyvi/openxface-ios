
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
//  XConfiguration_Privates.h
//  xFaceLib
//
//

#import "XConfiguration.h"

@interface XConfiguration()

/**
    获取系统工作空间
    @returns 系统工作空间绝对路径
 */
- (NSString *)getSystemWorkspace;

/**
    获取应用安装目录
    @returns 应用安装目录的绝对路径
 */
- (NSString *)getAppInstallationDir;

/**
    获取应用图标目录
    @returns 应用图标目录的绝对路径
 */
- (NSString *)getAppIconsDir;

/**
    获取系统配置文件所在路径
    @returns 系统配置文件的绝对路径
 */
- (NSString *)getSystemConfigFilePath;

/**
    用于获取系统配置文件中的配置信息
 */
@property (strong, nonatomic, readwrite) XSystemConfigInfo *systemConfigInfo;

@end
