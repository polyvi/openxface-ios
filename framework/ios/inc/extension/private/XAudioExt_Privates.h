
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
//  XAudioExt_Privates.h
//  xFaceLib
//
//

#ifdef __XAudioExt__

#import "XAudioExt.h"

enum XMediaError {
    MEDIA_ERR_ABORTED = 1,
    MEDIA_ERR_NETWORK = 2,
    MEDIA_ERR_DECODE = 3,
    MEDIA_ERR_NONE_SUPPORTED = 4
};
typedef NSUInteger XMediaError;

enum XMediaStates {
    MEDIA_NONE = 0,
    MEDIA_STARTING = 1,
    MEDIA_RUNNING = 2,
    MEDIA_PAUSED = 3,
    MEDIA_STOPPED = 4
};
typedef NSUInteger XMediaStates;

enum XMediaMsg {
    MEDIA_STATE = 1,
    MEDIA_DURATION = 2,
    MEDIA_POSITION = 3,
    MEDIA_ERROR = 4
};
typedef NSUInteger XMediaMsg;

@interface XAudioPlayer : AVAudioPlayer
{
    NSString* mediaId;
}
@property (nonatomic, copy) NSString* mediaId;
@end

@interface XAudioRecorder : AVAudioRecorder
{
}
@property (nonatomic, copy) NSString* mediaId;
@end

@protocol XApplication;

@interface XAudioFile : NSObject
{
}

@property (nonatomic, strong) NSString* resourcePath;
@property (nonatomic, strong) NSURL* resourceURL;
@property (nonatomic, strong) XAudioPlayer* player;
@property (nonatomic, strong) NSNumber* volume;
@property (nonatomic, strong) XAudioRecorder* recorder;
@property (nonatomic, strong) id<XApplication> application;

@end

@interface XAudioExt ()

@property (nonatomic, strong) NSMutableDictionary* soundCache;
@property (nonatomic, strong) AVAudioSession* avSession;

/**
    是否有audio会话存在.
    @return 返回正确的图片资源字串
 */
- (BOOL)hasAudioSession;

/**
    将资源path解析为相应的NSURL对象.
    @param resourcePath 资源的路径或http/file等协议的资源
    @param workspace app的工作空间路径
    @param isRecord 是否是录音
    @return 返回资源路径代表的的NSURL对象，可能返回nil
 */
- (NSURL*)urlForResource:(NSString*)resourcePath withPath:(NSString*)workspace isRecord:(BOOL)isRecord;

/**
    根据资源path生成对应的XAudioFile对象.
    @param resourcePath 资源的路径或http/file等协议的资源
    @param mediaId XAudioFile对象对应的标识
    @param workspace app的工作空间路径
    @param isRecord 是否是录音
    @return 返回资源路径代表的的XAudioFile对象，可能返回nil
 */
- (XAudioFile*)audioFileForResource:(NSString*)resourcePath withId:(NSString*)mediaId withPath:(NSString*)workspace isRecord:(BOOL)isRecord;

/**
    进行audio播放的初始化.
    @param audioFile 资源对应的XAudioFile对象
    @param mediaId XAudioFile对象对应的标识
    @return 返回正确的图片资源字串
 */
- (BOOL)prepareToPlay:(XAudioFile*)audioFile withId:(NSString*)mediaId;

/**
    创建MediaError的消息由code + message组成.
    @param code MediaError错误码
    @param message 错误消息
    @return 返回MediaError的消息
 */
- (NSString*)createMediaErrorWithCode:(XMediaError)code message:(NSString*)message;

/**
    通过app对应的webview执行JS.
    @param jsScript 要执行的js语句
    @param app XApplication对象 执行该扩展接口对应的app
 */
- (void)eavlJs:(NSString*)jsScript by:(id<XApplication>)app;

@end

#endif
