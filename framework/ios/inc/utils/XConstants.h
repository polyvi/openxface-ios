
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
//  XConstants.h
//  xFace
//
//

// 本文件仅定义xFace全局常量
#define FILE_SEPARATOR                           @"/"
#define XFACE_WORKSPACE_FOLDER                   @"xface3"
#define XFACE_PLAYER_WORKSPACE                   @"xface_player"
#define XFACE_PLAYER_PACKAGE_NAME                @"xface_player.zip"
#define APPLICATION_INSTALLATION_FOLDER          @"apps"
#define APPLICATION_ICONS_FOLDER                 @"app_icons"
#define APPLICATION_CONFIG_FILE_NAME             @"app.xml"
#define PRE_SET_DIR_NAME                         @"pre_set"
#define ENCRYPT_CODE_DIR_NAME                    @"encrypt_code"
#define DEFAULT_APP_ID_FOR_PLAYER                @"app"
#define DEFAULT_APP_START_PAGE                   @"index.html"
#define XFACE_JS_FILE_NAME                       @"xface.js"
#define XFACE_DATA_PLIST_NAME                    @"data.plist"
#define APPLICATION_KEY                          @"app"
#define JS_CALLBACK_KEY                          @"callback"
#define APP_WORKSPACE_FOLDER                     @"workspace"
#define SPLASH_FILE_NAME                         @"xface_logo"
#define APP_DATA_DIR_FOLDER                      @"data"
#define APP_TYPE_XAPP                            @"xapp"
#define APP_TYPE_NAPP                            @"napp"
#define ZIP_PACKAGE_SUFFIX                       @".zip"
#define APP_PACKAGE_SUFFIX_XPA                   @".xpa"          //离散文件形式的web应用安装包
#define APP_PACKAGE_SUFFIX_NPA                   @".npa"          //描述native应用package
#define ENCRYPE_CODE_PACKAGE_NAME                @"jscore.zip"    //加密代码包的包名
#define APP_DATA_KEY_FOR_START_PARAMS            @"start_params"  //启动参数在xapp通讯数据中的key
#define NATIVE_APP_CUSTOM_URL_PARAMS_SEPERATOR   @"://"           //custom url中scheme与params之间的分隔符

#define EXTENSION_AMS_NAME                       @"AMS"
#define EXTENSION_LOCAL_STORAGE_NAME             @"LocalStorage"

// xFace.app下相关目录及资源命名
#define PREINSTALLED_APPLICATIONS_FLODER         @"preinstalledApps"
#define APPLICATION_WWW_FOLDER                   @"www"
#define APP_DATA_PACKAGE_NAME_UNDER_WORKSPACE    @"workspace.zip"

// xFacePlayer.app下相关目录命名
// TODO:常量命名不准确，需要进一步调整
#define XFACE_WORKSPACE_NAME_UNDER_APP           @"xface"
#define APPLICATION_PREPACKED_PACKAGE_FOLDER     @"www"

// userApps.xml
#define USER_APPS_FILE_NAME                      @"userApps.xml"
#define TAG_APPLICATIONS                         @"applications"
#define APP_ROOT_PREINSTALLED                    @"preinstalled"
#define APP_ROOT_WORKSPACE                       @"workspace"
#define ATTR_NAME                                @"name"
#define ATTR_ID                                  @"id"
#define ATTR_VALUE                               @"value"

// key in data.plist
#define XFACE_DATA_KEY_DEVICETOKEN               @"deviceToken"

//tag in debug.xml
#define DEBUG_CONFIG_FILE                        @"debug.xml"
#define TAG_ROOT                                 @"config"
#define TAG_SOCKET                               @"socketlog"
#define ATTR_IP                                  @"hostip"

// config.xml相关常量定义
#define SYSTEM_CONFIG_FILE_NAME                  @"config.xml"
#define TAG_APP_PACKAGE                          @"app_package"
#define TAG_EXTENSION                            @"extension"
#define TAG_PREFERENCE                           @"preference"
#define USE_PLAYER_MODE_PROPERTY                 @"UsePlayerMode"
#define ENGINE_VERSION                           @"EngineVersion"
#define ENGINE_BUILD                             @"EngineBuild"
#define SHOW_SPLASH_SCREEN                       @"ShowSplashScreen"
#define SPLASH_SCREEN_DELAY_DURATION             @"SplashScreenDelayDuration"
#define EXTENSIONS_PROP_NAME                     @"Extensions"
#define ROTATE_ORIENTATION_PROP_NAME             @"RotateOrientationForbidden"
#define AUTO_HIDE_SPLASH_SCREEN                  @"AutoHideSplashScreen"
#define DISALLOW_OVERSCROLL                      @"DisallowOverscroll"
#define FADE_SPLASH_SCREEN                       @"FadeSplashScreen"
#define FADE_SPLASH_SCREEN_DURATION              @"FadeSplashScreenDuration"
#define SHOW_SPLASH_SCREEN_SPINNER               @"ShowSplashScreenSpinner"
#define TOP_ACTIVITY_INDICATOR                   @"TopActivityIndicator"
#define CHECK_UPDATE_PROP_NAME                   @"CheckUpdate"
#define UPDATE_ADDRESS_PROP_NAME                 @"UpdateAddress"
#define SECURITY_SERVER_PROP_NAME                @"SecurityServer"
#define ENABLE_VIEWPORT_SCALE_PROP_NAME          @"EnableViewportScale"
#define MEDIA_PLAYBACK_REQUIRES_USER_ACTION_PROP_NAME   @"MediaPlaybackRequiresUserAction"
#define ALLOW_INLINE_MEDIA_PLAYBACK_PROP_NAME    @"AllowInlineMediaPlayback"

// info.plist中定义的常量
#define UI_ORIENTAIONS_TAG                       @"UISupportedInterfaceOrientations"
#define UI_LAUNCH_IMAGE_FILE_KEY                 @"UILaunchImageFile"

// notification name
#define WEBVIEW_DID_FINISH_LOAD_NOTIFICATION             @"WebViewDidFinishLoadNotification"
#define WEBVIEW_DID_START_LOAD_NOTIFICATION              @"WebViewDidStartLoadNotification"
#define XAPPLICATION_DID_FINISH_INSTALL_NOTIFICATION     @"XApplicationDidFinishInstallNotification"
#define XAPPLICATION_DID_FINISH_CLOSE_NOTIFICATION       @"XApplicationDidFinishCloseNotification"
#define XAPPLICATION_CLOSE_NOTIFICATION                  @"XApplicationCloseNotification"
#define XAPPLICATION_SEND_MESSAGE_NOTIFICATION           @"XApplicationSendMessageNotification"
#define XUIAPPLICATION_TIMEOUT_NOTIFICATION              @"XUIApplicationTimeoutNotification"
#define UPDATE_TIMEOUT_INTERVAL_NOTIFICATION             @"UpdateTimeoutIntervalNotification"
#define DOCUMENT_EVENT_NOTIFICATION                      @"DocumentEventNotification"



#define SYSTEM_VERSION_NOT_LOWER_THAN(X) ([[[UIDevice currentDevice] systemVersion] compare:X options:NSNumericSearch] != NSOrderedAscending)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IPHONE5_MAIN_SCREEN_BOUNDS_HEIGHT        568

#define WILDCARDS               @"*"


