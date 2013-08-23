
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
//  XAppInstaller.m
//  xFace
//
//

#import "XAppInstaller.h"
#import "XApplication.h"
#import "XInstallListener.h"
#import "XConfiguration.h"
#import "XConstants.h"
#import "XAppList.h"
#import "XUtils.h"
#import "XApplicationPersistence.h"
#import "XAppInfo.h"
#import "XAppInstaller_Privates.h"
#import "XFileUtils.h"
#import "XApplicationFactory.h"

@implementation XAppInstaller

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

- (void) install:(NSString *)pkgPath withListener:(id<XInstallListener>)listener
{
    @synchronized(self)
    {
        // TODO:为避免同一个应用被安装多次：
        // 目前的处理策略为：不允许同时安装多个应用，每次只安装一个应用
        // 日后的处理策略为：允许同时安装多个appId不同的应用，只是不允许同时安装(卸载、更新)appId相同的应用
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL ret = [fileMgr fileExistsAtPath:pkgPath];
        if (!ret)
        {
            [listener onError:INSTALL withAppId:nil withError:NO_SRC_PACKAGE];
            XLogE(@"[%@] Failed to install app due to package not found!", NSStringFromSelector(_cmd));
            return;
        }

        [listener onProgressUpdated:INSTALL withStatus:INITIALIZED];

        // 获取应用安装包配置文件中的应用id
        XAppInfo *appInfo = [XUtils getAppInfoFromAppPackage:pkgPath];
        if (!appInfo)
        {
            [listener onError:INSTALL withAppId:nil withError:NO_APP_CONFIG_FILE];
            XLogE(@"[%@] Failed to install app due to app config file not found!", NSStringFromSelector(_cmd));
            return;
        }
        NSString *appId = [appInfo appId];

        // 对于已经安装的应用不再重复安装
        ret = [self->appList containsApp:appId];
        if (YES == ret)
        {
            [listener onError:INSTALL withAppId:appId withError:APP_ALREADY_EXISTED];
            XLogE(@"[%@] Failed to install '%@' due to app already existed!", NSStringFromSelector(_cmd), appId);
            return;
        }

        NSString *dstPath = [XUtils buildWorkspaceAppSrcPath:appId];

        [listener onProgressUpdated:INSTALL withStatus:INSTALLING];

        // 解压应用安装包
        ret = [XUtils unpackPackageAtPath:pkgPath toPath:dstPath];
        if (NO == ret)
        {
            // 解压失败，删除解压过程中生成的文件
            [XFileUtils removeItemAtPath:dstPath error:nil];
            [listener onError:INSTALL withAppId:appId withError:IO_ERROR];
             XLogE(@"[%@] Failed to install '%@' due to IO error!", NSStringFromSelector(_cmd), appId);
            return;
        }

        [appInfo setSrcRoot:APP_ROOT_WORKSPACE];
        id<XApplication> app = [XApplicationFactory create:appInfo];

        // 更新appList
        [self->appList add:app];

        // 将应用图标移动到<Applilcation_Home>/Documents/xface3/app_icons/appId/目录下，便于默认应用访问
        [self moveAppIconWithAppInfo:appInfo];

        // 更新配置文件
        [listener onProgressUpdated:INSTALL withStatus:UPDATING_CONFIGURATION];
        [self->appPersistence addAppToConfig:app];

        [listener onProgressUpdated:INSTALL withStatus:FINISHED];

        // 删除应用安装包
        [XFileUtils removeItemAtPath:pkgPath error:nil];

        [listener onSuccess:INSTALL withAppId:appId];

        //通知XAppEventHandler
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:XAPPLICATION_DID_FINISH_INSTALL_NOTIFICATION object:app]];
    }
    return;
}

