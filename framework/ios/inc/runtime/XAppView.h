
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
//  XAppView.h
//  xFace
//
//

#import <Foundation/Foundation.h>

/**
	定义app view接口，与XApplication关联的视图类将从此类派生
 */
@protocol XAppView <NSObject>

@property (nonatomic, getter = isValid) BOOL valid; /**<该视图是否有效，即是否与应用关联，- YES 表示该视图与一个app相关联，该app处于活动状态
                                             - NO 表示该视图曾经关联的app已经关闭，且不再与任何app关联，处于无效状态*/

/**
	加载应用到view上显示
	@param url 待加载应用的url
 */
- (void) loadApp:(NSURL *)url;

/**
	显示view
 */
- (void) show;

/**
	关闭view
 */
- (void) close;

@end
