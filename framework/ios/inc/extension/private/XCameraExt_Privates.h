
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
//  XCameraExt_Privates.h
//  xFaceLib
//
//

#ifdef __XCameraExt__

#import "XCameraExt.h"

enum DestinationType
{
    DESTINATION_TYPE_DATA_URL = 0,
    DESTINATION_TYPE_FILE_URL
};
typedef NSUInteger DestinationType;

enum EncodingType
{
    ENCODING_TYPE_JPEG = 0,
    ENCODING_TYPE_PNG
};
typedef NSUInteger EncodingType;

enum MediaType
{
    MEDIA_TYPE_PICTURE = 0,
    MEDIA_TYPE_VIDEO,
    MEDIA_TYPE_ALL
};
typedef NSUInteger MediaType;

#pragma mark -
#pragma mark XCameraPicker

@interface XCameraPicker : UIImagePickerController
{
}

@property (assign) NSInteger quality; //图片质量百分比 0-100
@property (strong)   XJsCallback* jsCallback; //回调
@property (nonatomic) enum DestinationType returnType; //目标类型
@property (nonatomic) enum EncodingType encodingType; //编码类型
@property (strong) UIPopoverController* popoverController;
@property (assign) CGSize targetSize; //目标尺寸
@property (assign) bool correctOrientation; //是否调整正确方向
@property (assign) bool saveToPhotoAlbum; //是否保存到相册
@property (assign) bool cropToSize; //是否需要裁剪尺寸
@property (assign) BOOL popoverSupported; //是否支持popoverView显示

@end

#pragma mark -
#pragma mark XCameraExt

@interface XCameraExt ()

@property (strong) XCameraPicker* pickerController;

/**
    图片缩放(等比缩放)并且裁剪到合适的尺寸大小
    @param (UIImage*)anImage 待处理图片
    @param (CGSize)targetSize 目标尺寸大小
    @returns 返回缩放和裁剪处理后的图片
 */
- (UIImage*)imageByScalingAndCroppingForSize:(UIImage*)anImage toSize:(CGSize)targetSize;

/**
    图片缩放(等比缩放)但不裁剪到合适的尺寸大小
    @param (UIImage*)anImage 待处理图片
    @param ((CGSize)frameSize 图片帧的尺寸大小
    @returns 返回缩放处理后的图片
 */
- (UIImage*)imageByScalingNotCroppingForSize:(UIImage*)anImage toSize:(CGSize)frameSize;

/**
    图片调整正确的方向与捕捉时一致
    @param (UIImage*)anImage 待处理图片
    @returns 返回处理后的图片
 */
- (UIImage*)imageCorrectedForCaptureOrientation:(UIImage*)anImage;

/**
    关闭CameraPicker view
    @param (XCameraPicker*)picker camera view的controller
 */
- (void) closePicker:(XCameraPicker*)picker;

/**
    生成照片的path完整路径，并返回路径
    @param (EncodingType)Type 图片的媒体类型
    @returns 返回照片的完整路径
 */
-(NSString*) generateFilePathFromType:(EncodingType)Type;

/**
    创建存储照片的文件夹，并返回文件夹的路径
    @returns 返回存储照片文件夹的路径
 */
-(NSString*) createPhotoDirPath;

/**
    清除文件或文件夹，返回YES 或 NO
    @param (NSString*)Path 待清除的文件或文件夹路径
    @returns 返回YES（成功） 或 NO（失败）
 */
-(BOOL) cleanupAtPath:(NSString*)Path;

/**
    根据目标尺寸大小决定是否需要对图片进行裁剪、调整大小
    @param image 待处理的图片
    @param size 目标尺寸大小
    @param crop 是否需要对图片进行裁剪
    @returns 返回处理后的图片
 */
-(UIImage*) handleImage:(UIImage*)image targetSize:(CGSize)size needCrop:(BOOL)crop;

/**
    根据图片的编码和图片质量，获取图片的data数据
    @param image 资源图片
    @param type 图片的编码类型
    @param aquality 图片的质量
    @returns 返回获取到的图片data
 */
-(NSData*) getImageData:(UIImage*)image encodeType:(EncodingType)type quality:(NSInteger)aquality;

/**
    打开CameraPicker view
    @param (XCameraPicker*)picker camera view的controller
 */
-(void) openPicker:(XCameraPicker*)cameraPicker;

@end

#endif
