
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
//  XUtils.h
//  xFace
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 如果对象为nil,则将其转换为NSNull
// 主要用于向集合中添加对象时，确保对象不为nil
#define CAST_TO_NSNULL_IF_NIL(obj)                 ((obj) ? (obj) : [NSNull null])

#define CAST_TO_NIL_IF_NSNULL(obj)                 ([(obj) isEqual:[NSNull null]] ? nil : (obj))

#define CAST_TO_POINTER_TO_NSERROR_IF_NIL(obj)      do{ \
                                                        if(!obj) { \
                                                            __autoreleasing NSError *err = nil; \
                                                            obj = &err; \
                                                        } \
                                                    } while(0)


@class XAppInfo;
@class APDocument;

/**
	提供常用工具方法
 */
@interface XUtils : NSObject
{
}

/**
	生成一个整型随机数
	@returns 生成后的随机数
 */
+ (NSInteger) generateRandomId;

/**
	解压package到指定目录
	@param srcPath package所在目录
	@param dstPath package解压后所在目录
	@returns 解压成功返回YES,否则返回NO
 */
+ (BOOL) unpackPackageAtPath:(NSString *)srcPath toPath:(NSString *)dstPath;

/**
	解析xml文件
	@param path xml文件所在绝对路径
	@param delegate 用于解析xml文件的delegate
	@returns 成功返回YES,失败返回NO
 */
+ (BOOL) parseXMLFileAtPath:(NSString *)path withDelegate:(id <NSXMLParserDelegate>)delegate;

/**
	解析xml数据
	@param data 待解析的xml数据
	@param delegate 用于解析xml数据的delegate
	@returns 成功返回YES，失败返回NO
 */
+ (BOOL) parseXMLData:(NSData *)data withDelegate:(id <NSXMLParserDelegate>)delegate;

/**
	读取package中的file数据
	@param fileName 待读取的文件名称
	@param packagePath 包含待读取文件的package的绝对路径
	@returns 成功时返回读取到的文件数据，失败时返回nil
 */
+ (NSData *) readFile:(NSString *)fileName inPackage:(NSString *)packagePath;

/**
	解析app.xml文档的数据，从中得到APPInfo.
	@param xmlData 待解析的app.xml文档数据
	@returns 成功时返回存有appinfo的XAppInfo对象,失败时返回nil
 */
+ (XAppInfo *) getAppInfoFromAppXMLData:(NSData *)xmlData;

/**
	从应用安装包中获取应用相关信息.
	解析应用安装包中的配置文件，并根据配置数据生成相应的对象.
	@param appPackagePath 待获取应用配置信息的应用安装包
	@returns 成功时返回XAppInfo对象,失败时返回nil
 */
+ (XAppInfo *) getAppInfoFromAppPackage:(NSString *)appPackagePath;

/**
    根据app.xml所在路径获取并解析app.xml数据以获取应用相关信息
    @param appConfigFilePath 待解析的app.xml所在绝对路径
    @returns 成功时返回XAppInfo对象,失败时返回nil
 */
+ (XAppInfo *) getAppInfoFromConfigFileAtPath:(NSString *)appConfigFilePath;

/**
    根据工作空间路径转换path为绝对路径.
    如果path为空串或为nil,则返回值为workspace
    转换后的path要求在workspace下:
        workspace: <Application_Home>/Documents/xface3/apps/appid/workspace
        - 1)  path: /download/app.zip 或 download/app.zip  <br />
              resolve后为： ~/Documents/xface3/apps/appid/workspace/download/app.zip  <br />
              正确 <br />
        - 2)  path: /app.zip 或 app.zip <br />
              resolve后为： ~/Documents/xface3/apps/appid/workspace/app.zip  <br />
              正确  <br />
        - 3)  path: /../app.zip 或 ../app.zip <br />
              resolve后为： ~/Documents/xface3/apps/appid/app.zip <br />
              错误，返回nil <br />
    @param path 待转换的路径
    @param workspace 工作空间，作为base path
    @returns 成功时返回转换后的路径，失败时返回nil
 */
