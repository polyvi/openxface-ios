
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
//  XInstallListener.h
//  xFace
//
//

#import <Foundation/Foundation.h>
#import "XAmsConstants.h"

/**
	负责应用安装、卸载进度及状态通知
 */
@protocol XInstallListener <NSObject>

/**
	更新安装进度
	@param type           操作类型：INSTALL  UNINSTALL
	@param progressStatus 进度状态码
 */
- (void) onProgressUpdated:(OPERATION_TYPE)type withStatus:(PROGRESS_STATUS)progressStatus;

/**
	操作执行成功
	@param type  操作类型：INSTALL  UNINSTALL
	@param appId 与app对应的id
 */
- (void) onSuccess:(OPERATION_TYPE)type withAppId:(NSString *)appId;

/**
	操作执行失败
	@param type  操作类型：INSTALL  UNINSTALL
	@param appId 与app对应的id
	@param error 错误码
 */
- (void) onError:(OPERATION_TYPE)type withAppId:(NSString *)appId withError:(AMS_ERROR)error;

@end
