
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
//  XZipArchiveExt_Privates.h
//  xFaceLib
//
//

#ifdef __XZipArchiveExt__

#import "XZipArchiveExt.h"

enum ZipError {
    FILE_NOT_EXIST = 1,
    COMPRESS_FILE_ERROR = 2,
    UNZIP_FILE_ERROR = 3,
    FILE_PATH_ERROR = 4,
    FILE_TYPE_ERROR = 5
};
typedef NSUInteger ZipError;

@class ZipArchive;
@interface XZipArchiveExt ()

/**
    将指定路径的文件压缩为zip文件,可采用密码方式（如果目标路径为空则压缩到当前目录）
    @param filePath 指定的文件的路径
    @param dstFilePath 指定的文件压缩的目标路径
    @param password 压缩采用的密码（可以为空,即不要密码）
    @return 返回压缩结果 YES表示成功,NO表示发生错误
 */
- (BOOL) compressFile:(NSString*)filePath To:(NSString*)dstFilePath withPassword:(NSString*)password;

/**
    将指定路径的多个文件或文件夹压缩为zip文件,可采用密码方式
    @param filePaths 指定的文件的路径
    @param dstZipFile 指定的文件压缩的目标路径
    @param password 压缩采用的密码（可以为空,即不要密码）
    @return 返回压缩结果 YES表示成功,NO表示发生错误
 */
- (BOOL) compressFiles:(NSMutableArray*)filePaths To:(NSString*)dstZipFile withPassword:(NSString*)password;

/**
    将指定路径的文件夹压缩为zip文件,可采用密码方式（如果目标路径为空则压缩到当前目录）
    @param folderPath 指定的文件夹的路径
    @param dstFilePath 指定的文件压缩的目标路径
    @param password 压缩采用的密码（可以为空,即不要密码）
    @return 返回压缩结果 YES表示成功,NO表示发生错误
 */
- (BOOL) compressFolder:(NSString*)folderPath To:(NSString*)dstFilePath withPassword:(NSString*)password;

/**
    将指定路径的zip文件解压到指定路径,可采用密码方式（如果目标路径为空则解压到当前目录）
    @param zipFilePath 指定的zip文件的路径
    @param dstFilePath 指定的zip文件解压的目标路径
    @param password 解压时的密码（可以为空,即不要密码）
    @return 返回压缩结果 YES表示成功,NO表示发生错误
 */
- (BOOL) unZipFile:(NSString*)zipFilePath To:(NSString*)dstFilePath withPassword:(NSString*)password;

/**
    将指定路径（filePath）的文件夹下的文件,通过遍历将所有文件加入到zip文件
    @param zipFilePath      指定的压缩目标zip文件的路径
    @param filePath         指定的被压缩的文件夹的路径
    @param rootFilePath     指定的被压缩的文件夹的根路径
    @param zip              ZipArchive 压缩处理对象
    @return 返回压缩结果 YES表示成功,NO表示发生错误
 */
- (BOOL)addFileToZip:(NSString*)zipFilePath useZipArchive:(ZipArchive*)zip atPath: (NSString *)filePath rootPath:(NSString *)rootFilePath;

/**
    取出当前压缩文件相对于压缩文件起始这一级的相对的fileName
    @param rootFilePath      待压缩文件的起始路径
    @param currentFilePath   当前正在处理的文件
    @return 返回压缩文件相对于zipfile 所在这一级的相对的fileName
 */
- (NSString*) getRelativeFileName:(NSString*)currentFilePath withRootFilePath:(NSString*)rootFilePath;

/**
    通过callback 发送错误信息
    @param errorMessage      zip操作中相关的错误码
    @param callback      XJsCallback对象
 */
- (void) sendErrorMessage:(int)errorMessage byCalllBack:(XJsCallback *)callback;

@end

#endif
