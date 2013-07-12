
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
//  XAppPreinstallListener.m
//  xFace
//
//

#import "XAppPreinstallListener.h"
#import "XAppManagement.h"
#import "XConfiguration.h"
#import "XConstants.h"
#import "XAppList.h"
#import "XApplication.h"
#import "XAppPreinstallListener_Private.h"
#import "XFileUtils.h"

@implementation XAppPreinstallListener

- (id)init:(XAppManagement *) applicationManagement
{
    self = [super init];
    if (self)
    {
        self->appManagement = applicationManagement;
        self->srcPresetDir = [[[XConfiguration getInstance] systemWorkspace] stringByAppendingPathComponent:PRE_SET_DIR_NAME];
    }
    return self;
}

- (void) handlePresetPackages
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;

    // 源pre_set目录不存在或者不是一个目录
    if(![fileManager fileExistsAtPath:self->srcPresetDir isDirectory:&isDir] || !isDir)
    {
        return;
    }

    // 将<system workspace>/pre_set目录下的预置应用包拷贝到defaultApp的<app workspace>/pre_set下
    [self movePresetAppPackages];

    // 将<system workspace>/pre_set目录下的预置数据包拷贝到defaultApp的<app workspace>下
    [self movePresetDataPackages];

    // 删除<system workspace>/pre_set目录
    [XFileUtils removeItemAtPath:self->srcPresetDir error:nil];
}

- (NSArray *)getPresetPackagesOfType:(PRESET_PACKAGE_TYPE)type atPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    __autoreleasing NSError *error = nil;
    NSArray *contentFiles = [fileManager contentsOfDirectoryAtPath:path error:&error];
    if(error)
    {
        XLogE(@"Can't get content files of dir: %@, error: %@", path, [error localizedDescription]);
        return nil;
    }

    NSArray *packages = nil;
    NSArray *fileExtensions = @[APP_PACKAGE_SUFFIX_XPA, APP_PACKAGE_SUFFIX_NPA];
    NSMutableArray *subPredicates = [NSMutableArray array];
    for (NSString *extension in fileExtensions)
    {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", extension]];
    }
    NSPredicate *appPkgFilter = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicates];

    if (PRESET_APP_PACKAGE == type)
    {
        // 获取预置应用包名
        packages = [contentFiles filteredArrayUsingPredicate:appPkgFilter];
    }
    else
    {
        // 获取预置数据包名
        NSPredicate *dataPkgFilter = [NSCompoundPredicate notPredicateWithSubpredicate:appPkgFilter];
        packages = [contentFiles filteredArrayUsingPredicate:dataPkgFilter];
    }
    return packages;
}

- (void) movePresetAppPackages
{
    id<XApplication> defaultApp = [[self->appManagement appList] getDefaultApp];
    NSString *dstPath = [[defaultApp getWorkspace] stringByAppendingPathComponent:PRE_SET_DIR_NAME];

    NSArray *appPackages = [self getPresetPackagesOfType:PRESET_APP_PACKAGE atPath:self->srcPresetDir];
    [self movePackages:appPackages atPath:self->srcPresetDir toPath:dstPath];
}

- (void) movePresetDataPackages
{
    id<XApplication> defaultApp = [[self->appManagement appList] getDefaultApp];
    NSString *dstPath = [defaultApp getWorkspace];

    NSArray *dataPackages = [self getPresetPackagesOfType:PRESET_DATA_PACKAGE atPath:self->srcPresetDir];
    [self movePackages:dataPackages atPath:self->srcPresetDir toPath:dstPath];
}

- (void) movePackages:(NSArray *)packageFiles atPath:(NSString *)srcPath toPath:(NSString *)dstPath
{
    for(NSString *fileName in packageFiles)
    {
        NSString *srcPkgPath = [srcPath stringByAppendingPathComponent:fileName];
        NSString *destPkgPath = [dstPath stringByAppendingPathComponent:fileName];

        [XFileUtils moveItemAtPath:srcPkgPath toPath:destPkgPath error:nil];
    }
}

- (void) handleEncryptCodePackages
{
    // 将<system workspace>/encrypt_code目录下的加密代码包拷贝到defaultApp的安装目录下
    id<XApplication> defaultApp = [[self->appManagement appList] getDefaultApp];
    NSString *encrytCodeDir = [[[XConfiguration getInstance] systemWorkspace] stringByAppendingPathComponent:ENCRYPT_CODE_DIR_NAME];

    NSString *srcPkgPath = [encrytCodeDir stringByAppendingPathComponent:ENCRYPE_CODE_PACKAGE_NAME];
    NSString *dstPkgPath = [[defaultApp installedDirectory] stringByAppendingPathComponent:ENCRYPE_CODE_PACKAGE_NAME];

    if ([[NSFileManager defaultManager] fileExistsAtPath:srcPkgPath])
    {
        [XFileUtils moveItemAtPath:srcPkgPath toPath:dstPkgPath error:nil];

        // 删除<system workspace>/encrypt_code目录
        [XFileUtils removeItemAtPath:encrytCodeDir error:nil];
    }
    return;
}

#pragma mark XInstallListener

- (void) onProgressUpdated:(OPERATION_TYPE)type withStatus:(PROGRESS_STATUS)progressStatus
{
    // TODO:对进度更新事件进行处理
}

- (void) onSuccess:(OPERATION_TYPE)type withAppId:(NSString *)appId
{
    // 预装完成，移动defaultApp使用的预置应用到defaultApp的workspace下面
    // appId为nil表示预安装过程结束
    // TODO: 关于如何通过整个预安装过程结束状态，以后可能需要统一考虑一个新的方案
    if(!appId)
    {
        [self handlePresetPackages];
        [self handleEncryptCodePackages];
    }
}

- (void) onError:(OPERATION_TYPE)type withAppId:(NSString *)appId withError:(AMS_ERROR)error
{
    // TODO:对安装失败的情况进行处理
}

@end