- (void) update:(NSString *)pkgPath withListener:(id<XInstallListener>)listener
{
    @synchronized(self)
    {
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL ret = [fileMgr fileExistsAtPath:pkgPath];
        if (!ret)
        {
            [listener onError:UPDATE withAppId:nil withError:NO_SRC_PACKAGE];
            XLogE(@"[%@] Failed to update app due to package not found!", NSStringFromSelector(_cmd));
            return;
        }

        [listener onProgressUpdated:UPDATE withStatus:INITIALIZED];

        // 获取应用更新包配置文件中的应用id
        XAppInfo *appInfo = [XUtils getAppInfoFromAppPackage:pkgPath];
        if (!appInfo)
        {
            [listener onError:UPDATE withAppId:nil withError:NO_APP_CONFIG_FILE];
            XLogE(@"[%@] Failed to update app due to app config file not found!", NSStringFromSelector(_cmd));
            return;
        }
        NSString *appId = [appInfo appId];

        // 只能更新已经安装的应用
        ret = [self->appList containsApp:appId];
        if (NO == ret)
        {
            [listener onError:UPDATE withAppId:appId withError:NO_TARGET_APP];
            XLogE(@"[%@] Failed to update app due to target app not found!", NSStringFromSelector(_cmd));
            return;
        }

        // 开始更新
        [listener onProgressUpdated:UPDATE withStatus:INSTALLING];

        // 解压应用更新包到临时目录下
        NSString *tmpDirPath = [XFileUtils createTemporaryDirectory:[[XConfiguration getInstance] appInstallationDir]];
        ret = [XUtils unpackPackageAtPath:pkgPath toPath:tmpDirPath];
        if (NO == ret)
        {
            // 解压失败，删除解压过程中生成的文件
            [XFileUtils removeItemAtPath:tmpDirPath error:nil];
            [listener onError:UPDATE withAppId:appId withError:IO_ERROR];
            XLogE(@"[%@] Failed to update '%@' due to IO error!", NSStringFromSelector(_cmd), appId);
            return;
        }

        // 迁移临时目录到指定app安装目录下
        NSString *dstPath = [XUtils buildWorkspaceAppSrcPath:appId];
        ret = [XFileUtils moveItemAtPath:tmpDirPath toPath:dstPath error:nil];
        if (NO == ret)
        {
            // 目录迁移失败，删除临时目录
            [XFileUtils removeItemAtPath:tmpDirPath error:nil];
            [listener onError:UPDATE withAppId:appId withError:IO_ERROR];
            XLogE(@"[%@] Failed to update '%@' due to IO error!", NSStringFromSelector(_cmd), appId);
            return;
        }

        [listener onProgressUpdated:UPDATE withStatus:UPDATING_CONFIGURATION];

        // 删除应用图标
        [self deleteAppIconWithAppId:appId];

        // 更新app对应的appInfo
        id<XApplication> originalApp = [self->appList getAppById:appId];
        [appInfo setSrcRoot:APP_ROOT_WORKSPACE];
        [originalApp setAppInfo:appInfo];

        // 更新配置文件
        [self->appPersistence updateAppToConfig:originalApp];

        // 将应用图标移动到<Applilcation_Home>/Documents/xface3/app_icons/appId/目录下，便于默认应用访问
        [self moveAppIconWithAppInfo:appInfo];

        [listener onProgressUpdated:UPDATE withStatus:FINISHED];

        // 删除应用更新包
        [XFileUtils removeItemAtPath:pkgPath error:nil];
        [listener onSuccess:UPDATE withAppId:appId];

        //通知XAppEventHandler
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:XAPPLICATION_DID_FINISH_INSTALL_NOTIFICATION object:originalApp]];
    }
    return;
}

- (void) uninstall:(NSString *)appId withListener:(id<XInstallListener>)listener
{
    @synchronized(self)
    {
        // TODO: 是否允许卸载正在运行的应用？
        // TODO: 增加进度报告
        id<XApplication> app = [self->appList getAppById:appId];
        if (!app)
        {
            [listener onError:UNINSTALL withAppId:appId withError:NO_TARGET_APP];
            XLogE(@"[%@] Failed to uninstall '%@' due to '%@' not found!", NSStringFromSelector(_cmd), appId, appId);
            return;
        }

        NSError * __autoreleasing error = nil;
        NSString *installedPath = [XUtils buildWorkspaceAppSrcPath:appId];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL ret = [fileMgr removeItemAtPath:installedPath error:&error];
        if (!ret)
        {
            [listener onError:UNINSTALL withAppId:appId withError:IO_ERROR];
            XLogE(@"[%@] Failed to uninstall '%@' at path:%@ with error:%@", NSStringFromSelector(_cmd), appId, installedPath, [error localizedDescription]);
        }
        else
        {
            // 更新已安装列表
            [self->appList removeAppById:appId];
            [self->appPersistence removeAppFromConfig:appId];

            // 删除应用图标
            [self deleteAppIconWithAppId:appId];
            [listener onSuccess:UNINSTALL withAppId:appId];
        }
    }
    return;
}

#pragma mark XAppInstaller private

- (void) deleteAppIconWithAppId:(NSString *)appId
{
    // 删除应用图标
    NSAssert([appId length], nil);
    NSString *iconPath = [XUtils generateAppIconPathUsingAppId:appId relativeIconPath:nil];
    [XFileUtils removeItemAtPath:iconPath error:nil];
}

- (void) moveAppIconWithAppInfo:(XAppInfo *)appInfo
{
    // 将应用图标移动到<Applilcation_Home>/Documents/xface3/app_icons/appId/目录下，便于默认应用访问
    NSString *iconWorkspace = [XUtils buildWorkspaceAppSrcPath:[appInfo appId]];
    NSString *iconSrcPath = [XUtils resolvePath:[appInfo icon] usingWorkspace:iconWorkspace];
    NSString *iconDstPath = [XUtils generateAppIconPathUsingAppId:[appInfo appId] relativeIconPath:[appInfo icon]];

    if (!iconSrcPath || !iconDstPath || [iconSrcPath isEqualToString:iconWorkspace])
    {
        XLogE(@"Error:failed to move app icon");
        return;
    }

    // 将应用图标移动到<Applilcation_Home>/Documents/xface3/app_icons/appId/目录下
    NSError * __autoreleasing error = nil;
    BOOL ret = [XFileUtils moveItemAtPath:iconSrcPath toPath:iconDstPath error:&error];
    if (!ret && error)
    {
        XLogE(@"Failed to move app icon at path:%@ to path:%@ with error:%@", iconSrcPath, iconDstPath, [error localizedDescription]);
    }
    return;
}

@end
