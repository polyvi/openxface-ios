
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
//  XFileExt.m
//  xFace
//
//

#ifdef __XFileExt__

#import "XFileExt.h"
#import "XExtensionResult.h"
#import "XFile.h"
#import "XJavaScriptEvaluator.h"
#import "XQueuedMutableArray.h"
#import "XApplication.h"
#import "XUtils.h"
#import "XExtendedDictionary.h"
#import "XJsCallback.h"

@interface XFileExt()

/**
    文件系统接口的实现者.
*/
@property (nonatomic, strong) XFile *worker;


@end

@implementation XFileExt

@synthesize worker;

- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = (XFileExt *) [super initWithMsgHandler:msgHandler];
    if (self)
    {
        self.worker = [[XFile alloc] init];
    }

    return self;
}

#pragma mark File implementations

- (void) write:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 3, callback)

    // arguments
    NSString* filePath = [arguments objectAtIndex:0];
    NSString* argData = [arguments objectAtIndex:1];
    unsigned long long pos = (unsigned long long)[[ arguments objectAtIndex:2] longLongValue];
    id<XApplication> app = [self getApplication:options];
    NSString* workSpace = [app getWorkspace];

    XExtensionResult* result = nil;
    XFileError error = NO_ERROR;

    [worker truncateFile:workSpace filePath:filePath atPosition:pos error:&error];

    int bytesWritten = [worker writeToFile:workSpace filePath:filePath withData:argData append:YES error:&error];
    if(bytesWritten >= 0)
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsInt:bytesWritten];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) truncate:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XExtensionResult* result = nil;
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 2, callback);

    NSString* filePath = [arguments objectAtIndex:0];
    if([[arguments objectAtIndex:1] longLongValue] < 0)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:TYPE_MISMATCH_ERR];
        [callback setExtensionResult:result];
        [self sendAsyncResult:callback];
        return;
    }
    unsigned long long pos = (unsigned long long)[[arguments objectAtIndex:1] longLongValue];
    id<XApplication> app = [self getApplication:options];
    NSString* workSpace = [app getWorkspace];

    XFileError error = NO_ERROR;

    unsigned long long newPos = [worker truncateFile:workSpace filePath:filePath atPosition:pos error:&error];
    if(NO_ERROR != error)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsInt:newPos];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) getFile:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 3, callback)

    NSString* dirPath = [arguments objectAtIndex:0];
    NSString* filePath = [arguments objectAtIndex:1];
    NSDictionary *jsOptions = [arguments objectAtIndex:2 withDefault:nil];

    id<XApplication> app = [self getApplication:options];
    NSString* workSpace = [app getWorkspace];

    BOOL create = NO;
    BOOL exclusive = NO;
    BOOL isDir = NO;

    XExtensionResult* result = nil;
    XFileError error = NO_ERROR;

    if ([jsOptions valueForKeyIsNumber:@"create"])
    {
        create = [[jsOptions valueForKey: @"create"] boolValue];
    }
    if ([jsOptions valueForKeyIsNumber:@"exclusive"])
    {
        exclusive = [[jsOptions valueForKey: @"exclusive"] boolValue];
    }

    if ([jsOptions valueForKeyIsNumber:@"getDir"])
    {
        //只获取文件时"getDir"是不存在的，当获取目录时会调用该方法
        isDir = [[jsOptions valueForKey: @"getDir"] boolValue];
    }

    NSDictionary* entry = [worker getFile:workSpace dirPath:dirPath filePath:filePath
                                   create:create exclusive:exclusive isDir:isDir error:&error];
    if(!entry || NO_ERROR != error)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:entry];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) getDirectory:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSMutableDictionary* jsOptions = nil;

    if ([arguments count] >= 3)
    {
        jsOptions = [arguments objectAtIndex:2 withDefault:nil];
    }
    // add getDir to options and call getFile()
    if (jsOptions != nil)
    {
        jsOptions = [NSMutableDictionary dictionaryWithDictionary:jsOptions];
    }
    else
    {
        jsOptions = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [jsOptions setObject:[NSNumber numberWithInt:1] forKey:@"getDir"];
    if ([arguments count] >= 3)
    {
        [arguments replaceObjectAtIndex:2 withObject:jsOptions];
    }
    else
    {
        [arguments addObject:jsOptions];
    }
    [self getFile:arguments withDict:options];
}

