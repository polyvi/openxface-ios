
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
//  XAppRunningMode.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>
#import "XAppInfo.h"
#import "XSecurityPolicy.h"
#import "XResourceIterator.h"

@class XApplication;

enum {
    LOCAL,      /** < 本地模式的指令码 */
    ONLINE,     /** < 在线模式的指令码 */
    INVALID     /** < 无效的模式 */
};

typedef u_int32_t RUNNING_MODE;  //模式的数据类型

/** 本地应用运行模式 */
#define LOCAL_RUNNING_MODE         @"local"
/** 在线应用运行模式 */
#define ONLINE_RUNNING_MODE        @"online"

@interface XAppRunningMode : NSObject

/**
   根据配置串创建具体的运行模式对象
   @param mode  mode对应的名称
   @param app   与mode相关联的app
   @return mode名称对应的mode对象
 */
+ (id)modeWithName:(NSString*)name app:(id<XApplication>)app;

/**
   根据app初始化mode对象的抽象方法
   @param app 与mode关联的app
   @return mode对象
 */
- (id)initWithApp:(id<XApplication>)app;

/*
    构造app的url
    @param app 应用实例
    @returns 返回app对应的NSURL
 */
- (NSURL*)getURL:(id<XApplication>)app;

/*
    构造app图标的url
    @param appInfo app的信息
    @returns 返回app图标的url
 */
- (NSString*)getIconURL:(XAppInfo*)appInfo;

/**
    模式类型
 */
@property RUNNING_MODE mode;

/**
    资源迭代器
 */
- (id<XResourceIterator>)getResourceIterator:(id<XApplication>)app;

/**
   加载应用
   @param app[in] 当前应用
   @param policy[in] 安全策略
 */
- (void)loadApp:(id<XApplication>)app policy:(id<XSecurityPolicy>)policy;

@end
