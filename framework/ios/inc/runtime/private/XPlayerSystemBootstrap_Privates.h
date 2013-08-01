
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
//  XPlayerSystemBootstrap_Privates.h
//  xFace
//
//

#import "XPlayerSystemBootstrap.h"

@protocol XApplication;

@interface XPlayerSystemBootstrap()

/**
	部署资源.
	将预置资源包（配置文件，预置应用）解压到工作空间下.
	@returns 成功返回YES,失败返回NO
 */
- (BOOL) deployResources;

/**
    为合并user data做准备工作：如迁移app下的workspace、data目录到上级目录
    @param needMerging 输出参数，用于标识是否需要对user data进行合并.当user data目录存在时返回YES,否则返回NO
    @returns 准备工作执行成功时返回YES，否则返回NO
 */
- (BOOL) prepareForMergingUserData:(BOOL *)needMerging;

/**
    合并srcPath下的user data到dest path下
    @param srcPath 待合并user data所在源路径
    @param destPath user data合并后所在目的路径
    @returns 成功时返回YES，否则返回NO
 */
- (BOOL) mergeUserDataAtPath:(NSString *)srcPath toPath:(NSString *)destPath;

/**
    创建默认启动的应用
    先尝试读取 default app根目录的app.xml, 如果有该文件就读取app info, 没有就创建默认的app info
    @returns 默认启动应用的实例
 */
- (id<XApplication>)createDefaultApp;

@end

