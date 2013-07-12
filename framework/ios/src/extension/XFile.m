
/*
 This file was modified from or inspired by Apache Cordova.

 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.
*/

//
//  XFile.m
//  xFace
//
//

#ifdef __XFileExt__

#import "XFile.h"
#import "XConfiguration.h"
#import "XUtils.h"
#import "XConstants.h"
#import "XBase64Data.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "XFileUtils.h"
#import "sys/xattr.h"
#import <UIKit/UIKit.h>

@interface XFile()

/**
    检查指定路径下剩余空间的容量
    @param path 待查询的路径
    @returns 空闲空间容量值
 */
- (NSNumber*) checkFreeDiskSpace: (NSString*) path;

/**
    判断是否允许将指定文件（夹）复制或者移动到目的文件夹
    @param src 源文件（夹）指定路径
    @param dest 目的文件夹路径
    @returns 允许返回YES，否则返回NO
 */
- (BOOL) canTransferSrc:(NSString*)src ToDestination:(NSString*)dest;

/**
    获取文件的mimeType
    @param fullPath 文件路径
    @returns 文件的类型
 */
- (NSString*) getMimeTypeFromPath: (NSString*) fullPath;

@end

#define EXTENSION_FILE_SYSTEM_NAME_TEMPORARY     @"temporary"
#define EXTENSION_FILE_SYSTEM_NAME_PERSISTENT    @"persistent"

@implementation XFile


- (id) init
{
    self = [super init];

    return self;
}

- (NSMutableDictionary *)requestFileSystem:(unsigned long long)size type:(XFileSystemType)theType usingWorkspace:(NSString*)workSpace error:(XFileError *)outputError
{
    *outputError = NO_ERROR;
    NSMutableDictionary* fileSystem = nil;
    NSNumber* availSpace = [self checkFreeDiskSpace:workSpace];
    if (availSpace && [availSpace unsignedLongLongValue] < size)
    {
        *outputError = QUOTA_EXCEEDED_ERR;
    }
    else
    {
        fileSystem = [NSMutableDictionary dictionaryWithCapacity:2];
        // FIXME: 区分temporary和persistent空间
        [fileSystem setObject: (TEMPORARY == theType ? EXTENSION_FILE_SYSTEM_NAME_TEMPORARY : EXTENSION_FILE_SYSTEM_NAME_PERSISTENT)forKey:@"name"];
        NSDictionary* dirEntry = [XFileUtils getEntry:workSpace usingWorkspace:workSpace isDir:YES];
        [fileSystem setObject:dirEntry forKey:@"root"];
    }

    return fileSystem;
}

- (NSDictionary *) getFile: (NSString*)workSpace dirPath:(NSString*)dirPath
                     filePath:(NSString*)filePath create:(BOOL)create exclusive:(BOOL)exclusive
                     isDir:(BOOL)isDir error:(XFileError *)outputError;
{
    *outputError = NO_ERROR;
    NSDictionary* entry = nil;
    NSString* reqFullPath = nil;

    NSString *dirFullPath = [XUtils resolvePath:dirPath usingWorkspace:workSpace];
    if (!dirFullPath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return entry;
    }
    else
    {
        reqFullPath = [XUtils resolvePath:filePath usingWorkspace:dirFullPath];
        if (!reqFullPath)
        {
            *outputError = INVALID_MODIFICATION_ERR;
            return entry;
        }
    }
    //FIXME：这里只检查了文件名中的不合法字符“：”，是否应该检查其他的不合法字符
    if ([filePath rangeOfString: @":"].location != NSNotFound)
    {
        *outputError = ENCODING_ERR;
    }
    else
    {
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        BOOL isDirectory;
        BOOL exists = [fileMgr fileExistsAtPath:reqFullPath isDirectory:&isDirectory];
        if (exists && create == NO && isDirectory == !isDir)
        {
            *outputError = TYPE_MISMATCH_ERR;
        }
        else if (!exists && create == NO)
        {
            *outputError = NOT_FOUND_ERR;
        }
        else if (exists && create == YES && exclusive == YES)
        {
            *outputError = PATH_EXISTS_ERR;
        }
        else
        {
            BOOL success = YES;
            NSError* __autoreleasing error = nil;
            if(!exists && create == YES)
            {
                if(isDir)
                {
                    // 创建目录
                    success = [fileMgr createDirectoryAtPath:reqFullPath withIntermediateDirectories:NO attributes:nil error:&error];
                }
                else
                {
                    // 创建空文件
                    success = [fileMgr createFileAtPath:reqFullPath contents:nil attributes:nil];
                }
            }
            if(!success)
            {
                *outputError = ABORT_ERR;
                if (error)
                {
                    XLogE(@"error creating directory: %@", [error localizedDescription]);
                }
            }
            else
            {
                entry = [XFileUtils getEntry:reqFullPath usingWorkspace:workSpace isDir:isDir];
            }
        }
    }

	return entry;
}

