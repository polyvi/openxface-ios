
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
//  XLightweightAppInstaller.h
//  xFaceLib
//
//

#import <UIKit/UIKit.h>
#import "XAppInstallerProtocol.h"

/**
    免解压过程的轻量应用安装器
 */
@interface XLightweightAppInstaller : NSObject <XAppInstallerProtocol>
{
    XAppList *appList;                          /**< 已安装应用列表 */
    XApplicationPersistence *appPersistence;    /**< 用于读写配置文件 */
}

@end
