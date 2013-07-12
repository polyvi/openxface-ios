
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
//  XStoreProductPresenter.h
//  xFaceLib
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@class XAppInfo;

/**
    用于展示native app安装包下载界面
    iOS 6.0及其以上且appleID非空时：在当前app内展示native app安装包下载界面
    iOS 6.0以下或appleID为空时：跳转到App Store或其他应用展示native app安装包下载界面
 */
@interface XStoreProductPresenter : NSObject<SKStoreProductViewControllerDelegate>

/**
    获取XStoreProductPresenter唯一实例
    @returns 获取到的XStoreProductPresenter实例
 */
+ (XStoreProductPresenter *)getInstance;

/**
    展示native app安装包下载界面
    @param appInfo native app信息
    @returns 成功返回YES，失败返回NO
 */
- (BOOL)presentStoreProductWithAppInfo:(XAppInfo *)appInfo;

@end
