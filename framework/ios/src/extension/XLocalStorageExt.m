
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
//  XLocalStorageExt.m
//  xFaceLib
//
//

#import "XLocalStorageExt.h"
#import "XLocalStorageExt_Privates.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XJsCallback.h"
#import "XConstants.h"

@implementation XLocalStorageExt

@synthesize backupInfo;

- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if (self)
    {
        //Fixme:目前没有对点击power键进入后台进行处理，此时是否也需要进行数据的备份和恢复？？？
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResignActive)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];


        self.backupInfo = [self createBackupInfo];

        // TODO:根据backupType处理localstorage的备份问题
        if (SYSTEM_VERSION_NOT_LOWER_THAN(@"5.1"))
        {
            // verify the and fix the iOS 5.1 database locations once
            [self verifyAndFixDatabaseLocations];
            // 解决同步或系统升级 以前的localstorage丢失问题
            [self fixLegacyDatabaseLocationIssues];
        }

        [self restore:nil withDict:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Extension interface methods

- (NSMutableArray*)createBackupInfo
{
    NSString* appLibraryFolder = [NSSearchPathForDirectoriesInDomains (NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* cacheFolder = [appLibraryFolder stringByAppendingPathComponent:@"Caches"];
    NSString* backupsFolder = [appLibraryFolder stringByAppendingPathComponent:@"Backups"];

    // create the backups folder
    [[NSFileManager defaultManager] createDirectoryAtPath:backupsFolder withIntermediateDirectories:YES attributes:nil error:nil];

    return [self createBackupInfoWithTargetDir:cacheFolder backupDir:backupsFolder rename:YES];
}

- (BOOL) copyFrom:(NSString*)src to:(NSString*)dest error:(NSError**)error
{
    NSFileManager* fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:src])
    {
        NSString* errorString = [NSString stringWithFormat:@"%@ file does not exist.", src];
        if (error)
        {
            (*error) = [NSError errorWithDomain:kXLocalStorageErrorDomain
                                           code:kXLocalStorageFileOperationError
                                       userInfo:[NSDictionary dictionaryWithObject:errorString
                                         forKey:NSLocalizedDescriptionKey]];
        }
        return NO;
    }

    // generate unique filepath in temp directory
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    NSString* tempBackup = [[NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString*)uuidString] stringByAppendingPathExtension:@"bak"];
    CFRelease(uuidString);
    CFRelease(uuidRef);

    BOOL destExists = [fileManager fileExistsAtPath:dest];

    // backup the dest
    if (destExists && ![fileManager copyItemAtPath:dest toPath:tempBackup error:error])
    {
        return NO;
    }

    // remove the dest
    if (destExists && ![fileManager removeItemAtPath:dest error:error])
    {
        return NO;
    }

    // copy src to dest
    if ([fileManager copyItemAtPath:src toPath:dest error:error])
    {
        // success - cleanup - delete the backup to the dest
        if ([fileManager fileExistsAtPath:tempBackup])
        {
            [fileManager removeItemAtPath:tempBackup error:error];
        }
        return YES;
    }
    else
    {
        // failure - we restore the temp backup file to dest
        [fileManager copyItemAtPath:tempBackup toPath:dest error:error];
        // cleanup - delete the backup to the dest
        if ([fileManager fileExistsAtPath:tempBackup])
        {
            [fileManager removeItemAtPath:tempBackup error:error];
        }
        return NO;
    }
}

/* copy from webkitDbLocation to persistentDbLocation */
- (void) backup:(NSArray*)arguments withDict:(NSMutableDictionary*)options;
{
    __autoreleasing NSError* error = nil;
    NSString* message = nil;

    for (XBackupInfo* info in self.backupInfo)
    {
        //判断是否需要备份（当webkitDbLocation中的数据比persistentDbLocation中的新时需要备份）
        if ([info shouldBackup])
        {
            [self copyFrom:info.original to:info.backup error:&error];

            if (error == nil)
            {
                message = [NSString stringWithFormat:@"Backed up: %@", info.label];
                XLogI(@"%@", message);
            }
            else
            {
                message = [NSString stringWithFormat:@"Error in XLocalStorage (%@) backup: %@", info.label, [error localizedDescription]];
                XLogI(@"%@", message);
            }
        }
    }
}

