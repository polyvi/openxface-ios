
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
//  XRootViewController.h
//  xFace
//
//

#import <UIKit/UIKit.h>

@protocol XAppView;
@protocol XApplication;

@interface XRootViewController : UIViewController {
    UIImageView             *splashView;      /**< splash视图对象 */
    UIActivityIndicatorView *activityView;    /**< ActivityIndicator视图，用于显示spinner */
}

/**
    为指定的application创建app view
    @param app 待为其创建app view的application
    @returns   创建后的app view, 如果创建失败，则返回nil
 */
- (id<XAppView>) createView:(id<XApplication>) app;

/**
    显示appview
 */
- (void) showView:(id<XAppView>)appView;

/**
    关闭指定的app view
    @param appView 待关闭的app view
 */
- (void) closeView:(id<XAppView>)appView;

/**
    停止显示splash
 */
- (void)stopShowingSplash;

@end

