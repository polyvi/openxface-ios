
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
//  XFileUtils.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>

enum XFileTransferError
{
    FILE_NOT_FOUND_ERR = 1,
    INVALID_URL_ERR = 2,
    CONNECTION_ERR = 3,
    CONNECTION_ABORTED = 4
};
typedef int XFileTransferError;

@interface XFileUtils : NSObject

/**
    获得代表指定路径(目录或文件)的信息
    @param path 指定路径
    @param workSpace 该应用的工作空间
    @param isDir 是否为目录
    @returns 存储了路径文件系统信息的数据
 */
+ (NSDictionary *) getEntry: (NSString *)path usingWorkspace:(NSString*)workSpace isDir: (BOOL) isDir;

/**
    产生FileTransfer错误信息对象.
    @param code 错误码,XFileTransferError中的一种（FILE_NOT_FOUND_ERR ,INVALID_URL_ERR,CONNECTION_ERR）
    @param source 源路径
    @param target 目的路径
    @returns 错误信息对象
 */
+ (NSMutableDictionary*) createFileTransferError:(int)code andSource:(NSString*)source andTarget:(NSString*)target;

/**
    移除指定目录下的所有内容
    @param path 待移除内容所在目录
    @param error 输出参数，错误码
    @returns 如果移除成功或path为nil则返回YES, 如果移除过程中发生错误则返回NO
 */
+ (BOOL)removeContentOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

/**
    移除指定路径的文件或目录
    此工具方法与FileManager提供的同名方法相比，区别在于移除item前会先判断item是否存在
    @param path 待移除文件或目录所在路径
    @param error 输出参数，错误码
    @returns 如果path为nil，或指定文件/目录不存在，或移除成功则返回YES, 如果移除过程中发生错误则返回NO
 */
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;

/**
    移动指定文件或目录到新位置
    此工具方法与FileManager提供的同名方法相比，区别在于当dstPath存在时，会先执行dstPath的删除操作
    @param srcPath 待移动文件或目录所在路径
    @param dstPath 目的路径
    @param error 输出参数，错误码
    @returns 如果移除成功返回YES, 否则返回NO
 */
+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error;

/**
    拷贝指定文件或目录到新位置
    此工具方法与FileManager提供的同名方法相比，区别在于当dstPath存在时，会先执行dstPath的删除操作
    @param srcPath 待拷贝文件或目录所在路径
    @param dstPath 目的路径
    @param error 输出参数，错误码
    @returns 如果拷贝成功返回YES, 否则返回NO
 */
+ (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error;

/**
    根据指定的路径创建文件夹
    @param Path      文件(夹)路径(完整路径)
        - 1)  fullPath 是文件: ~/workspace/foldernotexist/app.zip  <br />
        创建文件夹foldernotexist
        - 2)  path 是文件夹: ~/workspace/foldernotexist/foldernotexist1 或 ~/workspace/foldernotexist/foldernotexist1/
        依次创建文件夹foldernotexist、foldernotexist1
    @param workSpace      workSpace文件夹路径
    @returns 成功返回YES, 失败返回NO
 */
+ (BOOL) createFolder:(NSString*)fullPath;

/**
    递归的拷贝文件/目录到一个目标位置，如果目标路径存在则会进行覆写，不存在则
    创建对应的文件/目录
    @param srcPath 拷贝源路径，可以是文件或目录
    @param destPath 拷贝目标路径，用于指定拷贝的目标文件/目录路径
    @return 拷贝是否成功
 */
+ (BOOL) copyFileRecursively:(NSString *)srcPath toPath:destPath;

/**
    在parent下创建唯一的临时目录
    @param parent 临时目录所在的父目录，如果parent为空串，则在NSTemporaryDirectory下创建临时目录
    @returns 如果创建失败，返回nil,否则返回创建成功的临时目录
 */
+ (NSString *)createTemporaryDirectory:(NSString *)parent;

@end