/* copy from persistentDbLocation to webkitDbLocation */
- (void) restore:(NSArray*)arguments withDict:(NSMutableDictionary*)options;
{
    __autoreleasing NSError* error = nil;
    NSString* message = nil;

    for (XBackupInfo* info in self.backupInfo)
    {
        //判断是否需要恢复（当persistentDbLocation中的数据比webkitDbLocation中的新时需要恢复）
        if ([info shouldRestore])
        {
            [self copyFrom:info.backup to:info.original error:&error];

            if (error == nil)
            {
                message = [NSString stringWithFormat:@"Restored: %@", info.label];
                XLogI(@"%@", message);
            }
            else
            {
                message = [NSString stringWithFormat:@"Error in XLocalStorage (%@) restore: %@", info.label, [error localizedDescription]];
                XLogI(@"%@", message);
            }
        }
    }
}

- (void) verifyAndFixDatabaseLocations
{
    NSString* libraryCaches = @"Library/Caches";
    NSString* libraryWebKit = @"Library/WebKit";
    NSString* libraryPreferences = @"Library/Preferences";

    NSUserDefaults* appPreferences = [NSUserDefaults standardUserDefaults];
    NSBundle* mainBundle = [NSBundle mainBundle];

    NSString* bundlePath = [[mainBundle bundlePath] stringByDeletingLastPathComponent];
    NSString* bundleIdentifier = [[mainBundle infoDictionary] objectForKey:@"CFBundleIdentifier"];

    NSString* appPlistPath = [[bundlePath stringByAppendingPathComponent:libraryPreferences] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", bundleIdentifier]];
    NSMutableDictionary* appPlistDict = [NSMutableDictionary dictionaryWithContentsOfFile:appPlistPath];

    NSArray* keysToCheck = [NSArray arrayWithObjects:
                            @"WebKitLocalStorageDatabasePathPreferenceKey",
                            @"WebDatabaseDirectory",
                            nil];

    BOOL dirty = NO;

    for (NSString* key in keysToCheck)
    {
        NSString* value = [appPlistDict objectForKey:key];
        // verify key exists, and path is in app bundle, if not - fix
        if (value != nil && ![value hasPrefix:bundlePath])
        {
            // the pathSuffix to use may be wrong - OTA upgrades from < 5.1 to 5.1 do keep the old path Library/WebKit,
            // while Xcode synced ones do change the storage location to Library/Caches
            NSString* newBundlePath = [bundlePath stringByAppendingPathComponent:libraryCaches];
            if (![[NSFileManager defaultManager] fileExistsAtPath:newBundlePath])
            {
                newBundlePath = [bundlePath stringByAppendingPathComponent:libraryWebKit];
            }
            [appPlistDict setValue:newBundlePath forKey:key];
            dirty = YES;
        }
    }

    if (dirty)
    {
        BOOL ok = [appPlistDict writeToFile:appPlistPath atomically:YES];
        XLogI(@"Fix applied for database locations?: %@", ok? @"YES":@"NO");
        [appPreferences synchronize];
    }
}

- (NSMutableArray*) createBackupInfoWithTargetDir:(NSString*)targetDir backupDir:(NSString*)backupDir rename:(BOOL)rename
{
    NSMutableArray* backupInfos = [NSMutableArray arrayWithCapacity:3];

    NSString* original;
    NSString* backup;
    XBackupInfo* backupItem;

    //LOCALSTORAGE
    original = [targetDir stringByAppendingPathComponent:@"file__0.localstorage"];
    backup = [backupDir stringByAppendingPathComponent:rename ? @"localstorage.appdata.db":@"file__0.localstorage"];

    backupItem = [[XBackupInfo alloc] init];
    backupItem.backup = backup;
    backupItem.original = original;
    backupItem.label = @"localStorage database";

    [backupInfos addObject:backupItem];

    //WEBSQL MAIN DB
    original = [targetDir stringByAppendingPathComponent:@"Databases.db"];
    backup = [backupDir stringByAppendingPathComponent:rename ? @"websqlmain.appdata.db":@"Databases.db"];

    backupItem = [[XBackupInfo alloc] init];
    backupItem.backup = backup;
    backupItem.original = original;
    backupItem.label = @"websql main database";

    [backupInfos addObject:backupItem];

    //WEBSQL DATABASES
    original = [targetDir stringByAppendingPathComponent:@"file__0"];
    backup = [backupDir stringByAppendingPathComponent:rename ? @"websqldbs.appdata.db":@"file__0"];

    backupItem = [[XBackupInfo alloc] init];
    backupItem.backup = backup;
    backupItem.original = original;
    backupItem.label = @"websql databases";

    [backupInfos addObject:backupItem];

    return backupInfos;
}

/*
 * ios < 5.1 localstorage 的存储位置 {library/webkit/localstorage} persistent store by ios;
 * ios 5.1 / 6.0 localstorage 的存储位置 {library/caches/localstorage}
 * 存储在caches下的会被系统删除,所以在ios  5.1 / 6.0 将localstorage 备份到library/backup
 */
- (void) fixLegacyDatabaseLocationIssues
{
    //iOS 6.0 允许通过指定WebKitStoreWebDataForBackup key值为true 通过iCloud 备份 localstorage
    if (SYSTEM_VERSION_NOT_LOWER_THAN(@"6.0"))
    {
        //让iOS 6.0 采用和5.1一样的手动备份方式
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitStoreWebDataForBackup"];
    }

    //将备份(存储在library/backup) 或ios < 5.1存储(library/webkit) 还原到 localstorage 的系统默认存储目录下(Caches)
    NSString* appLibraryFolder = [NSSearchPathForDirectoriesInDomains (NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    // targetDir is where we want our databases to end up
    NSString* targetDir = [appLibraryFolder stringByAppendingPathComponent:@"Caches"];

    // backupDir's are the places where we may find old legacy backups
    NSString* backupDir = [appLibraryFolder stringByAppendingPathComponent:@"Backups"];
    NSString* backupDir2 = [appLibraryFolder stringByAppendingPathComponent:@"WebKit/LocalStorage"];

    NSMutableArray* backupInfos = [self createBackupInfoWithTargetDir:targetDir backupDir:backupDir rename:YES];
    [backupInfos addObjectsFromArray:[self createBackupInfoWithTargetDir:targetDir backupDir:backupDir2 rename:NO]];

    NSFileManager* manager = [NSFileManager defaultManager];

    for (XBackupInfo* info in backupInfos)
    {
        if ([info shouldRestore])
        {
            XLogI(@"Restoring old webstorage backup. From: '%@' To: '%@'.", info.backup, info.original);
            [self copyFrom:info.backup to:info.original error:nil];
        }
        if ([manager fileExistsAtPath:info.backup])
        {
            XLogI(@"Removing old webstorage backup: '%@'.", info.backup);
            [manager removeItemAtPath:info.backup error:nil];
        }
    }
}

#pragma mark -
#pragma mark Notification handlers

//当程序进行前后台切换退出时 要进行localstorage的 备份 和 还要
//将localstorage 备份到 library/backup下 或 从 library/backup 还原到 localstorage的原始位置

/*
    点击Home键回到后台时调用
 */
- (void) onResignActive
{
    UIDevice* device = [UIDevice currentDevice];

    NSNumber* exitsOnSuspend = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIApplicationExitsOnSuspend"];
    if (exitsOnSuspend == nil)
    {
        // if it's missing, it should be NO
        exitsOnSuspend = [NSNumber numberWithBool:NO];
    }
    if (exitsOnSuspend)
    {
        [self backup:nil withDict:nil];
    }

    if ([device isMultitaskingSupported])
    {
        __block UIBackgroundTaskIdentifier backgroundTaskID = UIBackgroundTaskInvalid;

        backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            XLogI(@"Background task to backup WebSQL/LocalStorage expired.");
        }];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            [self backup:nil withDict:nil];

            [[UIApplication sharedApplication] endBackgroundTask: backgroundTaskID];
            backgroundTaskID = UIBackgroundTaskInvalid;
        });
    }
}

