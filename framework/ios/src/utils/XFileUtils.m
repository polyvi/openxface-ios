
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
//  XFileUtils.m
//  xFaceLib
//
//

#import "XFileUtils.h"
#import "XConstants.h"
#import "XConfiguration.h"
#import "XUtils.h"

#define TEMPORARY_NAME                @"tmp"

@implementation XFileUtils

+ (NSDictionary *)getEntry:(NSString *)path usingWorkspace:(NSString*)workSpace isDir:(BOOL)isDir
{
    NSMutableDictionary* dirEntry = [NSMutableDictionary dictionaryWithCapacity:4];

    [dirEntry setObject:[NSNumber numberWithBool: !isDir]  forKey:@"isFile"];
    [dirEntry setObject:[NSNumber numberWithBool: isDir]  forKey:@"isDirectory"];

    NSString* lastPart = nil;
    if ([path isEqualToString:workSpace])
    {
        lastPart = FILE_SEPARATOR;
        path = FILE_SEPARATOR;
    }
    else
    {
        NSUInteger worhSpaceLen = [workSpace length];
        path = [path substringFromIndex:worhSpaceLen];
        lastPart = [path lastPathComponent];
    }
    [dirEntry setObject: path forKey:@"fullPath"];
    [dirEntry setObject: lastPart forKey:@"name"];

    return dirEntry;
}

+ (NSMutableDictionary*) createFileTransferError:(int)code andSource:(NSString*)source andTarget:(NSString*)target
{
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:3];
    [result setObject:[NSNumber numberWithInt:code] forKey:@"code"];
    [result setObject:source forKey:@"source"];
    [result setObject:target forKey:@"target"];
    XLogE(@"FileTransferError %@", result);

    return result;
}

+ (BOOL)removeContentOfDirectoryAtPath:(NSString *)path error:(NSError **)error
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:path];
    NSString *fileName = nil;
    BOOL ret = YES;

    while ((fileName = [directoryEnumerator nextObject]))
    {
        NSString* filePath = [path stringByAppendingPathComponent:fileName];
        ret = [fileMgr removeItemAtPath:filePath error:error];
        if (!ret && error)
        {
            XLogE(@"Failed to delete: %@ (error: %@)", filePath, [*error localizedDescription]);
            return ret;
        }
    }
    return ret;
}

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error
{
    BOOL ret = YES;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:path])
    {
        CAST_TO_POINTER_TO_NSERROR_IF_NIL(error);

        ret = [fileMgr removeItemAtPath:path error:error];
        if(!ret && error)
        {
            XLogE(@"[%@] Failed to remove item at path: %@ (error: %@)", NSStringFromSelector(_cmd), path, [*error localizedDescription]);
        }
    }

    return ret;
}

+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error
{
    BOOL ret = NO;
    if ( (![srcPath length]) || (![dstPath length]) )
    {
        XLogE(@"[%@] Failed to move item due to srcPath or dstPath is nil!", NSStringFromSelector(_cmd));
        return ret;
    }

    NSFileManager* fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:srcPath])
    {
        XLogD(@"[%@] Failed to move item due to src file or directory is non-existent!", NSStringFromSelector(_cmd));
        return ret;
    }

    // 确保destination item不存在，否则执行moveItem时将失败（Cocoa error 516）
    CAST_TO_POINTER_TO_NSERROR_IF_NIL(error);
    [XFileUtils removeItemAtPath:dstPath error:error];

    NSString *parentDir = [dstPath stringByDeletingLastPathComponent];
    if (![fileMgr fileExistsAtPath:parentDir])
    {
        // 保证parent目录存在，否则执行moveItem时将失败（Cocoa error 4）
        ret = [fileMgr createDirectoryAtPath:parentDir withIntermediateDirectories:YES attributes:nil error:error];
        if(!ret && error)
        {
            XLogE(@"[%@] Failed to create directory at path:%@ with error:%@", NSStringFromSelector(_cmd), dstPath, [*error localizedDescription]);
            return ret;
        }
    }

    ret = [fileMgr moveItemAtPath:srcPath toPath:dstPath error:error];
    if(!ret && error)
    {
        XLogE(@"[%@] Failed to move item at path:%@ to path:%@ with error:%@", NSStringFromSelector(_cmd), srcPath, dstPath, [*error localizedDescription]);
    }
    return ret;
}

