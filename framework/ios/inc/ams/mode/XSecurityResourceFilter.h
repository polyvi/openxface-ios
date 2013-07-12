
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
//  XSecurityResourceFilter.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>

//Fileter of resources which need security check.
@protocol XSecurityResourceFilter <NSObject>

/**
   文件是否需要安全校验
   @param filePath 文件路径
   @returns 需要安检的文件类型返回YES， 其他返回NO。
 */
-(BOOL)accept:(NSString*)filePath;

@end