/*
    从后台回到前台是调用
 */
- (void) onBecomeActive
{
    [self restore:nil withDict:nil];
}

/*
    中止应用时调用
 */
- (void) onAppTerminate
{
    [self onResignActive];
}

@end


#pragma mark -
#pragma mark XBackupInfo implementation

@implementation XBackupInfo

@synthesize original;
@synthesize backup;
@synthesize label;

/*
    判断aPath对应的文件项是否比bPath对应的文件项要新(具体的判断方法)
    @param aPath 原始文件路径
    @param bPath 目标文件路径
    @return YES表示aPath对应的文件比bPath对应的文件要新，NO表示bPath对应的文件比aPath对应的文件要新
 */
- (BOOL) file:(NSString*)aPath isNewerThanFile:(NSString*)bPath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error = nil;

    NSDictionary* aPathAttribs = [fileManager attributesOfItemAtPath:aPath error:&error];
    NSDictionary* bPathAttribs = [fileManager attributesOfItemAtPath:bPath error:&error];

    NSDate* aPathModDate = [aPathAttribs objectForKey:NSFileModificationDate];
    NSDate* bPathModDate = [bPathAttribs objectForKey:NSFileModificationDate];

    if (nil == aPathModDate && nil == bPathModDate)
    {
        return NO;
    }
    return ([aPathModDate compare:bPathModDate] == NSOrderedDescending || bPathModDate == nil);
}

