
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
//  XUtils.m
//  xFace
//
//

#import "XUtils.h"
#import "XZipArchive.h"
#import "XConstants.h"
#import "XConfiguration.h"
#import "APXML.h"
#import "XExtension.h"
#import "XUtils_Privates.h"
#import "XAppXMLParser.h"
#import "XAppXMLParserFactory.h"
#import "UIDevice+Additions.h"
#import "XRuntime.h"
#import "XSystemConfigInfo.h"

#define APP_VERSION_FOUR_SEQUENCE (4)
#define BACKSLASH       @"\\"

@implementation XUtils

static XUtils* sSelPerformer = nil;

+ (void)initialize
{
    sSelPerformer = [[XUtils alloc] init];
}

+ (NSInteger) generateRandomId
{
    return arc4random();
}

+ (BOOL) unpackPackageAtPath:(NSString *)srcPath toPath:(NSString *)dstPath
{
    BOOL ret = NO;
    if ((0 == [srcPath length]) || (0 == [dstPath length]))
    {
        return ret;
    }

    ZipArchive *za = [[ZipArchive alloc] init];
    if ([za UnzipOpenFile:srcPath])
    {
        ret = [za UnzipFileTo:dstPath overWrite:YES];
        [za UnzipCloseFile];
    }

    if(ret)
    {
        XLogI(@"unpack application package successfully");
    } else
    {
        XLogE(@"Error:unpack application package failed");
    }
    return ret;
}

+ (BOOL) parseXMLFileAtPath:(NSString *)path withDelegate:(id <NSXMLParserDelegate>)delegate
{
    BOOL ret = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (ret)
    {
        NSData *xmlData = [[NSFileManager defaultManager] contentsAtPath:path];
        ret = [XUtils parseXMLData:xmlData withDelegate:delegate];
    }
    return ret;
}

+ (BOOL) parseXMLData:(NSData *)data withDelegate:(id <NSXMLParserDelegate>)delegate
{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    [xmlParser setDelegate:delegate];
    BOOL ret = [xmlParser parse];
    return ret;
}

+ (NSData *) readFile:(NSString *)fileName inPackage:(NSString *)packagePath
{
    NSAssert((0 != [fileName length]), nil);

    ZipArchive *za = [[ZipArchive alloc] init];

    BOOL ret = [za UnzipOpenFile:packagePath];
    if (!ret)
    {
        return nil;
    }

    NSData *data = nil;
    ret = [za locateFileInZip:fileName];
    if (ret)
    {
        data = [za readCurrentFileInZip];
    }

    [za UnzipCloseFile];
    return data;
}

+ (XAppInfo *) getAppInfoFromAppXMLData:(NSData *)xmlData
{
    id<XAppXMLParser> appXMLParser = [XAppXMLParserFactory createAppXMLParserWithXMLData:xmlData];
    if (appXMLParser)
    {
        XAppInfo *appInfo = [appXMLParser parseAppXML];
        return appInfo;
    }

    //如果app.xml是不能识别的，会返回一个为nil 的appxml parser
    XLogE(@"can't parse app.xml");
    return nil;
}

+ (XAppInfo *) getAppInfoFromAppPackage:(NSString *)appPackagePath
{
    NSData *xmlData = [XUtils readFile:APPLICATION_CONFIG_FILE_NAME inPackage:appPackagePath];
    if (xmlData)
    {
        // 解析获取到的应用配置文件数据
        XAppInfo *appInfo = [XUtils getAppInfoFromAppXMLData:xmlData];
        return appInfo;
    }
    return nil;
}

+ (XAppInfo *) getAppInfoFromConfigFileAtPath:(NSString *)appConfigFilePath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:appConfigFilePath])
    {
        NSData *xmlData = [fileMgr contentsAtPath:appConfigFilePath];
        XAppInfo *appInfo = [XUtils getAppInfoFromAppXMLData:xmlData];
        return appInfo;
    }
    XLogE(@"app.xml at path:%@ not found!", appConfigFilePath);
    return nil;
}

