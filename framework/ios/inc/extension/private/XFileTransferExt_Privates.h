
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
//  XFileTransferExt_Privates.h
//  xFaceLib
//
//

#ifdef __XFileTransferExt__

#import "XFileTransferExt.h"

@interface XFileTransferExt()

@property (readonly) NSMutableDictionary* activeTransfers;

/*
    使用块流传输时将给定的数据写入到stream中
    @param data   要写入的数据
    @param stream 接收数据的流
    @return 成功返回写入数据的字节数，失败返回－1,如果流已经满了返回0
 */
- (CFIndex) writeDataToStream:(NSData *)data stream:(CFWriteStreamRef)stream;

/*
    处理头部信息(js端传过来的键值对形式的头部信息，将其设置到request)
    @param request 连接请求
    @param headers 要处理的头部信息
 */
- (void) handleHeaders:(NSMutableURLRequest *)request withDict:(NSDictionary *) headers;

/*
    获取要发送给服务器的具体文件数据的前面部分
    @param arguments 参数列表
    @param options   可选参数
    @param fileData  要发送给服务器的具体文件数据
    @return 要发送给服务器的具体文件数据的前面部分
 */
- (NSMutableData *)createHeadersForUploadingFile:(NSMutableArray*)arguments withDict:(NSDictionary*)options fileData:(NSData*)fileData;

/*
    获取上传的请求
    @param arguments 参数列表
    @param options   可选参数
    @param fileData  要发送给服务器的具体文件数据
    @return NSURLRequest对象
 */
- (NSURLRequest*) requestForUpload:(NSMutableArray*)arguments withDict:(NSDictionary*)options fileData:(NSData*)fileData;

/*
    从js传过来的参数中获取要上传文件的数据
    @param arguments 参数列表
    @param options   可选参数
    @return 要上传文件的数据
 */
- (NSData*) fileDataForUploadArguments:(NSMutableArray*)arguments withDict:(NSDictionary*)options;

@end

#endif