- (unsigned long long) truncateFile:(NSString*)workSpace filePath:(NSString*)filePath
                         atPosition:(unsigned long long)pos error:(XFileError *)outputError
{
    *outputError = NO_ERROR;
    unsigned long long newPos = 0UL;
    filePath = [XUtils resolvePath:filePath usingWorkspace:workSpace];
    if (!filePath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return newPos;
    }
    NSFileHandle* file = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if(file)
    {
        //当pos的大小超过文件的大小时，取文件的长度
        unsigned long long fileLength = [file seekToEndOfFile];
        if(pos > fileLength)
        {
            newPos = fileLength;
        }
        else
        {
            [file truncateFileAtOffset:pos];
            newPos = [file offsetInFile];
            [file synchronizeFile];
            [file closeFile];
        }
    }
    return newPos;
}

- (int) writeToFile:(NSString*)workSpace filePath:(NSString*)filePath withData:(NSString*)data
              append:(BOOL)shouldAppend error:(XFileError *)outputError
{
    *outputError = INVALID_MODIFICATION_ERR;
    int bytesWritten = -1;
    NSData* encData = [data dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    filePath = [XUtils resolvePath:filePath usingWorkspace:workSpace];
    if (!filePath)
    {
        return bytesWritten;
    }
    if (filePath)
    {
        NSOutputStream* fileStream = [NSOutputStream outputStreamToFileAtPath:filePath append:shouldAppend];
        if (fileStream)
        {
            NSUInteger len = [encData length];
            [fileStream open];
            bytesWritten = [fileStream write:[encData bytes] maxLength:len];
            [fileStream close];
        }
    }
    else
    {
        *outputError = NOT_FOUND_ERR;
    }
    return bytesWritten;

}

- (BOOL) remove:(NSString *)workSpace filePath:(NSString *)filePath error:(XFileError *)outputError
{
    *outputError = NO_ERROR;
    BOOL removeSuccess = NO;
    NSString* fullPath = [XUtils resolvePath:filePath usingWorkspace:workSpace];
    if(!fullPath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return removeSuccess;
    }
    if([fullPath isEqualToString:workSpace])
    {
        *outputError = NO_MODIFICATION_ALLOWED_ERR;
        return removeSuccess;
    }

    NSFileManager* fileMgr = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL exists = [fileMgr fileExistsAtPath:fullPath isDirectory: &isDir];
    if (!exists)
    {
        *outputError = NOT_FOUND_ERR;
        return removeSuccess;
    }
    if (isDir && [[fileMgr contentsOfDirectoryAtPath:fullPath error:nil] count] != 0)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return removeSuccess;
    }
    NSError* __autoreleasing error = nil;
    removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
    if (!removeSuccess)
    {
        *outputError = ABORT_ERR;
        XLogE(@"error getting metadata: %@", [error localizedDescription]);
        if ([error code] == NSFileNoSuchFileError)
        {
            *outputError = NOT_FOUND_ERR;
        }
        else if ([error code] == NSFileWriteNoPermissionError)
        {
            *outputError = NO_MODIFICATION_ALLOWED_ERR;
        }
    }
    return removeSuccess;

}

