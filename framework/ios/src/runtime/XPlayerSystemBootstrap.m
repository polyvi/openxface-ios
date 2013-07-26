
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
//  XPlayerSystemBootstrap.m
//  xFace
//
//

#import "XPlayerSystemBootstrap.h"
#import "XConfiguration.h"
#import "XAppManagement.h"
#import "XAppPreinstallListener.h"
#import "XAppList.h"
#import "XApplication.h"
#import "XAppInfo.h"
#import "XUtils.h"
#import "XConstants.h"
#import "XPlayerSystemBootstrap_Privates.h"
#import "XFileUtils.h"
#import "XAppManagement.h"
#import "XSync.h"
#import "XApplicationFactory.h"
#import "XAmsImpl.h"
#import "XAmsExt.h"
#import "XMessenger.h"
#import "XApplication.h"
#import "XExtensionManager.h"

@implementation XPlayerSystemBootstrap

@synthesize bootDelegate;

/**
    启动之前的准备工作
 */
-(void) prepareWorkEnvironment
{
    [[XConfiguration getInstance] prepareSystemWorkspace];
    XSync* sync = [[XSync alloc] initWith:self];
    [sync run];
}

#pragma mark XSyncDelegate

-(void)syncDidFinish
{
    // 执行资源部署
    if ([self deployResources])
    {
        [[self bootDelegate] didFinishPreparingWorkEnvironment];
    }
    else
    {
        NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : @"fail to deployResources"};
        NSError *anError = [[NSError alloc] initWithDomain:@"xface" code:0 userInfo:errorDictionary];
        [[self bootDelegate] didFailToPrepareEnvironmentWithError:anError];
    }
}

/**
  使用player模式进行启动
 */
-(void) boot:(XAppManagement*)appManagement
{
    //清空所有缓存的response数据
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    XAppInfo *info = [[XAppInfo alloc] init];
    info.appId = DEFAULT_APP_ID_FOR_PLAYER;
    info.isEncrypted = NO;
    info.entry = DEFAULT_APP_START_PAGE;
    info.type = APP_TYPE_XAPP;

    id<XApplication> app = [XApplicationFactory create:info];
    XAppList *appList = [appManagement appList];
    [appList add:app];
    [appList markAsDefaultApp:info.appId];

    // 创建ams扩展,并交给扩展管理器进行管理
    XAmsImpl *amsImpl = [[XAmsImpl alloc] init:appManagement];
    XAmsExt *amsExt = [[XAmsExt alloc] init:amsImpl withMessenger:[[XMessenger alloc] init] withMsgHandler:app.jsEvaluator];
    [app.extMgr registerExtension:amsExt withName:EXTENSION_AMS_NAME];

    NSString *params = [[self bootDelegate] bootParams];
    [appManagement startDefaultAppWithParams:params];
}

