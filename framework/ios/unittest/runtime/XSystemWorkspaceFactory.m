
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
//  XSystemWorkspaceFactory.m
//  xFace
//
//

#import "XSystemWorkspaceFactory.h"
#import "XConstants.h"
#import "XUtils.h"

@implementation XSystemWorkspaceFactory

+ (NSString *)create
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];

    // 区别player与非player的系统工作空间，以隔离相关配置，避免互相覆盖数据，影响程序正常运行
    // player的系统工作空间路径形如：<Applilcation_Home>/Documents/xface_player_test/
    // 非player的系统工作空间路径形如：<Applilcation_Home>/Documents/xface3_test/

    BOOL isPlayerUsed = [XUtils isPlayer];
    NSString *workspaceName = isPlayerUsed ? XFACE_PLAYER_WORKSPACE :  XFACE_WORKSPACE_FOLDER ;
    workspaceName = [workspaceName stringByAppendingString:@"_test"];
    return [documentDirectory stringByAppendingFormat:@"%@%@%@", FILE_SEPARATOR, workspaceName, FILE_SEPARATOR];
}

@end