- (NSDictionary*) transferTo:(NSString*)workSpace oldPath:(NSString*)oldPath newParentPath:(NSString*)newParentPath
            newName:(NSString*)newName isCopy:(BOOL)isCopy error:(XFileError*)outputError
{
    *outputError = NO_ERROR;
    NSDictionary* entry = nil;

    //判断源路径是否在app的工作空间下
    NSString* srcFullPath = [XUtils resolvePath:oldPath usingWorkspace:workSpace];
    if(!srcFullPath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return entry;
    }

    //判断目的文件夹路径是否在app的工作空间下
    NSString* destRootPath = [XUtils resolvePath:newParentPath usingWorkspace:workSpace];
    if(!destRootPath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return entry;
    }

    //判断新文件名是否含有不合法字符
    if ([newName rangeOfString:@":"].location != NSNotFound)
    {
        *outputError = ENCODING_ERR;
        return entry;
	}

    //判断新文件（夹）路径是否在app的工作空间下
    NSString* newFullPath = [XUtils resolvePath:newName usingWorkspace:destRootPath];
    if (!newFullPath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return entry;
    }
    //判断新路径是否和源路径相同
    if ([newFullPath isEqualToString:srcFullPath])
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return entry;
    }

    NSFileManager* fileMgr = [NSFileManager defaultManager];

    BOOL srcIsDir = NO;
    BOOL destIsDir = NO;
    BOOL newIsDir = NO;
    BOOL srcExists = [fileMgr fileExistsAtPath:srcFullPath isDirectory:&srcIsDir];
    BOOL destExists= [fileMgr fileExistsAtPath:destRootPath isDirectory:&destIsDir];
    BOOL newExists = [fileMgr fileExistsAtPath:newFullPath isDirectory:&newIsDir];
    if (!srcExists || !destExists)
    {
        //源路径或者目的路径不存在
        *outputError = NOT_FOUND_ERR;
    }
    else if (srcIsDir && (newExists && !newIsDir))
    {
		//不能将目录复制或者移动成文件
        *outputError = INVALID_MODIFICATION_ERR;
    }
    else
    {
        NSError* __autoreleasing error = nil;
        BOOL transferSuccess = NO;

        if (isCopy)   //复制
        {
            if (srcIsDir && ![self canTransferSrc:srcFullPath ToDestination:newFullPath])
            {
                //复制给自己
                *outputError = INVALID_MODIFICATION_ERR;
                return entry;
            }
            else if (newExists)
            {
                *outputError = PATH_EXISTS_ERR;
                return entry;
            }
            else
            {
                transferSuccess = [fileMgr copyItemAtPath:srcFullPath toPath:newFullPath error:&error];
            }
        }
        else   //移动
        {
            if (!srcIsDir && (newExists && newIsDir))
            {
                // 不能将文件移动成为文件夹
                *outputError = INVALID_MODIFICATION_ERR;
                return entry;
            }
            else if (srcIsDir && ![self canTransferSrc:srcFullPath ToDestination:newFullPath])
            {
                *outputError = INVALID_MODIFICATION_ERR;
                return entry;
            }
            else if (newExists)
            {
                if (newIsDir && [[fileMgr contentsOfDirectoryAtPath:newFullPath error:&error] count] != 0)
                {
                    *outputError = INVALID_MODIFICATION_ERR;
                    return entry;
                }
                else
                {
                    transferSuccess = [fileMgr removeItemAtPath:newFullPath error:&error];
                }
            }
            else if (newIsDir && ![self canTransferSrc:srcFullPath ToDestination:newFullPath])
            {
                *outputError = INVALID_MODIFICATION_ERR;
                return entry;
            }
            transferSuccess = [fileMgr moveItemAtPath: srcFullPath toPath: newFullPath error: &error];

        }
        if (transferSuccess)
        {
            entry = [XFileUtils getEntry:newFullPath usingWorkspace:workSpace isDir:srcIsDir];
        }
        else
        {
            *outputError = INVALID_MODIFICATION_ERR;
            if (error)
            {
                if ([error code] == NSFileReadUnknownError || [error code] == NSFileReadTooLargeError)
                {
                    *outputError = NOT_READABLE_ERR;
                }
                else if ([error code] == NSFileWriteOutOfSpaceError)
                {
                    *outputError = QUOTA_EXCEEDED_ERR;
                }
                else if ([error code] == NSFileWriteNoPermissionError)
                {
                    *outputError = NO_MODIFICATION_ALLOWED_ERR;
                }
            }
        }
    }
    return entry;
}

- (NSDictionary*)getParent:(NSString *)workspace filePath:(NSString *)filePath error:(XFileError *)outputError
{
    *outputError = NO_ERROR;
    NSString* fullPath = [XUtils resolvePath:filePath usingWorkspace:workspace];
    NSDictionary* entry = nil;
    NSString* parentPath = nil;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    if(!fullPath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return entry;
    }
    if(![fileMgr fileExistsAtPath:fullPath])
    {
        *outputError = NOT_FOUND_ERR;
        return entry;
    }
    if([fullPath isEqualToString:workspace])
    {
        parentPath = fullPath;
    }
    else
    {
        NSRange range = [fullPath rangeOfString:FILE_SEPARATOR options:NSBackwardsSearch];
        parentPath = [fullPath substringToIndex:range.location];
    }
    if (parentPath)
    {
        BOOL isDir;
        BOOL exists = [fileMgr fileExistsAtPath: parentPath isDirectory: &isDir];
        if (exists)
        {
            entry = [XFileUtils getEntry:parentPath usingWorkspace:workspace isDir:isDir];
		}
        else
        {
            *outputError = NOT_FOUND_ERR;
        }
    }
    else
    {
        *outputError = NOT_FOUND_ERR;
    }
    return entry;
}

