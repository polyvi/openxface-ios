
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
//  XLightweightAppInstaller.m
//  xFaceLib
//
//

#import "XLightweightAppInstaller.h"
#import "XLightweightAppInstaller_Privates.h"
#import "XInstallListener.h"
#import "XApplicationFactory.h"
#import "XApplication.h"
#import "XFileUtils.h"
#import "XUtils.h"
#import "XConfiguration.h"
#import "XAppList.h"
#import "XAppInfo.h"
#import "XConstants.h"
#import "XApplicationPersistence.h"

@implementation XLightweightAppInstaller

- (id) initWithAppList:(XAppList *)installedAppList appPersistence:(XApplicationPersistence *)applicationPersistence
{
    self = [super init];
    if (self)
    {
        self->appList = installedAppList;
        self->appPersistence = applicationPersistence;
    }
    return self;
}

- (void) install:(NSString *)preinstallAppSrcPath withListener:(id<XInstallListener>)listener
{
    @synchronized(self)
    {
        // NOTE:根据此接口目前的调用场景，不存在APP_ALREADY_EXISTED的错误情况,如果日后调用场景改变，请增加对此情况的处理.
        NSString *appConfigFilePath = [preinstallAppSrcPath stringByAppendingPathComponent:APPLICATION_CONFIG_FILE_NAME];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL ret = [fileMgr fileExistsAtPath:preinstallAppSrcPath];
        if (!ret)
        {
            [listener onError:INSTALL withAppId:nil withError:NO_SRC_PACKAGE];
            XLogE(@"[%@] Failed to install app due to package not found!", NSStringFromSelector(_cmd));
            return;
        }

        XAppInfo *appInfo = [XUtils getAppInfoFromConfigFileAtPath:appConfigFilePath];
        if (!appInfo)
        {
            [listener onError:INSTALL withAppId:nil withError:NO_APP_CONFIG_FILE];
            XLogE(@"[%@] Failed to install app due to app config file not found!", NSStringFromSelector(_cmd));
            return;
        }

        // 1) 设置应用源码root
        [appInfo setSrcRoot:APP_ROOT_PREINSTALLED];

        // 2) 拷贝应用配置文件，便于appList的初始化过程统一
        NSString *appId = [appInfo appId];
        ret = [self copyAppConfigFileWithAppInfo:appInfo];
        if (!ret)
        {
            [listener onError:INSTALL withAppId:appId withError:IO_ERROR];
            return;
        }

        // 3) 拷贝应用图标
        [self copyAppIconWithAppInfo:appInfo];

        // 4) 解压内置数据包
        ret = [self unpackAppDataWithAppInfo:appInfo];
        if (!ret)
        {
            [listener onError:INSTALL withAppId:appId withError:IO_ERROR];
            return;
        }

        // 5) 更新appList
        id<XApplication> app = [XApplicationFactory create:appInfo];
        [self->appList add:app];

        // 6) 更新配置文件
        [self->appPersistence addAppToConfig:app];

        [listener onSuccess:INSTALL withAppId:appId];

        //通知XAppEventHandler
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:XAPPLICATION_DID_FINISH_INSTALL_NOTIFICATION object:app]];
    }
}

