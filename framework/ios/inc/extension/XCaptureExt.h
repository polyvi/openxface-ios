
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
//  XCaptureExt.h
//  xFaceLib
//
//
#ifdef __XCaptureExt__

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "XExtension.h"

enum CaptureError {
    CAPTURE_INTERNAL_ERR = 0,
    CAPTURE_APPLICATION_BUSY = 1,
    CAPTURE_INVALID_ARGUMENT = 2,
    CAPTURE_NO_MEDIA_FILES = 3,
    CAPTURE_NOT_SUPPORTED = 20
};
typedef NSUInteger CaptureError;

@class XJavaScriptEvaluator;
@class XJsCallback;

@interface XCaptureExt : XExtension<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
}

/**
    capture是否在使用中
 */
@property BOOL inUse;

/**
    初始化方法
    @param msgHandler 消息处理者
    @return 初始化后的Capture扩展对象，如果初始化失败，则返回nil
 */
- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler;

/**
    使用创建的audiorecordview,根据参数捕获音频.
    @param arguments 捕获音频参数
        - 0 XJsCallback* callback
    @param options 可选参数
        - 0 captureAudioOptions limit 最大可捕获音频数,默认是1 IOS 不支持设置
        - 1 captureAudioOptions duration 最大可捕获音频时长,单位秒
        - 2 captureAudioOptions mode 捕获音频的格式 IOS 不支持设置
 */
- (void) captureAudio:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    使用系统的camera,根据参数捕获图片.
    @param arguments 捕获图片参数
        - 0 XJsCallback* callback
    @param options 可选参数
        - 0 captureImageOptions limit 最大可捕获图片数,默认是1 IOS 不支持设置
        - 1 captureImageOptions mode 捕获图片的格式 IOS 不支持设置
 */
- (void) captureImage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    使用系统的camera,根据参数捕获视频.
    @param arguments 捕获视频参数
        - 0 XJsCallback* callback
    @param options 可选参数
        - 0 captureVideoOptions limit 最大可捕获视频数,默认是1 IOS 不支持设置
        - 1 captureVideoOptions duration 最大可捕获视频时长,单位秒 IOS 不支持设置
        - 2 captureVideoOptions mode 捕获视频的格式 IOS 不支持设置
 */
- (void) captureVideo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    获取媒体文件的格式(image/audio/video)
    @param arguments 捕获视频参数
        - 0 XJsCallback* callback
    @param options 可选参数(本接口中未使用)
 */
- (void) getMediaModes: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    获取媒体数据信息(bitrate/codecs/duration/height/width)
    @param arguments 捕获视频参数
        - 0 XJsCallback* callback
    @param options 可选参数(本接口中未使用)
 */
- (void) getFormatData: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    截图
    @param arguments 捕获视频参数
        - 0 jsOptions 截图参数
                key                value
            destinationType       返回结果的类型
            destionationFile      图片的保存路径
                x                 起点x坐标
                y                 起点y坐标
              width               图片的宽度
              height              图片的高度
 @param options
 */
- (void) captureScreen: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    获取存有媒体路径及类型信息的字典对象(包括name/type等信息)
    @param fullPath 全路径
    @param type 类型
    @return 返回包含媒体基本信息的字典对象
 */
-(NSDictionary*) getMediaDictionaryFromPath: (NSString*) fullPath ofType: (NSString*) type;


/**
    执行captureaudio结果，返回js端
    @param callback captureaudio回调结果
 */
-(void)captureAudioResult:(XJsCallback*)callback;

@end

#endif
