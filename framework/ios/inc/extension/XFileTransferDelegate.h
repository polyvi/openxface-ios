
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
//  XFileTransferDelegate.h
//  xFace
//
//

#ifdef __XFileTransferExt__

#import <Foundation/Foundation.h>
#import "XFileTransferExt.h"

@class XJsCallback;

@interface XFileTransferDelegate : NSObject

@property (retain) NSMutableData* responseData; // atomic
@property (strong, nonatomic) XFileTransferExt* command;
@property (nonatomic, assign) XFileTransferDirection direction;
@property (nonatomic, strong) NSURLConnection* connection;
@property (strong, nonatomic) XJsCallback* jsCallback;
@property (nonatomic, copy)   NSString* objectId;
@property (strong, nonatomic) NSString* source;
@property (strong, nonatomic) NSString* target;
@property (strong, nonatomic) NSString* workspace;
@property (strong, nonatomic) XJavaScriptEvaluator* jsEvaluator;
@property (assign) int responseCode; // atomic
@property (nonatomic, assign) NSInteger bytesTransfered;
@property (nonatomic, assign) NSInteger bytesExpected;

/**
    发送进度通知
    @param lengthComputable 发送数据的长度是否已知
    @param transfer 已经传送的字节数
    @param total 需传送的总字节数
 */
-(void) sendProgressCallBack:(BOOL)lengthComputable bytesTransfer:(NSInteger)transfer bytesTotal:(NSInteger)total;

@end

#endif