+ (NSString *) resolvePath:(NSString *)path usingWorkspace:(NSString *)workspace
{
    NSAssert([workspace isAbsolutePath], @"Error:path:%@ is not absolute path", workspace);

    if (0 == [path length])
    {
        return workspace;
    }

    path = [path stringByReplacingOccurrencesOfString:BACKSLASH withString:FILE_SEPARATOR];

    NSString *resolvedPath = [workspace stringByAppendingPathComponent:path];
    resolvedPath = [resolvedPath stringByStandardizingPath];

    // 转换后的path要求在workspace下
    NSString *resolvedTempPath = resolvedPath;
    if (![resolvedPath hasSuffix:FILE_SEPARATOR])
    {
        resolvedTempPath = [resolvedPath stringByAppendingString:FILE_SEPARATOR];
    }
    if(![workspace hasSuffix:FILE_SEPARATOR])
    {
        workspace = [workspace stringByAppendingString:FILE_SEPARATOR];
    }

    BOOL ret = [resolvedTempPath hasPrefix:workspace];
    if (ret)
    {
        return resolvedPath;
    }
    else
    {
        XLogE(@"Error:path:%@ is not authorized", resolvedPath);
        return nil;
    }
}

+ (NSString *) generateAppIconPathUsingAppId:(NSString *)appId relativeIconPath:(NSString *)relativeIconPath
{
    // 生成的应用图标最终放置的目标路径形如：<Application_Home>/Documents/xface3/app_icons/appId/icon.png
    NSAssert((nil != appId), nil);

    NSString *iconRoot = [[XConfiguration getInstance] appIconsDir];
    iconRoot = [iconRoot stringByAppendingFormat:@"%@", appId];

    NSString *iconPath = [self resolvePath:relativeIconPath usingWorkspace:iconRoot];
    return iconPath;
}

+ (BOOL) saveDoc:(APDocument *)doc toFile:(NSString *)filePath
{
    NSString *xmlStr = [doc prettyXML];
    NSData *xmlData=[xmlStr dataUsingEncoding:NSUTF8StringEncoding];
    BOOL ret = [xmlData writeToFile:filePath atomically:YES];
    if (!ret)
    {
        XLogE(@"Error:writting configuration failed and file path is: %@", filePath);
    }
    return ret;
}

+ (id) getPreferenceForKey:(NSString *)keyName
{
    XSystemConfigInfo *systemConfigInfo = [[XConfiguration getInstance] systemConfigInfo];
    id preference = [[systemConfigInfo settings] objectForKey:keyName];
    return preference;
}

+(BOOL) isPlayer
{
    return[[XUtils getPreferenceForKey:USE_PLAYER_MODE_PROPERTY] boolValue];
}

+ (id) getValueFromDataForKey:(id)key
{
    NSString *systemWorkspace = [[XConfiguration getInstance] systemWorkspace];
    NSString *plistPath = [systemWorkspace stringByAppendingPathComponent:XFACE_DATA_PLIST_NAME];
    NSDictionary *configDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    if (configDic) {
        return [configDic valueForKey:key];
    }
    return nil;
}

+ (void) setValueToDataForKey:(id)key value:(id)value
{
    NSString *systemWorkspace = [[XConfiguration getInstance] systemWorkspace];
    NSString *plistPath = [systemWorkspace stringByAppendingPathComponent:XFACE_DATA_PLIST_NAME];
    NSMutableDictionary *configDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    if (nil == configDic)
    {
        configDic = [[NSMutableDictionary alloc] init];
    }

    [configDic setObject:value forKey:key];
    [configDic writeToFile:plistPath atomically:YES];
}

+ (NSString *)generateJsCallbackRegistryKey:(NSString *)extClass withMethod:(NSString *)extMethod
{
    Class cls = NSClassFromString(extClass);
    if([cls isSubclassOfClass:[XExtension class]])
    {
        return [NSString stringWithFormat:@"%@_%@", extClass, extMethod];
    }

    XLogE(@"Can't generate js callback key for class: %@, it's not a subclass of XExtension!", extClass);
    return nil;
}

+ (void)performSelectorInBackgroundWithTarget:(id)target selector:(SEL)aSelector withObject:(id)anObject
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
            target, KEY_TARGET,
            [NSValue valueWithPointer:aSelector], KEY_SELECTOR,
            anObject, KEY_OBJECT,
            nil];

    [sSelPerformer performSelectorInBackground:@selector(performWithArgs:) withObject:args];
}