- (BOOL) deployResources
{
    BOOL ret = NO;
    NSBundle *mainBundle = [NSBundle mainBundle];
    XConfiguration *config = [XConfiguration getInstance];

    //首先检查<Applilcation_Home>/Documents/目录下是否存在xface_player.zip，如果存在，则解压到特定目录，否则拷贝www下的离散文件到特定目录
    // 其中xface_player.zip需要用户通过itunes拷贝到<Applilcation_Home>/Documents/目录下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];

    // packagePath路径形如：<Applilcation_Home>/Documents/xface_player.zip
    NSString *packagePath = [documentDirectory stringByAppendingFormat:@"%@%@", FILE_SEPARATOR, XFACE_PLAYER_PACKAGE_NAME];
    NSString *destPath = [[config appInstallationDir] stringByAppendingPathComponent:DEFAULT_APP_ID_FOR_PLAYER];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isPackageExisted = [fileManager fileExistsAtPath:packagePath];
    if (isPackageExisted)
    {
        ret = [XUtils unpackPackageAtPath:packagePath toPath:destPath];
        return ret;
    }
    else
    {
        NSString *bundlePath = [NSString stringWithFormat:@"%@%@%@%@%@", APPLICATION_PREPACKED_PACKAGE_FOLDER, FILE_SEPARATOR, XFACE_WORKSPACE_NAME_UNDER_APP, FILE_SEPARATOR, APPLICATION_INSTALLATION_FOLDER];
        NSString *srcAppFolderPath = [mainBundle pathForResource:DEFAULT_APP_ID_FOR_PLAYER ofType:nil inDirectory:bundlePath];

        NSAssert(srcAppFolderPath, @"Start app using player mode, but the default app files don't exist!");

        //当srcAppFolderPath目录下文件较多且destPath已经存在时，将导致copyFileRecursively过程较慢，从而影响player的启动速度
        //为提高player启动速度，又考虑到player的使用场景，调整资源部署过程，只对workspace,data目录进行merge操作，避免对整个app目录的遍历过程
        BOOL needMerging = NO;
        ret = [self prepareForMergingUserData:&needMerging];

        //在prepare过程中已经将destPath删除，故避免了对整个app目录的遍历过程
        ret &= [XFileUtils copyFileRecursively:srcAppFolderPath toPath:destPath];

        if (ret && needMerging)
        {
            ret =  [self mergeUserDataAtPath:srcAppFolderPath toPath:destPath];
        }
        return ret;
    }
}

- (BOOL) prepareForMergingUserData:(BOOL *)needMerging
{
    BOOL ret = YES;
    *needMerging = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    XConfiguration *config = [XConfiguration getInstance];
    NSString *destPath = [[config appInstallationDir] stringByAppendingPathComponent:DEFAULT_APP_ID_FOR_PLAYER];
    NSArray *userDataDirs = [NSArray arrayWithObjects:APP_WORKSPACE_FOLDER, APP_DATA_DIR_FOLDER, nil];
    if ([fileManager fileExistsAtPath:destPath])
    {
        //将app下的workspace、data目录移动到上级目录，为合并userdata做准备
        NSEnumerator *enumerator = [userDataDirs objectEnumerator];
        NSString *dir = nil;
        BOOL isDir = NO;

        while (dir = [enumerator nextObject])
        {
            NSString *userDataDir = [destPath stringByAppendingPathComponent:dir];
            if ([fileManager fileExistsAtPath:userDataDir isDirectory:&isDir] && isDir)
            {
                NSString *tempUserDataDir = [[config appInstallationDir] stringByAppendingPathComponent:dir];
                ret &= [XFileUtils moveItemAtPath:userDataDir toPath:tempUserDataDir error:nil];
                *needMerging = YES;
            }
        }

        ret &= [XFileUtils removeItemAtPath:destPath error:nil];
    }
    return ret;
}

- (BOOL) mergeUserDataAtPath:(NSString *)srcPath toPath:(NSString *)destPath
{
    NSArray *userDataDirs = [NSArray arrayWithObjects:APP_WORKSPACE_FOLDER, APP_DATA_DIR_FOLDER, nil];
    NSEnumerator *enumerator = [userDataDirs objectEnumerator];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    XConfiguration *config = [XConfiguration getInstance];
    NSString *dir = nil;
    BOOL isDir = NO;
    BOOL ret = YES;

    while (dir = [enumerator nextObject])
    {
        NSString *tempUserDataDir = [[config appInstallationDir] stringByAppendingPathComponent:dir];
        if ([fileManager fileExistsAtPath:tempUserDataDir isDirectory:&isDir] && isDir)
        {
            NSString *srcUserDataDir = [srcPath stringByAppendingPathComponent:dir];
            if ([fileManager fileExistsAtPath:srcUserDataDir isDirectory:&isDir] && isDir)
            {
                ret &= [XFileUtils copyFileRecursively:srcUserDataDir toPath:tempUserDataDir];
            }
            NSString *destUserDataDir = [destPath stringByAppendingPathComponent:dir];
            ret &= [XFileUtils moveItemAtPath:tempUserDataDir toPath:destUserDataDir error:nil];
        }
    }
    return ret;
}

@end
