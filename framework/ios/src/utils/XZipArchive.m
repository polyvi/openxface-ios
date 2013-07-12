
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
//  XZipArchive.m
//  xFace
//
//

#import "XZipArchive.h"

#define FILE_IN_ZIP_MAX_NAME_LENGTH (256)

@implementation ZipArchive (XZipArchive)

- (BOOL) locateFileInZip:(NSString *)fileNameInZip
{
    BOOL ret = NO;

    int err = unzLocateFile(_unzFile, [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding], 1);
    if (UNZ_END_OF_LIST_OF_FILE == err)
    {
        return ret;
    }

    ret = (UNZ_OK == err);
    if (!ret)
    {
        XLogE(@"Error in locating the file in zip");
    }
    return ret;
}

- (NSData *) readCurrentFileInZip
{
    char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
    unz_file_info file_info;

    int err = unzGetCurrentFileInfo(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
    if (UNZ_OK != err)
    {
        XLogE(@"Error in getting current file info");
        return nil;
    }

    // 打开当前文件
    err = unzOpenCurrentFilePassword(_unzFile, NULL);
    if (UNZ_OK != err)
    {
        XLogE(@"Error in opening current file");
        return nil;
    }

    NSString *fileNameInZip = [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];
    NSUInteger fileUncompressedSize = file_info.uncompressed_size;
    NSMutableData *data = [NSMutableData dataWithLength:fileUncompressedSize];

    // 读取当前文件数据
    int bytes = unzReadCurrentFile(_unzFile, [data mutableBytes], [data length]);
    if (bytes < 0)
    {
        XLogE(@"Error in reading '%@' in zip", fileNameInZip);
        return nil;
    }
    [data setLength:bytes];

    // 关闭当前文件
    err = unzCloseCurrentFile(_unzFile);
    if (UNZ_OK != err)
    {
        XLogE(@"Error in  closing '%@' in zip", fileNameInZip);
    }

    return data;
}

@end
