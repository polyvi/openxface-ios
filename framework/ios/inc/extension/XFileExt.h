
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
//  XFileExt.h
//  xFace
//
//

#ifdef __XFileExt__

#import <Foundation/Foundation.h>
#import "XExtension.h"

@class XJavaScriptEvaluator;

/**
	文件系统扩展，实现文件、目录操作等功能
 */
@interface XFileExt : XExtension

/**
	初始化方法
	@param msgHandler 消息处理者
	@returns 初始化后的file扩展对象，如果初始化失败，则返回nil
 */
- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler;

/**
	写文件.
    根据参数向指定文件写入.
	@param arguments 写文件参数
        - 0 XJsCallback* callback
        - 1 NSString* file path
        - 2 NSString* data to write
        - 3 NSString* position to begin with
	@param options 可选参数
 */
- (void) write:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	截断文件至指定位置.
    根据参数按照指定长度截断文件.
	@param arguments 参数列表
        - 0 NSString* file path
        - 1 long 指定的截断位置
	@param options 可选参数
 */
- (void) truncate:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	创建或返回指定文件.
    若指定文件不存在，则创建该文件，否则返回存在的文件.
	@param arguments 参数列表
        - 0 NSString* full path for this file
        - 1 NSString* path，可能是绝对路径或者相对路径
        - 2 NSDictionary* flags
    @param options 可选参数,，有create和exclusive两种， <br/>
        create <br/>
        - 若create为true, 文件不存在，则创建文件，返回
        - 若create为true，exclusive为true，文件不存在，返回error
        - 若create为false，文件不存在，返回error
        - 若create为false，path为dir路径，返回error
        exclusive(必须和create一起使用) <br/>
        - 若create为true，exclusive为true，文件存在，返回error
 */
- (void) getFile:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	创建或返回指定文件夹.
    若指定文件夹不存在，则创建该文件夹，否则返回存在的文件夹.
    @param arguments 参数列表
        - 0 NSString* full path for this directory
        - 1 NSString* path，可能是绝对路径或者相对路径
        - 2 NSDictionary* flags
    @param options 可选参数,，有create和exclusive两种， <br/>
        create <br/>
        - 若create为true, 文件夹不存在，则创建文件夹，返回
        - 若create为true，exclusive为true，文件夹不存在，返回error
        - 若create为false，文件夹不存在，返回error
        - 若create为false，path为file路径，返回error
        exclusive(必须和create一起使用) <br/>
        - 若create为true，exclusive为true，文件夹存在，返回error
 */
- (void) getDirectory:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	获得文件的元数据.
	@param arguments 参数列表
        - 0 NSString* 文件路径
	@param options 可选参数
 */
- (void) getFileMetadata:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	复制文件(夹).
    把文件(夹)从源路径复制到目标路径.
	@param arguments 参数列表
        - 0 XJsCallback* callback
        - 1 NSString* 源文件(夹)路径
        - 2 NSString* 目标文件(夹)路径
	@param options 可选参数
        - fullPath 目标文件(夹)的根目录
 */
- (void) copyTo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    移动文件(夹).
    把文件(夹)从源路径移动到目标路径.
    @param arguments 参数列表
        - 0 XJsCallback* callback
        - 1 NSString* 源文件(夹)路径
        - 2 NSString* 目标文件(夹)路径
    @param options 可选参数
        - fullPath 目标文件(夹)的根目录
 */
- (void) moveTo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	删除文件(夹).
    删除指定路径的文件(夹).
	@param arguments 参数列表
        - 0 XJsCallback* callback
        - 1 NSString* 待删除的文件(夹)路径
	@param options 可选参数
 */
- (void) remove:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	查询指定文件(夹)的父目录.
    查询指定文件(夹)的父目录，若指定路径为文件系统的根，则它的父目录是自己.
    @param arguments 参数列表
        - 0 XJsCallback* callback
        - 1 NSString* 文件(夹)路径
    @param options 可选参数
 */
- (void) getParent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    删除指定文件(夹)以及其所有内容.
	@param arguments 参数列表
        - 0 XJsCallback* callback
        - 1 NSString* 待删除的文件(夹)路径
	@param options 可选参数
 */
- (void) removeRecursively:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	以文本方式读取文件内容.
	@param arguments 参数列表
        - 0 XJsCallback* callback
        - 1 NSString* 文件路径
        - 2 NSString* encoding，iOS未使用，默认按照UTF8模式
	@param options 可选参数
 */
- (void) readAsText:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	读取文本文件内容，并以base64编码的data url方式返回.
    @param arguments 参数列表
        - 0 XJsCallback* callback
        - 1 NSString* 文件路径
	@param options 可选参数
 */
- (void) readAsDataURL:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	获得指定文件夹包含的所有(文件)目录项
	@param arguments 参数列表
        - 0 NSString* 文件夹路径
	@param options 可选参数
 */
- (void) readEntries:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	解析URI格式的文件路径.
    解析URI，返回W3C标准的entry对象
	@param arguments 参数列表
        - 0 NSString* file URI
	@param options 可选参数
 */
- (void) resolveLocalFileSystemURI:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	获得Entry对象的元数据(目前只包含最后修改时间).
	@param arguments 参数列表
        - 0 NSString* entry path
	@param options 可选参数
 */
- (void) getMetadata:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    设置Entry对象的元数据属性(目前只支持com.apple.MobileBackup属性).
    @param arguments 参数列表
        - 0 NSString* entry path
    @param options 可选参数
        - metadataValue   元数据属性值(1或0,设置为1不允许文件(夹)通过iCloud备份;设置为0允许通过iCloud备份)
 */
- (void) setMetadata:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	获得文件系统根信息.
	@param arguments 参数列表
        - 0 NSString* type, 'temporary' or 'persistent'
        - 1 unsigned long long size，请求的空间大小(尚未使用)
	@param options 可选参数
 */
- (void) requestFileSystem:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