- (BOOL) removeRecursively:(NSString*)workspace filePath:(NSString*)filePath error:(XFileError*)outputError
{
    *outputError = NO_ERROR;
    NSString* fullPath = [XUtils resolvePath:filePath usingWorkspace:workspace];
    BOOL removeSuccess = NO;
    if(!fullPath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
    }
    else if([fullPath isEqualToString:workspace])
    {
        *outputError = NO_MODIFICATION_ALLOWED_ERR;
    }
    else
    {
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        NSError* __autoreleasing error = nil;
        removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
        if (!removeSuccess)
        {
            *outputError = ABORT_ERR;
            XLogE(@"error getting metadata: %@", [error localizedDescription]);
            if (NSFileNoSuchFileError == [error code])
            {
                *outputError = NOT_FOUND_ERR;
            }
            else if (NSFileWriteNoPermissionError == [error code])
            {
                *outputError = NO_MODIFICATION_ALLOWED_ERR;
            }
        }
    }
    return removeSuccess;
}

- (NSDate*) getMetadata:(NSString*)workspace filePath:(NSString*)filePath error:(XFileError*)outputError
{
    *outputError = NO_ERROR;
    NSString* fullPath = [XUtils resolvePath:filePath usingWorkspace:workspace];
    NSDate* modDate = nil;
    if(!fullPath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return modDate;
    }

    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSError* __autoreleasing error = nil;
    NSDictionary* fileAttribs = [fileMgr attributesOfItemAtPath:fullPath error:&error];
    if (fileAttribs)
    {
        modDate = [fileAttribs fileModificationDate];
    }
    else
    {
        *outputError = ABORT_ERR;
        XLogE(@"error getting metadata: %@", [error localizedDescription]);
        if (NSFileNoSuchFileError == [error code])
        {
            *outputError = NOT_FOUND_ERR;
        }
    }
    return modDate;
}

- (NSString*) readAsText:(NSString*)workspace filePath:(NSString*)filePath error:(XFileError*)outputError
{
    *outputError = NO_ERROR;
    NSString* fullPath = [XUtils resolvePath:filePath usingWorkspace:workspace];
    NSString* readData = nil;
    if(!fullPath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return readData;
    }

    NSError* __autoreleasing error = nil;
    readData = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    if (!readData)
    {
        *outputError = ABORT_ERR;
        if (NSFileReadNoSuchFileError == [error code])
        {
            *outputError = NOT_FOUND_ERR;
        }
    }
    return readData;
}
- (NSString*) readAsDataURL:(NSString*)workspace filePath:(NSString*)filePath error:(XFileError*)outputError
{
    *outputError = NO_ERROR;
    NSString* fullPath = [XUtils resolvePath:filePath usingWorkspace:workspace];
    NSString* readData = nil;
    if(!fullPath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return readData;
    }

    NSString* mimeType = [self getMimeTypeFromPath:fullPath];
    if (!mimeType)
    {
        *outputError = ENCODING_ERR;
    }
    else
    {
        NSFileHandle* file = [ NSFileHandle fileHandleForReadingAtPath:fullPath];
        NSData* data = [file readDataToEndOfFile];
        [file closeFile];
        if (data)
        {
            readData = [NSString stringWithFormat:@"data:%@;base64,%@", mimeType, [data base64EncodedString]];
        }
        else
        {
            *outputError = NOT_FOUND_ERR;
        }
	}
	return readData;
}

- (NSMutableArray*) readEntries:(NSString*)workspace filePath:(NSString*)filePath error:(XFileError*)outputError
{
    *outputError = NO_ERROR;
    NSString* fullPath = [XUtils resolvePath:filePath usingWorkspace:workspace];
    NSMutableArray* entries = nil;
    if(!fullPath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return entries;
    }

    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSError* __autoreleasing error = nil;
    NSArray* contents = [fileMgr contentsOfDirectoryAtPath:fullPath error:&error];
    if (contents)
    {
        entries = [NSMutableArray arrayWithCapacity:[contents count]];
        for (NSString* name in contents)
        {
            NSString* entryPath = [fullPath stringByAppendingPathComponent:name];
            BOOL isDir = NO;
            [fileMgr fileExistsAtPath:entryPath isDirectory: &isDir];
            NSDictionary* entryDict = [XFileUtils getEntry:entryPath usingWorkspace:workspace isDir:isDir];
            [entries addObject:entryDict];
        }
    }
    else
    {
        *outputError = NOT_FOUND_ERR;
    }
    return entries;
}