/*
    判断aPath对应的文件项是否比bPath对应的文件项要新(根据文件的最后修改时间来做具体的判断)
    @param aPath 原始文件路径
    @param bPath 目标文件路径
    @return YES表示aPath对应的文件比bPath对应的文件要新，NO表示bPath对应的文件比aPath对应的文件要新
 */
- (BOOL) item:(NSString*)aPath isNewerThanItem:(NSString*)bPath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];

    BOOL aPathIsDir = NO, bPathIsDir = NO;
    BOOL aPathExists = [fileManager fileExistsAtPath:aPath isDirectory:&aPathIsDir];
    [fileManager fileExistsAtPath:bPath isDirectory:&bPathIsDir];

    if (!aPathExists)
    {
        return NO;
    }

    // 如果都不是文件夹就直接进行判断
    if (!(aPathIsDir && bPathIsDir))
    {
        return [self file:aPath isNewerThanFile:bPath];
    }

    // 如果都是文件夹就对文件夹中的文件进行逐一判断
    NSDirectoryEnumerator* directoryEnumerator = [fileManager enumeratorAtPath:aPath];
    NSString* path;

    while ((path = [directoryEnumerator nextObject]))
    {
        NSString* aPathFile = [aPath stringByAppendingPathComponent:path];
        NSString* bPathFile = [bPath stringByAppendingPathComponent:path];

        BOOL isNewer = [self file:aPathFile isNewerThanFile:bPathFile];
        if (isNewer)
        {
            return YES;
        }
    }

    return NO;
}

- (BOOL) shouldBackup
{
    return [self item:self.original isNewerThanItem:self.backup];
}

- (BOOL) shouldRestore
{
    return [self item:self.backup isNewerThanItem:self.original];
}

@end
