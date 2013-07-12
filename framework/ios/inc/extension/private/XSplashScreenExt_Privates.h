
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
//  XSplashScreenExt_Privates.h
//  xFaceLib
//
//

#import "XSplashScreenExt.h"

@interface XSplashScreenExt ()

/*
    获取UIImage实例
    @param imagePath 指定图片的路径
    @returns 如果imagePath有效且图片存在，则返回该图片的image实例，否则根据当前设备类型返回匹配的splash的image实例
 */
- (UIImage*)getImage:(NSString *)imagePath;

/*
    显示splash
    @param image 指定图片的image实例
    @param app   要显示splash的应用
    @returns 显示成功返回YES
 */
- (BOOL) showSplashWithImage:(UIImage*)image inApp:(id<XApplication>)app;

/**
    更新splash view的bounds，以解决横屏时splash不能全屏显示的问题
 */
- (void)updateBounds;

/*
    隐藏splash
 */
- (void) hide;

@end