+ (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error
{
    // NOTE:与moveItemAtPath:toPath有重复代码，出现第三次时考虑重构
    BOOL ret = NO;
    if ( (![srcPath length]) || (![dstPath length]) )
    {
        XLogE(@"[%@] Failed to move item due to srcPath or dstPath is nil!", NSStringFromSelector(_cmd));
        return ret;
    }

    NSFileManager* fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:srcPath])
    {
        XLogD(@"[%@] Failed to move item due to src file or directory is non-existent!", NSStringFromSelector(_cmd));
        return ret;
    }

    // 确保destination item不存在，否则执行copyItem时将失败（Cocoa error 516）
    CAST_TO_POINTER_TO_NSERROR_IF_NIL(error);
    [XFileUtils removeItemAtPath:dstPath error:error];

    NSString *parentDir = [dstPath stringByDeletingLastPathComponent];
    if (![fileMgr fileExistsAtPath:parentDir])
    {
        // 保证parent目录存在，否则执行copyItem时将失败（Cocoa error 4）
        ret = [fileMgr createDirectoryAtPath:parentDir withIntermediateDirectories:YES attributes:nil error:error];
        if(!ret && error)
        {
            XLogE(@"[%@] Failed to create directory at path:%@ with error:%@", NSStringFromSelector(_cmd), dstPath, [*error localizedDescription]);
            return ret;
        }
    }

    ret = [fileMgr copyItemAtPath:srcPath toPath:dstPath error:error];
    if(!ret && error)
    {
        XLogE(@"[%@] Failed to copy item at path:%@ to path:%@ with error:%@", NSStringFromSelector(_cmd), srcPath, dstPath, [*error localizedDescription]);
    }
    return ret;
}

+ (BOOL) createFolder:(NSString*)fullPath
{
    BOOL result = NO;
    NSString* path = fullPath;
    //文件应该有相应的文件名扩展,没有则处理成文件夹
    if([[path pathExtension] length] >0 )
    {
        //去掉filename
        path = [path stringByDeletingLastPathComponent];
    }
    NSFileManager* fileMrg = [NSFileManager defaultManager];
    result = [fileMrg createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return result;
}

+ (BOOL) copyFileRecursively:(NSString *)srcPath toPath:destPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    __autoreleasing NSError *error = nil;
    BOOL destIsDir = NO;
    BOOL srcIsDir = NO;
    if([fileManager fileExistsAtPath:destPath isDirectory:&destIsDir])
    {
        [fileManager fileExistsAtPath:srcPath isDirectory:&srcIsDir];
        if(destIsDir && srcIsDir)
        {
            NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:srcPath];
            NSString *file = nil;
            while((file = [enumerator nextObject]) != nil)
            {
                NSString *nextSrcPath = [srcPath stringByAppendingPathComponent:file];
                NSString *nextDestPath = [destPath stringByAppendingPathComponent:file];
                if(![self copyFileRecursively:nextSrcPath toPath:nextDestPath])
                {
                    return NO;
                }
            }
            return YES;
        }
        else if(![fileManager removeItemAtPath:destPath error:&error])
        {
            XLogE(@"Remove file item: %@ failed, info: %@!", destPath, [error localizedDescription]);
            return NO;
        }
    }

    if(![fileManager copyItemAtPath:srcPath toPath:destPath error:&error])
    {
        XLogE(@"Copy file item: %@ failed, info: %@!", destPath, [error localizedDescription]);
        return NO;
    }
    return YES;
}

+ (NSString *)createTemporaryDirectory:(NSString *)parent
{
    NSString *tmpDirName = [NSString stringWithFormat: @"%.0f%d%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, [XUtils generateRandomId], TEMPORARY_NAME];

    parent = [parent length] ? parent : NSTemporaryDirectory();

    NSString *tmpDirPath = [parent stringByAppendingPathComponent:tmpDirName];

    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSAssert(![fileMgr fileExistsAtPath:tmpDirPath], nil);

    __autoreleasing NSError *error = nil;
    BOOL ret = [fileMgr createDirectoryAtPath:tmpDirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if(!ret && error)
    {
        XLogE(@"[%@] Failed to create directory at path:%@ with error:%@", NSStringFromSelector(_cmd), tmpDirPath, [error localizedDescription]);
    }

    return ret ? tmpDirPath : nil;
}

@end
