
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
//  XAppUpdater.h
//  xFaceLib
//
//

//该类用于检测是否存在新版本的app，通过appstore更新app
@interface XAppUpdater :NSObject <NSURLConnectionDelegate, UIAlertViewDelegate>
{
    NSMutableData* downloadAddressData;    /** 用于保存从服务器获取到的app下载地址 */
    int responseCode;                      /** 请求状态码 */
}

/*
    执行检测更新
 */
- (void) run;

@end
