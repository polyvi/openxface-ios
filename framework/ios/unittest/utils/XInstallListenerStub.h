
/*
 Copyright 2012-2013, Polyvi Inc. (http://polyvi.github.io/openxface)
 This program is distributed under the terms of the GNU General Public License.

 This file is part of xFace.

 xFace is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 xFace is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with xFace.  If not, see <http://www.gnu.org/licenses/>.
*/

//
//  XInstallListenerStub.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>
#import "XInstallListener.h"

/**
    用于监听app安装、卸载的单元测试桩
 */
@interface XInstallListenerStub : NSObject <XInstallListener>

/**
    与当前被操作的app关联的id
 */
@property (strong, nonatomic) NSString *applicationId;

/**
    标识当前操作类型
 */
@property (nonatomic) OPERATION_TYPE operationType;

/**
    进度状态码
 */
@property (nonatomic) PROGRESS_STATUS status;

/**
    应用安装、更新、卸载过程中的错误码
 */
@property (nonatomic) AMS_ERROR amsError;

/**
    onProgressUpdated被调用
 */
@property (nonatomic) BOOL isOnProgressUpdatedInvoked;

/**
    onSuccess被调用
 */
@property (nonatomic) BOOL isOnSuccessInvoked;

/**
    onError被调用
 */
@property (nonatomic) BOOL isOnErrorInvoked;

/**
    重置数据、状态码
 */
- (void)reset;

@end
