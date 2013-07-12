
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
//  XAppInfo.h
//  xFace
//
//

#import <UIKit/UIKit.h>

/**
	应用配置信息封装类
 */
@interface XAppInfo : NSObject

/**
	app对应的id
 */
@property (strong, nonatomic) NSString *appId;

/**
	app对应的名称
 */
@property (strong, nonatomic) NSString *name;

/**
	app对应的版本号
 */
@property (strong, nonatomic) NSString *version;

/**
	app启动页面相对路径
 */
@property (strong, nonatomic) NSString *entry;

/**
	app图标相对路径
 */
@property (strong, nonatomic) NSString *icon;

/**
     app图标背景颜色
 */
@property (strong, nonatomic) NSString *iconBgColor;

/**
	app对应的类型.
	app类型有如下两种：<br />
	1) xapp,代表web app         <br />
	2) napp,代表native app
 */
@property (strong, nonatomic) NSString *type;

/**
	app数据是否被加密
 */
@property (nonatomic) BOOL isEncrypted;

/**
	app显示的宽度
 */
@property (nonatomic) NSInteger width;

/**
	app显示的高度
 */
@property (nonatomic) NSInteger height;

/**
    应用显示的方式
 */
@property (strong, nonatomic) NSString *displayMode;

/**
   应用运行的方式
 */
@property (strong, nonatomic) NSString *runningMode;

/**
    定义此应用基于1.x or 3.x引擎运行，后面研究混合模式需要用到
 */
@property (strong, nonatomic) NSString *engineType;

/**
    渠道ID
 */
@property (strong, nonatomic) NSString *channelId;

/**
    渠道名称
 */
@property (strong, nonatomic) NSString *channelName;

/**
    native app安装包的iTunes store下载地址
 */
@property (strong, nonatomic) NSString *prefRemotePkg;

/**
    native app的iTunes identifier
 */
@property (strong, nonatomic) NSString *appleId;

/**
    用于指定app的网络访问权限
 */
@property (strong, nonatomic) NSMutableArray *whitelistHosts;

/**
    对预安装应用,srcRoot为"preinstalled",对非预安装应用,srcRoot为"workspace"
 */
@property (strong, nonatomic) NSString *srcRoot;

/**
    app源码所在绝对路径
    预装应用源码所在根目录路径形如：  <Application_Home>/xFace.app/www/preinstalledApps/appSrcDirName/
    非预装应用源码所在根目录路径形如：<Application_Home>/Documents/xface3/apps/appId/
 */
@property (strong, nonatomic, readonly) NSString *srcPath;

@end