- (NSDictionary*) resolveLocalFileSystemURI:(NSString*)workspace fileURI:(NSString*)fileURI error:(XFileError*)outputError
{
    *outputError = NO_ERROR;
    NSDictionary* entry = nil;
    NSString* cleanUri = [fileURI stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* strUri = [cleanUri stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURL* newUri = [NSURL URLWithString:strUri];

    if (!newUri || ![newUri isFileURL])
    {
        *outputError = ENCODING_ERR;
        return entry;
    }

    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString* path = [newUri path];
    NSString* fullPath = [XUtils resolvePath:path usingWorkspace:workspace];

    if(!fullPath)
    {
        *outputError = INVALID_MODIFICATION_ERR;
        return entry;
    }

    BOOL isDir = NO;
    BOOL exists = [fileMgr fileExistsAtPath:fullPath isDirectory:&isDir];
    if (exists)
    {
        entry = [XFileUtils getEntry:fullPath usingWorkspace:workspace isDir:isDir];
    }
    else
    {
        *outputError = NOT_FOUND_ERR;
    }
    return entry;
}

- (BOOL) setMetadata:(id)metadataValue filePath:(NSString*)filePath
{
    if(!filePath)
    {
        return false;
    }

     NSString* iCloudBackupExtendedAttributeKey = @"com.apple.MobileBackup";
    if ((metadataValue != nil) && [metadataValue isKindOfClass:[NSNumber class]])
    {
        if (SYSTEM_VERSION_NOT_LOWER_THAN(@"5.1"))
        {
            NSURL* url = [NSURL fileURLWithPath:filePath];
            NSError* __autoreleasing error = nil;

            BOOL temp = [url setResourceValue:[NSNumber numberWithBool:[metadataValue boolValue]] forKey:NSURLIsExcludedFromBackupKey error:&error];
            if (error)
            {
                XLogE(@"setMetadata error %@ :", error);
            }
            return temp;
        }
        else
        {
            // below 5.1 (deprecated - only really supported in 5.01)
            u_int8_t value = [metadataValue intValue];
            if (value == 0)
            {
                // remove the attribute (allow backup, the default)
                return (removexattr([filePath fileSystemRepresentation], [iCloudBackupExtendedAttributeKey cStringUsingEncoding:NSUTF8StringEncoding], 0) == 0);
            }
            else
            {
                // set the attribute (skip backup)
                return (setxattr([filePath fileSystemRepresentation], [iCloudBackupExtendedAttributeKey cStringUsingEncoding:NSUTF8StringEncoding], &value, sizeof(value), 0, 0) == 0);
            }
        }
    }
    return false;
}

#pragma mark private implementations

- (NSNumber *)checkFreeDiskSpace:(NSString *)path
{
    NSFileManager* fMgr = [NSFileManager defaultManager];

    NSError* __autoreleasing error = nil;

    NSDictionary* pDict = [ fMgr attributesOfFileSystemForPath:path error:&error ];
    NSNumber* availSpace = (NSNumber*)[ pDict objectForKey:NSFileSystemFreeSize ];

    return availSpace;
}

-(BOOL) canTransferSrc:(NSString*)src ToDestination:(NSString*)dest
{
    // 复制 /Documents/myDir 到 /Documents/myDir-backup 是允许的，但是
    // 复制 /Documents/myDir 到 /Documents/myDir/backup 是不允许的

    if ([src isEqualToString:dest])
    {
        return NO;
    }
    if(![src hasSuffix:FILE_SEPARATOR])
    {
        src = [src stringByAppendingString:FILE_SEPARATOR];
    }
    return (![dest hasPrefix:src]);
}

- (NSString*) getMimeTypeFromPath: (NSString*) fullPath
{
    NSString* mimeType = nil;
    if(fullPath)
    {
        CFStringRef typeId = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)[fullPath pathExtension], nil);
        if (typeId)
        {
            mimeType = (__bridge NSString*)UTTypeCopyPreferredTagWithClass(typeId,kUTTagClassMIMEType);
            if (!mimeType)
            {
                if (NSNotFound != [(__bridge NSString*)typeId rangeOfString: @"m4a-audio"].location)
                {
                    mimeType = @"audio/mp4";
                }
                else if (NSNotFound != [[fullPath pathExtension] rangeOfString:@"wav"].location)
                {
                    mimeType = @"audio/wav";
                }
            }
            CFRelease(typeId);
        }
    }
    return mimeType;
}

@end

#endif
