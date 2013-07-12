
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
//  XCameraExt.h
//  xFaceLib
//
//

#ifdef __XCameraExt__

#import <Foundation/Foundation.h>
#import "XExtension.h"

@interface XCameraExt : XExtension<UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate,
                                    UIPopoverControllerDelegate>
{
}

/**
    使用Camera,根据参数拍照.
    @param arguments 拍照参数
        - 0 XJsCallback* callback
        - 1 quality 压缩质量百分比
        - 2 destinationType 目标结果的类型
        - 3 sourceType 图像来源;如 相片库/照相机/保存的相片
        - 4 targetWidth 目标尺寸宽度
        - 5 targetHeight 目标尺寸高度
        - 6 encodingType 编码格式
        - 7 mediaType 媒体类型
        - 8 allowEdit 是否允许编辑
        - 9 correctOrientation 正确的方向
        - 10 saveToPhotoAlbum 保存到相册
    @param options 可选参数 本接口未使用
 */
- (void) takePicture:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    清除所有使用takePicture拍照存储在程序tmp 文件夹下的照片.
    @param arguments 拍照参数
        - 0 XJsCallback* callback
    @param options 可选参数 本接口未使用
 */
- (void) cleanup:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
