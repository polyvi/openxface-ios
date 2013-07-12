
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
//  XAmsImpl.m
//  xFace
//
//

#import "XAmsImpl.h"
#import "XAppManagement.h"
#import "XAppList.h"
#import "XApplication.h"
#import "XUtils.h"
#import "XConstants.h"

@implementation XAmsImpl

- (id)init:(XAppManagement *) applicationManagement
{
    self = [super init];
    if (self) {
        self->appManagement = applicationManagement;
    }
    return self;
}

#pragma mark XAms

- (void) installApp:(NSArray *)arguments
{
    id<XApplication> app = [arguments objectAtIndex:0];
    NSString *pkgPath = [arguments objectAtIndex:1];
    id<XInstallListener> listener = [arguments objectAtIndex:2];

    NSString *resolvedPath = [XUtils resolvePath:pkgPath usingWorkspace:[app getWorkspace]];
    [self->appManagement installApp:resolvedPath withListener:listener];
}

- (void) uninstallApp:(NSArray *)arguments
{
    NSString *appId = [arguments objectAtIndex:0];
    id<XInstallListener> listener = [arguments objectAtIndex:1];

    [self->appManagement uninstallApp:appId withListener:listener];
}

- (void) updateApp:(NSArray *)arguments
{
    id<XApplication> app = [arguments objectAtIndex:0];
    NSString *pkgPath = [arguments objectAtIndex:1];
    id<XInstallListener> listener = [arguments objectAtIndex:2];

    NSString *resolvedPath = [XUtils resolvePath:pkgPath usingWorkspace:[app getWorkspace]];
    [self->appManagement updateApp:resolvedPath withListener:listener];
}

- (BOOL) startApp:(NSString *)appId withParameters:(NSString *)params
{
    return [self->appManagement startApp:appId withParameters:params];
}

- (XAppList *) getAppList
{
    return [self->appManagement appList];
}

- (NSMutableArray *) getPresetAppPackages
{
    __autoreleasing NSError *error = nil;
    NSString *appWorkspace = [[[appManagement appList] getDefaultApp] getWorkspace];
    NSString *presetDirPath = [appWorkspace stringByAppendingPathComponent:PRE_SET_DIR_NAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:presetDirPath])
    {
        return nil;
    }

    NSArray *subFileNames = [fileManager contentsOfDirectoryAtPath:presetDirPath error:&error];
    if(error)
    {
        XLogE(@"Can't get content file of directory: %@, error: %@", presetDirPath, [error localizedDescription]);
        return nil;
    }
    if([subFileNames count] == 0)
    {
        return nil;
    }

    BOOL isDir = NO;
    NSMutableArray *appPackages = [[NSMutableArray alloc] init];
    for(NSString *subFileName in subFileNames)
    {
        [fileManager fileExistsAtPath:[presetDirPath stringByAppendingPathComponent:subFileName] isDirectory:&isDir];
        if(!isDir && ([subFileName hasSuffix:ZIP_PACKAGE_SUFFIX]
                      || [subFileName hasSuffix:APP_PACKAGE_SUFFIX_XPA]
                      || [subFileName hasSuffix:APP_PACKAGE_SUFFIX_NPA]))
        {
            [appPackages addObject:subFileName];
        }
    }
    return appPackages;
}

@end