- (void) performWithArgs:(NSDictionary *)args
{
    @autoreleasepool
    {
        id target = [args objectForKey:KEY_TARGET];
        id anObj = [args objectForKey:KEY_OBJECT];
        SEL selector = [[args objectForKey:KEY_SELECTOR] pointerValue];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:selector withObject:anObj];
#pragma clang diagnostic pop
    }
}

+ (NSString*) getIpFromDebugConfig
{
    //读取配置信息
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString* xmlFile = [documentDirectory stringByAppendingFormat:@"%@%@", FILE_SEPARATOR, DEBUG_CONFIG_FILE];
    NSError* __autoreleasing error;
    NSString *xmlStr = [[NSString alloc] initWithContentsOfFile:xmlFile encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        return nil;
    }
    APDocument* doc = [APDocument documentWithXMLString:xmlStr];
    APElement *rootElem = [doc rootElement];
    APElement *socketElem = [rootElem firstChildElementNamed:TAG_SOCKET];
    NSString* ip = [socketElem valueForAttributeNamed:ATTR_IP];
    return ip;
}

+ (NSString*) getWorkDir
{
    XConfiguration *config = [XConfiguration getInstance];
    return [config systemWorkspace];
}

+ (NSString*)resolveSplashScreenImageResourceWithOrientation:(UIInterfaceOrientation)orientation
{
    NSString *launchImageFile = [[NSBundle mainBundle] objectForInfoDictionaryKey:UI_LAUNCH_IMAGE_FILE_KEY];
    launchImageFile = launchImageFile ? launchImageFile : SPLASH_FILE_NAME;

    NSString *resolvedImage = launchImageFile;
    if ([UIDevice deviceType] & IPHONE5)
    {
        // 处理当前设备为iPhone 5 或 iPod Touch 5th-gen的情况
        resolvedImage = [NSString stringWithFormat:@"%@-568h", launchImageFile];
    }
    else if(([UIDevice deviceType] & IPAD))
    {
        // 处理当前设备为iPad的情况
        switch (orientation)
        {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                resolvedImage = [NSString stringWithFormat:@"%@-Landscape", launchImageFile];
                break;
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
            default:
                resolvedImage = [NSString stringWithFormat:@"%@-Portrait", launchImageFile];
                break;
        }
    }
    return resolvedImage;
}

+ (NSString *)buildConfigFilePathWithAppId:(NSString *)appId
{
    // 应用配置文件所在路径形如：~/Documents/xface3/apps/appId/app.xml
    NSAssert(([appId length] > 0), nil);
    NSString *appInstallationPath = [[XConfiguration getInstance] appInstallationDir];
    NSString *appConfigFilePath = [appInstallationPath stringByAppendingFormat:@"%@%@%@", appId, FILE_SEPARATOR, APPLICATION_CONFIG_FILE_NAME];

    return appConfigFilePath;
}

+ (NSString *) buildPreinstalledAppSrcPath:(NSString *)appId
{
    // 构造预装应用源码所在绝对路径，路径形如：<Application_Home>/xFace.app/www/preinstalledApps/appSrcDirName/
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSString *preinstalledAppsPath = [mainBundle pathForResource:PREINSTALLED_APPLICATIONS_FLODER ofType:nil inDirectory:APPLICATION_WWW_FOLDER];
    if (![preinstalledAppsPath length])
    {
        return nil;
    }
    
    NSAssert([appId length], nil);
    NSString *appSrcPath = [preinstalledAppsPath stringByAppendingFormat:@"%@%@%@", FILE_SEPARATOR, appId, FILE_SEPARATOR];
    return appSrcPath;
}

+ (NSString *)buildWorkspaceAppSrcPath:(NSString *)appId
{
    NSString *appSrcPath = [[XConfiguration getInstance] appInstallationDir];
    
    // 工作空间下应用安装路径形如：<Application_Home>/Documents/xface3/apps/appId/
    NSAssert([appId length], nil);
    appSrcPath = [appSrcPath stringByAppendingFormat:@"%@%@", appId, FILE_SEPARATOR];
    return appSrcPath;
}

+ (id)rootViewController
{
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    XRuntime *runtime = [appDelegate performSelector:@selector(runtime)];
    id rootViewController = [runtime rootViewController];
    return rootViewController;
}

@end
