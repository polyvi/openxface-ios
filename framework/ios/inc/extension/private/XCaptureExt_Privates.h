
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
//  XCaptureExt_Privates.h
//  xFaceLib
//
//

#ifdef __XCaptureExt__

#import "XCaptureExt.h"

enum
{
    kImageTypeJPEG = 0,
    kImageTypePNG,
    kImageTypeUnknown
};

typedef NSUInteger ImageType;

enum
{
    DESTINATION_TYPE_DATA_URL = 0,
    DESTINATION_TYPE_FILE_URL
};

typedef NSUInteger DestinationType;

enum
{
    /**
     * 表示截屏执行成功
     */
    SUCCESS = 0,

    /**
     * 表示传入的参数有错误
     */
    ARGUMENT_ERROR,

    /**
     * 表示执行IO的时候发生了错误
     */
    IO_ERROR
};

#pragma mark -
#pragma mark XImagePicker

@interface XImagePicker : UIImagePickerController
{
}

@property (assign) NSInteger quality;
@property (strong) XJsCallback* jsCallback;
@property (copy)   NSString* mimeType;

@end

#pragma mark -
#pragma mark XCaptureExt

@class XExtensionResult;

@interface XCaptureExt ()

/**
    XImagePicker相机view的Controller
 */
@property (nonatomic,strong)XImagePicker* pickerController;

/**
    图片处理(图片存储、图片信息及结果的json数据处理)
    @param image 图片
    @param mimeType 图片类型
    @return 返回结果信息，包含图片名字等基本信息
 */
-(XExtensionResult*) processImage: (UIImage*) image type: (NSString*) mimeType;

/**
    视频处理(视频信息及结果的json数据处理)
    @param moviePath 视频所在的路径
    @return 返回结果信息，包含视频name等基本信息
 */
-(XExtensionResult *) processVideo: (NSString*) moviePath;

/**
    获取媒体类型信息如：audio/mp4
    @param fullPath 存媒体所在的全路径
    @return 返回媒体类型字串，不能确定时返回nil
 */
-(NSString*) getMediaTypeFromFullPath: (NSString*) fullPath;

/**
    打开录音界面
    @param theDuration 可录制的音频时长(单位s)
    @param theCallback 用于返回音频录制的结果的回调对象
 */
- (void) openCaptureAudioView: (NSNumber*) theDuration callback: (XJsCallback*) theCallback;

/**
    打开照相界面
    @param mode 设定图像的格式（默认是JPEG格式）
    @param theCallback 用于返回照相的结果的回调对象
 */
- (void) openCaptureImageView:(NSString*)mode callback: (XJsCallback*) theCallback;

/**
    获取设备支持的录制视频的媒体格式
    @return 返回支持的媒体格式,不支持则返回nil
 */
- (NSString*) getCaptureVideoSupportMediaType;

/**
    打开录制视频界面
    @param mediaType 录制视频采用的媒体格式
    @param theCallback 用于返回视频录制的结果的回调对象
 */
- (void) openCaptureVideoView:(NSString*)mediaType callback: (XJsCallback*) theCallback;

/**
    解析截图的保存路径
    @param   destPath 要解析的路径
    @returns 返回截图的保存路径
 */

- (NSString *)resolveDestPath:(NSString *)destPath;

/**
    根据截图的保存路径解析截图的保存类型
    @param   destPath 要解析的路径
    @returns 返回截图的保存类型
 */
- (ImageType)resolveImageTypeByPath:(NSString *)destPath;

/**
    处理截图的目标区域
    @param targetRect 原始目标区域
    @param defaultRect 默认的区域
    @returns 返回处理过的目标区域
 */
- (CGRect)resolveTargetRect:(CGRect)targetRect withDefaultRect:(CGRect)defaultRect;

/**
    处理截图数据
    @param image 截图数据
    @param imageType 图片类型
    @param destType  返回结果格式，base64或文件uri
    @param destPath  图片的保存路径
    @returns 返回XExtensionResult的实例对象
 */
-(XExtensionResult*) resolveImage:(UIImage*)image imageType:(ImageType)imageType destType:(DestinationType)destType destPath:(NSString*)destPath;

@end

#endif
