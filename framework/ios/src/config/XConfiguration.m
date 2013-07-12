
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
//  XConfiguration.m
//  xFace
//
//

#import <sys/xattr.h>

#import "XConfiguration.h"
#import "XConstants.h"
#import "XUtils.h"
#import "XUtils+Additions.h"
#import "APXML.h"
#import "APDocument+XAPDocument.h"
#import "XConfiguration_Privates.h"
#import "XSystemWorkspaceFactory.h"
#import "XFileOperatorFactory.h"
#import "XFileOperator.h"
#import "XSystemConfigInfo.h"

#define EMTPY_USER_APPS_CONTENT                  @"<config>\n</config>"

@implementation XConfiguration

@synthesize systemWorkspace;
@synthesize appInstallationDir;
@synthesize appIconsDir;
@synthesize userAppsFilePath;
@synthesize systemConfigInfo;
@synthesize preinstallApps;

static XConfiguration *instance;

+ (void) initialize
{
    if (self == [XConfiguration class])
    {
        instance = [[XConfiguration alloc] init];
    }
}

+ (XConfiguration *) getInstance
{
    NSAssert((nil != instance), nil);
    return instance;
}

- (NSMutableArray *) preinstallApps
{
    return [[self systemConfigInfo] preinstallApps];
}

- (BOOL) loadConfiguration
{
    // 通过解析系统配置文件，加载配置信息：如预安装应用，偏好设置，扩展信息等
    self.systemConfigInfo = [[XSystemConfigInfo alloc] init];
    NSString *configFilePath = [self getSystemConfigFilePath];
    BOOL ret = [XUtils parseXMLFileAtPath:configFilePath withDelegate:self.systemConfigInfo];
    return ret;
}

- (BOOL) prepareSystemWorkspace
{
    self->systemWorkspace = [self getSystemWorkspace];
    self->appInstallationDir = [self getAppInstallationDir];
    self->appIconsDir = [self getAppIconsDir];
    self->userAppsFilePath = [self getUserAppsFilePath];

    BOOL ret = [self systemWorkspace]
                    && [self appInstallationDir]
                    && [self appIconsDir]
                    && [self userAppsFilePath];
    return ret;
}

#pragma mark private methods

- (NSString*)getSystemWorkspace;
{
    NSString *workspace = [XSystemWorkspaceFactory create];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:workspace])
    {
        NSError * __autoreleasing error = nil;

        BOOL ret = [fileManager createDirectoryAtPath:workspace withIntermediateDirectories:YES attributes:nil error:&error];
        if(!ret)
        {
            XLogE(@"%@", [error localizedDescription]);
            workspace = nil;
        } else {
            // Disable iCloud & iTunes backup.
            u_int8_t attrValue = 1;
            setxattr([workspace fileSystemRepresentation],
                     "com.apple.MobileBackup",
                     &attrValue,
                     sizeof(attrValue),
                     0,
                     0);
        }
    }
    return workspace;
}

- (NSString*)getAppInstallationDir
{
    // 应用安装路径形如：<Applilcation_Home>/Documents/xface3/apps/
    NSString *workspace = [self systemWorkspace];
    NSString *installationPath = [workspace stringByAppendingFormat:@"%@%@", APPLICATION_INSTALLATION_FOLDER, FILE_SEPARATOR];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:installationPath])
    {
        NSError * __autoreleasing error = nil;

        BOOL ret = [fileManager createDirectoryAtPath:installationPath withIntermediateDirectories:YES attributes:nil error:&error];
        if(!ret)
        {
            XLogE(@"%@", [error localizedDescription]);
            installationPath = nil;
        }
    }

    return installationPath;
}

- (NSString *)getAppIconsDir
{
    // 应用图标路径形如：<Applilcation_Home>/Documents/xface3/app_icons/
    NSString *workspace = [self systemWorkspace];
    NSString *appIconsPath = [workspace stringByAppendingFormat:@"%@%@", APPLICATION_ICONS_FOLDER, FILE_SEPARATOR];

    // TODO:定义为单独的方法
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:appIconsPath])
    {
        NSError * __autoreleasing error = nil;

        BOOL ret = [fileManager createDirectoryAtPath:appIconsPath withIntermediateDirectories:YES attributes:nil error:&error];
        if(!ret)
        {
            XLogE(@"%@", [error localizedDescription]);
            appIconsPath = nil;
        }
    }

    return appIconsPath;
}

- (NSString *)getSystemConfigFilePath
{
    // 系统配置文件所在路径形如：<Applilcation_Home>/xFace.app/config.xml
    NSString* configFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:SYSTEM_CONFIG_FILE_NAME ofType:nil];
    return configFilePath;
}

- (NSString *)getUserAppsFilePath
{
    // userApps.xml所在路径形如：<Applilcation_Home>/Documents/xface3/userApps.xml
    NSString *appsFilePath = [self systemWorkspace];
    appsFilePath = [appsFilePath stringByAppendingString:USER_APPS_FILE_NAME];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:appsFilePath])
    {
        id<XFileOperator> systemConfigFileOperator = [XFileOperatorFactory create];
        BOOL ret = [systemConfigFileOperator saveString:EMTPY_USER_APPS_CONTENT toFile:appsFilePath];
        if(!ret)
        {
            XLogE(@"Failed to create userApps.xml at path:%@", appsFilePath);
            appsFilePath = nil;
        }
    }
    return appsFilePath;
}

@end
