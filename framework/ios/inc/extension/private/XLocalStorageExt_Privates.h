
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
//  XLocalStorageExt_Privates.h
//  xFaceLib
//
//

#import "XLocalStorageExt.h"

@interface XLocalStorageExt ()

@property (nonatomic, readwrite, strong) NSMutableArray* backupInfo;

/**
    verify and fix the iOS 5.1 database locations
 */
- (void) verifyAndFixDatabaseLocations;

/**
    创建Backup 的文件夹，并返回 BackupInfo 数组
    @return 返回 存有相关备份位置信息和原位置信息的 数组
 */
- (NSMutableArray*)createBackupInfo;

/*
    创建备份信息（包含原位置 备份位置）的信息数组
    @param targetDir 目标文件路径
    @param backupDir 备份文件路径
    @param rename 是否需要改名
    @return 返回 存有相关备份位置信息和原位置信息的 数组
 */
- (NSMutableArray*) createBackupInfoWithTargetDir:(NSString*)targetDir backupDir:(NSString*)backupDir rename:(BOOL)rename;

/**
    解决遗留localstorage备份在同步过程中丢失的问题
 */
- (void) fixLegacyDatabaseLocationIssues;

/*
    拷贝原文件到目标文件路径
    @param src 原始文件路径
    @param dest 目标文件路径
    @return YES表示成功，NO表示失败
 */
- (BOOL) copyFrom:(NSString*)src to:(NSString*)dest error:(NSError**)error;

/**
    将数据从webkitDbLocation备份到persistentDbLocation
    @param arguments 参数列表
    @param options   可选参数
 */
- (void) backup:(NSArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    将persistentDbLocation中得数据恢复到webkitDbLocation
    @param arguments 参数列表
    @param options   可选参数
 */
- (void) restore:(NSArray*)arguments withDict:(NSMutableDictionary*)options;

/*
    点击Home键回到后台时调用
 */
- (void) onResignActive;

@end

@interface XBackupInfo : NSObject

@property (nonatomic, copy) NSString* original;
@property (nonatomic, copy) NSString* backup;
@property (nonatomic, copy) NSString* label;

/**
    是否需要备份
    @returns YES表示需要备份，NO表示不需要备份
 */
- (BOOL) shouldBackup;

/**
    是否需要恢复
    @returns YES表示需要恢复，NO表示不需要恢复
 */
- (BOOL) shouldRestore;

/*
    判断aPath对应的文件项是否比bPath对应的文件项要新(具体的判断方法)
    @param aPath 原始文件路径
    @param bPath 目标文件路径
    @return YES表示aPath对应的文件比bPath对应的文件要新，NO表示bPath对应的文件比aPath对应的文件要新
 */
- (BOOL) file:(NSString*)aPath isNewerThanFile:(NSString*)bPath;

/*
    判断aPath对应的文件项是否比bPath对应的文件项要新(根据文件的最后修改时间来做具体的判断)
    @param aPath 原始文件路径
    @param bPath 目标文件路径
    @return YES表示aPath对应的文件比bPath对应的文件要新，NO表示bPath对应的文件比aPath对应的文件要新
 */
- (BOOL) item:(NSString*)aPath isNewerThanItem:(NSString*)bPath;

@end
