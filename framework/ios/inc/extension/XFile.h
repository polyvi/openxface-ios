
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
//  XFile.h
//  xFace
//
//

#ifdef __XFileExt__

#import <Foundation/Foundation.h>
#import "XFileConstants.h"

@interface XFile : NSObject

/**
    获得文件系统根信息
    @param size 指定一个大小，供查询文件系统是否有足够容量
    @param theType 文件系统类型
    @param workspace 该应用的工作空间
    @param outputError 错误代码，输出参数
    @returns 返回包含文件系统信息的数据
 */
- (NSMutableDictionary *)requestFileSystem:(unsigned long long)size type:(XFileSystemType)theType
                            usingWorkspace:(NSString*)workSpace error:(XFileError *)outputError;

/**
    创建或返回指定文件.
    若指定文件不存在，则创建该文件，否则返回存在的文件.
    @param workSpace 该应用所在的工作空间
    @param dir 要获取的文件（夹）所在的目录
    @param filePath 要获取的文件（夹）路径
    @param create <br/>
        - 若create为true, 文件不存在，则创建文件，返回
        - 若create为true，exclusive为true，文件不存在，返回error
        - 若create为false，文件不存在，返回error
        - 若create为false，path为dir路径，返回error
    @param exclusive(必须和create一起使用) <br/>
        - 若create为true，exclusive为true，文件存在，返回error
    @param isDir 指定创建或返回文件还是文件夹（true表示创建或返回文件夹，false表示创建或返回文件）
    @param outputError 错误代码，输出参数
    @returns 返回包含文件系统信息的数据
 */
- (NSDictionary *) getFile:(NSString*)workSpace dirPath:(NSString*)dirPath
                     filePath:(NSString*)filePath create:(BOOL)create exclusive:(BOOL)exclusive
                     isDir:(BOOL)isDir error:(XFileError *)outputError;

/**
    截断文件至指定位置.
    根据参数按照指定长度截断文件.
    @param workSpace 该应用所在的工作空间
    @param filePath 文件路径
    @param pos      指定的截断位置
    @param outputError 错误代码，输出参数
    @returns        文件流当前的位置
 */
- (unsigned long long) truncateFile:(NSString*)workSpace filePath:(NSString*)filePath
                         atPosition:(unsigned long long)pos error:(XFileError *)outputError;

/**
    截断文件至指定位置.
    根据参数按照指定长度截断文件.
    @param workSpace 该应用所在的工作空间
    @param filePath 文件路径
    @param pos      指定的截断位置
    @param outputError 错误代码，输出参数
    @returns        文件流当前的位置
 */
- (int) writeToFile:(NSString*)workSpace filePath:(NSString*)filePath withData:(NSString*)data
              append:(BOOL)shouldAppend error:(XFileError *)outputError;

/**
    删除文件(夹).
    删除指定路径的文件(夹).
    @param workSpace   该应用所在的工作空间
    @param filePath    待删除的文件(夹)路径
    @param outputError 错误代码，输出参数
    @returns           删除成功返回YES,否则返回NO
 */
- (BOOL) remove:(NSString*)workSpace filePath:(NSString*)filePath error:(XFileError*)outputError;

/**
    复制或者移动文件(夹).
    @param workSpace     该应用所在的工作空间
    @param oldPath       源文件（夹）路径
    @param newParentPath 目的文件夹路径（即要复制或移动到哪个文件夹）
    @param newName       新的文件（夹）名
    @param isCopy        标识是复制还是移动（YES表示复制，NO表示移动）
    @param outputError   错误代码，输出参数
    @returns 返回包含文件系统信息的数据
 */
- (NSDictionary*) transferTo:(NSString*)workSpace oldPath:(NSString*)oldPath newParentPath:(NSString*)newParentPath
            newName:(NSString*)newName isCopy:(BOOL)isCopy error:(XFileError*)outputError;

/**
    获取父文件夹.
    @param workSpace   该应用所在的工作空间
    @param filePath    文件(夹)路径
    @param outputError 错误代码，输出参数
    @returns           父文件夹信息
 */
- (NSDictionary*) getParent:(NSString*)workspace filePath:(NSString*)filePath error:(XFileError*)outputError;

/**
    删除文件夹中的所有内容.
    @param workSpace   该应用所在的工作空间
    @param filePath    待删除的文件夹路径
    @param outputError 错误代码，输出参数
    @returns           删除成功返回YES,否则返回NO
 */
- (BOOL) removeRecursively:(NSString*)workspace filePath:(NSString*)filePath error:(XFileError*)outputError;

/**
    获得Entry对象的元数据(目前只包含最后修改时间).
    @param workSpace   该应用所在的工作空间
    @param filePath    文件(夹)路径
    @param outputError 错误代码，输出参数
    @returns           最后修改时间
 */
- (NSDate*) getMetadata:(NSString*)workspace filePath:(NSString*)filePath error:(XFileError*)outputError;

/**
    读取文本文件.
    @param workSpace   该应用所在的工作空间
    @param filePath    要读的文件路径
    @param outputError 错误代码，输出参数
    @returns           读到的数据
 */
- (NSString*) readAsText:(NSString*)workspace filePath:(NSString*)filePath error:(XFileError*)outputError;

/**
    读取URL格式的文件.
    @param workSpace   该应用所在的工作空间
    @param filePath    要读的文件路径
    @param outputError 错误代码，输出参数
    @returns           读到的数据
 */
- (NSString*) readAsDataURL:(NSString*)workspace filePath:(NSString*)filePath error:(XFileError*)outputError;

/**
    读取文件夹中的所有文件和文件夹.
    @param workSpace   该应用所在的工作空间
    @param filePath    要读的文件夹路径
    @param outputError 错误代码，输出参数
    @returns           文件夹中的所有内容
 */
- (NSMutableArray*) readEntries:(NSString*)workspace filePath:(NSString*)filePath error:(XFileError*)outputError;

/**
    解析URI格式的文件路径.
    @param workSpace   该应用所在的工作空间
    @param fileURI     URI格式的文件路径
    @param outputError 错误代码，输出参数
    @returns           返回包含文件系统信息的数据
 */
- (NSDictionary*) resolveLocalFileSystemURI:(NSString*)workspace fileURI:(NSString*)fileURI error:(XFileError*)outputError;

/**
    设置Entry对象的元数据属性(目前只支持com.apple.MobileBackup属性).
    @param metadataValue   元数据属性值(1或0,设置为1不允许文件(夹)通过iCloud备份;设置为0允许通过iCloud备份)
    @param filePath    文件(夹)路径
    @returns           返回设置结果成功返回TRUE,失败返回FALSE
 */
- (BOOL) setMetadata:(id)metadataValue filePath:(NSString*)filePath;

@end

#endif
