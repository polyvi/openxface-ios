
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
//  XSync.h
//  xFaceLib
//
//

//该delegate用于通知同步完成
@protocol XSyncDelegate <NSObject>
-(void) syncDidFinish;
@end

//该类用于同步player的app
@interface XSync :NSObject <NSURLConnectionDelegate>
{
@private
    NSString* localFilePath;               /** 保存文件的路径*/
    NSString* tmpFilePath;                 /** 临时文件的路径*/
    NSFileHandle* fileHandle;              /** 用于保存文件*/
    id<XSyncDelegate> syncDelegate;        /** 用于通知同步完成*/

    int responseCode;                      /** 请求状态码 */
}

- (id) initWith:(id<XSyncDelegate>)delegate;

/*
    执行同步
 */
- (void) run;

@end
