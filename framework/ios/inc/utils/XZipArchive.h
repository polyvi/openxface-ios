
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
//  XZipArchive.h
//  xFace
//
//

#import "ZipArchive.h"

/**
	定义XZipArchive category.
	为ZipArchive添加新方法，以获取压缩包内指定的文件内容
 */
@interface ZipArchive (XZipArchive)

/**
	定位压缩包内的指定文件.
	该方法执行成功时，表明在压缩包内找到指定文件，且已经将指定文件变为当前文件.
	@param fileNameInZip 待定位的文件名称
	@returns 如果在压缩包内找到指定文件，返回YES,否则返回NO
 */
- (BOOL) locateFileInZip:(NSString *)fileNameInZip;

/**
	读取压缩包中当前文件的全部数据.
	@returns 成功时返回读取到的文件数据,失败时返回nil
 */
- (NSData *) readCurrentFileInZip;

@end