- (void) getFileMetadata:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 1, callback)

    NSString* filePath = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    NSString* workSpace = [app getWorkspace];

    XExtensionResult* result = nil;

    NSString* fullPath = [XUtils resolvePath:filePath usingWorkspace:workSpace];
    if (!fullPath) {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:INVALID_MODIFICATION_ERR];
    }
    else
    {
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        BOOL isDir = NO;
        BOOL exists = [fileMgr fileExistsAtPath:fullPath isDirectory:&isDir];
        if(!exists || isDir)
        {
            result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt: NOT_FOUND_ERR];
        }
        else
        {
            NSError* __autoreleasing error = nil;
            NSDictionary* fileAttrs = [fileMgr attributesOfItemAtPath:fullPath error:&error];
            NSMutableDictionary* fileInfo = [NSMutableDictionary dictionaryWithCapacity:5];
            [fileInfo setObject:[NSNumber numberWithUnsignedLongLong:[fileAttrs fileSize]] forKey:@"size"];
            [fileInfo setObject:filePath forKey:@"fullPath"];
            [fileInfo setObject:@"" forKey:@"type"]; //TODO:获取文件的类型比较复杂，现在先没有实现
            [fileInfo setObject:[filePath lastPathComponent] forKey:@"name"];
            NSDate* modDate = [fileAttrs fileModificationDate];
            NSNumber* msDate = [NSNumber numberWithDouble:[modDate timeIntervalSince1970] * 1000];
            [fileInfo setObject:msDate forKey:@"lastModifiedDate"];

            result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject: fileInfo];
        }
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) copyTo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 3, callback);

    NSString* oldPath = [arguments objectAtIndex:0];
    NSString* newParentPath = [arguments objectAtIndex:1];
    NSString* newName = [arguments objectAtIndex:2];
    id<XApplication> app = [self getApplication:options];
    NSString* workspace = [app getWorkspace];
    XFileError error = NO_ERROR;

    XExtensionResult* result = nil;
    NSDictionary* entry = [worker transferTo:workspace oldPath:oldPath newParentPath:newParentPath
                                     newName:newName isCopy:YES error:&error];
    if(!entry || NO_ERROR != error)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:entry];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) moveTo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 3, callback);

    NSString* oldPath = [arguments objectAtIndex:0];
    NSString* newParentPath = [arguments objectAtIndex:1];
    NSString* newName = [arguments objectAtIndex:2];
    id<XApplication> app = [self getApplication:options];
    NSString* workspace = [app getWorkspace];
    XFileError error = NO_ERROR;

    XExtensionResult* result = nil;
    NSDictionary* entry = [worker transferTo:workspace oldPath:oldPath newParentPath:newParentPath
                                     newName:newName isCopy:NO error:&error];
    if(!entry || NO_ERROR != error)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:entry];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) remove:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 1, callback);

    NSString* filePath = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    NSString* workspace = [app getWorkspace];
    XFileError error = NO_ERROR;

    XExtensionResult* result = nil;

    BOOL removeSuccess = [worker remove:workspace filePath:filePath error:&error];
    if (!removeSuccess || NO_ERROR != error)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) getParent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 1, callback);

    NSString* filePath = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    NSString* workspace = [app getWorkspace];
    XFileError error = NO_ERROR;
    NSDictionary* entry = nil;

    XExtensionResult* result = nil;

    entry = [worker getParent:workspace filePath:filePath error:&error];
    if (!entry || NO_ERROR != error)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:entry];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) removeRecursively:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 1, callback);

    NSString* filePath = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    NSString* workspace = [app getWorkspace];
    XFileError error = NO_ERROR;
    BOOL removeSuccess = NO;

    XExtensionResult* result = nil;

    removeSuccess = [worker removeRecursively:workspace filePath:filePath error:&error];
    if(!removeSuccess || NO_ERROR != error)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) readAsText:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 2, callback);

    NSString* filePath = [arguments objectAtIndex:0];
    //FIXME:第二个参数是编码格式，目前我们这里没有用到，在IOS上我们目前采取都用UTF-8
    id<XApplication> app = [self getApplication:options];
    NSString* workspace = [app getWorkspace];
    XFileError error = NO_ERROR;

    XExtensionResult* result = nil;
    NSString* readData = [worker readAsText:workspace filePath:filePath error:&error];

    if(!readData || NO_ERROR != error)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:readData];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) readAsDataURL:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 1, callback);

    NSString* filePath = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    NSString* workspace = [app getWorkspace];
    XFileError error = NO_ERROR;

    NSString* readData = nil;
    XExtensionResult* result = nil;
    if(!filePath)
    {
        error = SYNTAX_ERR;
    }
    else
    {
        readData = [worker readAsDataURL:workspace filePath:filePath error:&error];
    }
    if(!readData || NO_ERROR != error)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:readData];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) readEntries:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 1, callback);

    NSString* filePath = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    NSString* workspace = [app getWorkspace];
    XFileError error = NO_ERROR;

    XExtensionResult* result = nil;
    NSMutableArray* entries = [worker readEntries:workspace filePath:filePath error:&error];

    if(!entries || NO_ERROR != error)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:entries];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) resolveLocalFileSystemURI:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 1, callback);

    NSString* fileURI = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    NSString* workspace = [app getWorkspace];
    XFileError error = NO_ERROR;

    XExtensionResult* result = nil;
    NSDictionary* entry = [worker resolveLocalFileSystemURI:workspace fileURI:fileURI error:&error];

    if(!entry || NO_ERROR != error)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:entry];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) getMetadata:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 1, callback);

    NSString* filePath = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    NSString* workspace = [app getWorkspace];
    XFileError error = NO_ERROR;
    NSDate* modDate = nil;

    XExtensionResult* result = nil;

    modDate = [worker getMetadata:workspace filePath:filePath error:&error];
    if(!modDate || NO_ERROR != error)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:error];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsDouble:[modDate timeIntervalSince1970] * 1000];
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) setMetadata:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 1, callback);

    NSString* filePath = [arguments objectAtIndex:0];
    NSDictionary* jsOptions = [arguments objectAtIndex:1 withDefault:nil];
    id<XApplication> app = [self getApplication:options];
    NSString* workspace = [app getWorkspace];
    NSString* fullPath = [XUtils resolvePath:filePath usingWorkspace:workspace];

    NSString* iCloudBackupExtendedAttributeKey = @"com.apple.MobileBackup";
    id iCloudBackupExtendedAttributeValue = [jsOptions objectForKey:iCloudBackupExtendedAttributeKey];

    XExtensionResult* result = nil;
    if([worker setMetadata:iCloudBackupExtendedAttributeValue filePath:fullPath])
    {
        result = [XExtensionResult resultWithStatus:STATUS_OK];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR];
    }
    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) requestFileSystem:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 2, callback)

    // arguments
    NSString* strType = [arguments objectAtIndex:0];
    unsigned long long size = [[arguments objectAtIndex:1] unsignedLongLongValue];
    id<XApplication> app = [self getApplication:options];

    NSString* workSpace = [app getWorkspace];
    int type = [strType intValue];
    XExtensionResult* result = nil;

    if (type > PERSISTENT)
    {
        result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsInt: NOT_FOUND_ERR];
        XLogW(@"iOS for xFace only supports TEMPORARY and PERSISTENT file systems");
    }
    else
    {
        XFileError error = NO_ERROR;
        NSMutableDictionary *fs = [worker requestFileSystem:size type:type usingWorkspace: workSpace error:&error];
        if (!fs || NO_ERROR != error)
        {
            result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsInt: error];
        }
        else
        {
            result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject: fs];
        }
    }

    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (BOOL) shouldExecuteInBackground:(NSString *)fullMethodName
{
    return YES;
}

@end

#endif
