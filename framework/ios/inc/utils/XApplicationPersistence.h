
/*
 Copyright 2012-2013, Polyvi Inc. (http://polyvi.github.io/openxface)
 This program is distributed under the terms of the GNU General Public License.

 This file is part of xFace.

 xFace is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 xFace is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with xFace.  If not, see <http://www.gnu.org/licenses/>.
*/

//
//  XApplicationPersistence.h
//  xFace
//
//

#import <Foundation/Foundation.h>

@protocol XApplication;
@protocol XFileOperator;

@class XAppList;
@class APDocument;

@interface XApplicationPersistence : NSObject
{
    APDocument               *document;          /**< 用户已安装应用文件(userApps.xml)被解析后对应的document */
    id<XFileOperator>  userAppsFileOperator;     /**< 用于读写userApps.xml */
}

/**
	从userApps.xml中获取所有已安装应用的相关信息.
	@param appList  用于存储已安装应用相关信息的app list
	@returns 成功读取app信息并添加到appList中时返回YES,否则返回NO
 */
- (BOOL) readAppsFromConfig:(XAppList *)appList;

/**
	添加一个app到userApps.xml中.
	将app对应的id以及srcRoot记录到userApps.xml中.
	@param app 待记录的应用
 */
- (void) addAppToConfig:(id<XApplication>) app;

/**
	更新app的配置到userApps.xml中.
	将app对应的srcRoot更新到userApps.xml中.
	@param app 待更新的应用
 */
- (void) updateAppToConfig:(id<XApplication>) app;

/**
	从userApps.xml文件中移除一个app.
	将指定的appId从userApps.xml中删除.
	@param appId 待移除的app id
 */
- (void) removeAppFromConfig:(NSString *)appId;

/**
	将指定app标记为默认应用.
	将app id作为defaultAppId的属性值记录到userApps.xml中.
	@param appId 待标记为默认应用的app id
 */
- (void) markAsDefaultApp:(NSString *)appId;

@end
