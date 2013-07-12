
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
//  XAudioExt.h
//  xFaceLib
//
//

#ifdef __XAudioExt__

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "XExtension.h"

@interface XAudioExt : XExtension <AVAudioPlayerDelegate, AVAudioRecorderDelegate>
{
}

/**
    start 或者 resume音频文件.
    @param arguments
    - 0 XJsCallback* callback
    - 1 mediaId  audio对象的标识
    - 2 resourcePath 音频文件的绝对路径
    - 3 app 执行此扩展的app
    @param options 可选参数 本接口未使用
 */
- (void)play:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    暂停播放音频文件.
    @param arguments
    - 0 XJsCallback* callback
    - 1 mediaId  audio对象的标识
    - 2 app 执行此扩展的app
    @param options 可选参数 本接口未使用
 */
- (void)pause:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    停止播放音频文件.
    @param arguments
    - 0 XJsCallback* callback
    - 1 mediaId  audio对象的标识
    - 2 app 执行此扩展的app
    @param options 可选参数 本接口未使用
 */
- (void)stop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    跳到audio的某个位置.
    @param arguments
    - 0 XJsCallback* callback
    - 1 mediaId  audio对象的标识
    - 2 Milliseconds 需要调到新位置的毫秒值
    - 3 app 执行此扩展的app
    @param options 可选参数 本接口未使用
 */
- (void)seekTo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    释放audio实例.
    @param arguments
    - 0 XJsCallback* callback
    - 1 mediaId  audio对象的标识
    - 2 app 执行此扩展的app
    @param options 可选参数 本接口未使用
 */
- (void)release:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    获取audio 的当前播放位置.(通过callback 返回position或者-1)
    @param arguments
    - 0 XJsCallback* callback
    - 1 mediaId  audio对象的标识
    - 2 app 执行此扩展的app
    @param options 可选参数 本接口未使用
 */
- (void)getCurrentPosition:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    开始录制一段audio，并保存到指定的文件
    @param arguments
    - 0 XJsCallback* callback
    - 1 mediaId  audio对象的标识
    - 2 outputFileName 输出音频文件的filename,由js端指定
    - 3 app 执行此扩展的app
    @param options 可选参数 本接口未使用
 */
- (void)startRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    停止录制audio，并保存到指定的文件
    @param arguments
    - 0 XJsCallback* callback
    - 1 mediaId  audio对象的标识
    - 2 app 执行此扩展的app
    @param options 可选参数 本接口未使用
 */
- (void)stopRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    设置播放audio的volume 大小
    @param arguments
    - 0 XJsCallback* callback
    - 1 mediaId  audio对象的标识
    - 2 volume 指定volume的大小,由js端指定
    - 3 app 执行此扩展的app
    @param options 可选参数 本接口未使用
 */
- (void)setVolume:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