+ (NSString *) resolvePath:(NSString *)path usingWorkspace:(NSString *)workspace;

/**
	根据应用id,应用图标相对路径生成应用图标最终放置的目标路径.
	生成的目标路径要求在<Application_Home>/Documents/xface3/app_icons/appId/目录下.
	如果relativeIconPath为空串或为nil,则返回值为<Application_Home>/Documents/xface3/app_icons/appId
	@param appId 用于标识图标所属的应用，并将其作为应用图标放置的目标路径的一部分
	@param relativeIconPath 应用图标所在相对路径，通过解析应用配置文件获得
	@returns 成功时返回生成的应用图标最终放置的目标路径，失败时返回nil
 */
+ (NSString *) generateAppIconPathUsingAppId:(NSString *)appId relativeIconPath:(NSString *)relativeIconPath;

/**
	保存文件数据到指定的文件中
	@param doc 待保存的文件数据
	@param filePath 待保存数据的文件的路径
	@returns 成功返回YES,失败返回NO
 */
+ (BOOL) saveDoc:(APDocument *)doc toFile:(NSString *)filePath;

/**
    读取系统配置文件中的preference信息
    @param keyName 配置项的名称
    @return 配置项的值，不存在则返回nil
 */
+ (id) getPreferenceForKey:(NSString *)keyName;

/**
   判断是否为player模式
 */
+ (BOOL) isPlayer;

/**
 读取documents目录下的data.plist，并取出某个配置项的值
 @param key 配置关键字
 @return 配置项的值，不存在则返回nil
 */
+ (id) getValueFromDataForKey:(id)key;

/**
 设置documents目录下的data.plist中某项目的值，如果key不存在，则新增项目
 @param key 配置关键字
 @param value 配置项的值
 */
+ (void) setValueToDataForKey:(id)key value:(id)value;

/**
    生成某个扩展方法的js回调注册用的key，如果传入的extClass不是扩展类对象，直接返回nil
    @param extClass 回调所对应的扩展类的Class名称
    @param extMethod 回调对应的扩展方法名称
    @return 注册js回调的key
 */
+ (NSString *)generateJsCallbackRegistryKey:(NSString *)extClass withMethod:(NSString *)extMethod;

/**
    后台执行selector
    @param target 执行selector的对象
    @param aSelector 待执行的selector方法
    @param object 传给selector的参数
*/
+ (void) performSelectorInBackgroundWithTarget:(id)target selector:(SEL)aSelector withObject:(id)anObject;

/**
    从debug.xml获取ip地址
 */
+ (NSString*) getIpFromDebugConfig;

/**
    player返回：<Applilcation_Home>/Documents/xface_player/
    非player返回：<Applilcation_Home>/Documents/xface3/
 */
+ (NSString*) getWorkDir;

/**
    根据当前设备类型获取splashscreen图片的文件名
    @param orientation 当前设备屏幕朝向
    @returns 获取到的splashscreen图片的文件名
 */
+ (NSString*)resolveSplashScreenImageResourceWithOrientation:(UIInterfaceOrientation)orientation;

/**
    构造应用配置文件所在绝对路径
    @param appId 用于构造应用配置文件路径的app id
    @returns 应用配置文件所在绝对路径
 */
+ (NSString *)buildConfigFilePathWithAppId:(NSString *)appId;

/**
    根据app id构造预装应用源码所在绝对路径
    @param appId 应用id
    @returns 构造成功时返回预装应用所在绝对路径，失败时返回nil
 */
+ (NSString *) buildPreinstalledAppSrcPath:(NSString *)appId;

/**
    根据app id构造工作空间下应用源码所在绝对路径
    @param appId 应用id
    @returns 构造成功时返回工作空间下应用所在绝对路径，失败时返回nil
 */
+ (NSString *)buildWorkspaceAppSrcPath:(NSString *)appId;

/**
    获取rootViewController
 */
+ (id)rootViewController;

@end
