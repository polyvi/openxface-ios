
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
//  XFileTransferExt.h
//  xFace
//
//

#ifdef __XFileTransferExt__

#import <Foundation/Foundation.h>
#import "XExtension.h"

@class XJavaScriptEvaluator;

enum XFileTransferDirection
{
    TRANSFER_UPLOAD = 1,
    TRANSFER_DOWNLOAD = 2,
};
typedef int XFileTransferDirection;

@interface XFileTransferExt : XExtension
{

}

/**
    产生FileTransfer错误信息对象.
    @param code         错误码， XFileTransferError中的一种（FILE_NOT_FOUND_ERR ,INVALID_URL_ERR,CONNECTION_ERR）
    @param source       源路径
    @param target       目的路径
    @param httpStatus   发生错误时的连接状态
    @returns 错误信息对象
 */
-(NSMutableDictionary*) createFileTransferError:(int)code andSource:(NSString*)source andTarget:(NSString*)target andHttpStatus:(int)httpStatus;

/**
    文件下载.
    @param arguments 参数列表
    - 0 XJsCallback* callback
    - 1 NSString* serverURL 服务器路径
    - 2 NSString* filePath  本地存储下载文件的路径
    @param options 可选参数
 */
- (void) download:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    文件上传.
    @param arguments 参数列表
    - 0 XJsCallback* callback
    - 1 NSString* source     要上传的本地文件路径
    - 2 NSString* target     接收文件的服务器地址
    - 3 NSString* fileKey    表单元素的name值
    - 4 NSString* fileName   希望文件存储到服务器所用的文件名
    - 5 NSString* mimeType   正在上传数据所使用的mime类型
    - 6 BOOL trustEveryone   信任所有的主机(目前ios平台没有使用)
    - 7 BOOL chunkedMode     数据是否以块流模式上传，如果没有这个参数，默认该值为true
    - 8 id<XApplication> app 表示当前应用
    @param options params    通过HTTP请求发送到服务器的一系列可选键/值对
 */
- (void) upload:(NSMutableArray*)arguments withDict:(NSDictionary*)options;

@end

#endif