- (void) update:(NSString *)preinstallAppSrcPath withListener:(id<XInstallListener>)listener
{
    @synchronized(self)
    {
        NSString *appConfigFilePath = [preinstallAppSrcPath stringByAppendingPathComponent:APPLICATION_CONFIG_FILE_NAME];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL ret = [fileMgr fileExistsAtPath:preinstallAppSrcPath];
        if (!ret)
        {
            [listener onError:UPDATE withAppId:nil withError:NO_SRC_PACKAGE];
            XLogE(@"[%@] Failed to update app due to package not found!", NSStringFromSelector(_cmd));
            return;
        }

        XAppInfo *appInfo = [XUtils getAppInfoFromConfigFileAtPath:appConfigFilePath];
        if (!appInfo)
        {
            [listener onError:UPDATE withAppId:nil withError:NO_APP_CONFIG_FILE];
            XLogE(@"[%@] Failed to update app due to app config file not found!", NSStringFromSelector(_cmd));
            return;
        }

        // 1) 设置应用源码root
        [appInfo setSrcRoot:APP_ROOT_PREINSTALLED];

        // 2) 拷贝应用配置文件，便于appList的初始化过程统一
        NSString *appId = [appInfo appId];
        NSAssert([self->appList containsApp:appId], nil);
        ret = [self copyAppConfigFileWithAppInfo:appInfo];
        if (!ret)
        {
            [listener onError:UPDATE withAppId:appId withError:IO_ERROR];
            return;
        }

        // 3) 拷贝应用图标
        [self copyAppIconWithAppInfo:appInfo];

        // 4) 解压内置数据包
        ret = [self unpackAppDataWithAppInfo:appInfo];
        if (!ret)
        {
            [listener onError:UPDATE withAppId:appId withError:IO_ERROR];
            return;
        }

        // 5) 更新app对应的appInfo
        id<XApplication> app = [self->appList getAppById:appId];
        [app setAppInfo:appInfo];

        // 6) 更新配置文件
        [self->appPersistence updateAppToConfig:app];

        [listener onSuccess:UPDATE withAppId:appId];

        //通知XAppEventHandler
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:XAPPLICATION_DID_FINISH_INSTALL_NOTIFICATION object:app]];
    }
}

#pragma mark Privates

- (BOOL) copyAppConfigFileWithAppInfo:(XAppInfo *)appInfo
{
    // 将应用配置文件从<Application_Home>/xFace.app/www/preinstalledApps/appSrcDirName/app.xml拷贝到<Applilcation_Home>/Documents/xface3/app_icons/appId/app.xml，便于appList的初始化过程统一
    NSString *appConfigFilePath = [[appInfo srcPath] stringByAppendingPathComponent:APPLICATION_CONFIG_FILE_NAME];
    NSString *destAppConfigFilePath = [[[XConfiguration getInstance] appInstallationDir] stringByAppendingFormat:@"%@%@%@", [appInfo appId], FILE_SEPARATOR, APPLICATION_CONFIG_FILE_NAME];

    BOOL ret = [XFileUtils copyItemAtPath:appConfigFilePath toPath:destAppConfigFilePath error:nil];
    return ret;
}

- (void) copyAppIconWithAppInfo:(XAppInfo *)appInfo
{
    // TODO:减少XAppInstaller中moveAppIconWithAppInfo的冗余代码
    NSString *iconSrcPath = [XUtils resolvePath:[appInfo icon] usingWorkspace:[appInfo srcPath]];
    NSString *iconDstPath = [XUtils generateAppIconPathUsingAppId:[appInfo appId] relativeIconPath:[appInfo icon]];

    if (!iconSrcPath || !iconDstPath || [iconSrcPath isEqualToString:[appInfo srcPath]])
    {
        XLogE(@"Error:failed to move app icon");
        return;
    }

    // 将应用图标从<Application_Home>/xFace.app/www/preinstalledApps/appSrcDirName/拷贝到<Applilcation_Home>/Documents/xface3/app_icons/appId/，便于默认应用访问
    [XFileUtils copyItemAtPath:iconSrcPath toPath:iconDstPath error:nil];
    return;
}

- (BOOL) unpackAppDataWithAppInfo:(XAppInfo *)appInfo
{
    //将内置数据<Application_Home>/xFace.app/www/preinstalledApps/appSrcDirName/workspace/workspace.zip解压到<Applilcation_Home>/Documents/xface3/app_icons/appId/workspace下
    NSString *dataPkgSrcPath = [[appInfo srcPath] stringByAppendingFormat:@"%@%@%@", APP_WORKSPACE_FOLDER, FILE_SEPARATOR, APP_DATA_PACKAGE_NAME_UNDER_WORKSPACE];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL ret = [fileMgr fileExistsAtPath:dataPkgSrcPath];
    if (ret)
    {
        NSString *dataDestPath = [[[XConfiguration getInstance] appInstallationDir] stringByAppendingFormat:@"%@%@%@", [appInfo appId], FILE_SEPARATOR, APP_WORKSPACE_FOLDER];
        ret = [XUtils unpackPackageAtPath:dataPkgSrcPath toPath:dataDestPath];
        return ret;
    }
    return YES;
}

@end
