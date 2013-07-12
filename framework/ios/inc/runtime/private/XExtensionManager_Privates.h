
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
//  XExtensionManager_Privates.h
//  xFaceLib
//
//

#import "XExtensionManager.h"

@interface XExtensionManager ()

/**
    扩展对象集合
 */
@property (nonatomic, strong) NSMutableDictionary *extensionObjects;

/**
    xFace 的rootViewController
 */
@property (weak, nonatomic) XRootViewController *rootViewController;

/**
    负责command的获取与执行
 */
@property (nonatomic, readwrite, strong) XCommandQueue* commandQueue;

/**
    用于获取扩展对象js端与native端的映射关系
 */
@property (nonatomic, readwrite, strong) NSDictionary *extensionsDict;

/**
    通过扩展名称获取对应的扩展对象
    如果扩展对象集合中不存在相应的对象，则需创建后添加到扩展集合中
    @param extensionName 扩展名称
    @returns 与扩展名称对应的对象，如果创建失败，则返回nil
 */
- (id) getCommandInstance:(NSString *)extensionName;

/**
    执行扩展方法
    @param arguments 待执行扩展方法需要的参数
 */
- (void) executeExtension:(NSArray*)arguments;

/**
    尝试执行XApplication相关的命令
    @param cmd 待执行的命令
    @returns 执行了XApplication相关的命令，返回YES,否则返回NO
 */
- (BOOL) tryExecuteXApplicationCmd:(XCommand *)cmd;

/**
    判断是否为XApplication相关的命令
    @param cmdMethodName 待判断的命令
    @returns 是XApplication相关的命令，返回YES,否则返回NO
 */
- (BOOL) isXApplicationCmd:(NSString *)cmdMethodName;

@end
