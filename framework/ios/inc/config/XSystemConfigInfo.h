
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
//  XSystemConfigInfo.h
//  xFaceLib
//
//

#import <UIKit/UIKit.h>

/**
    系统配置文件中的配置信息
 */
@interface XSystemConfigInfo : NSObject <NSXMLParserDelegate>

/**
    获取所有预安装应用ID
    对应配置文件内容：<app_package id="appId">appSrcDirName</app_package>
 */
@property (nonatomic, readonly, strong) NSMutableArray *preinstallApps;

/**
    获取preference配置信息
    对应配置文件内容：<preference name="AutoHideSplashScreen" value="true" />
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *settings;

/**
    获取扩展信息
    对应配置文件内容：<extension name="Device" value="XDeviceExt" />
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *extensionsDict;

@end
