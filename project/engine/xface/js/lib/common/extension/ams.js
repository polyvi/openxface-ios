
/*
 Copyright 2012-2013, Polyvi Inc. (http://www.xface3.com)
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

/**
  *该模块定义了xFace应用相关的一系列操作，包括应用的安装，运行，卸载，更新等
  *@module ams
  *@main
  */


/**
  * 该类定义了xFace应用管理的基础api，包括应用的安装、卸载、启动、关闭、更新等（Android, iOS, WP8）<br/>
  * 该类不能通过new来创建相应的对象，可以通过xFace.AMS来直接使用该类中定义的方法
  * @class AMS
  * @platform Android, iOS, WP8
  * @since 3.0.0
  */
var argscheck = require('xFace/argscheck');
var exec = require('xFace/exec');
var xFace = require('xFace');
var localStorage = require('xFace/localStorage');
var AMS = function(){
};

/**
 * 安装一个app（Android, iOS, WP8）
 * @example
        function successCallback(info) {
            console.log(info.appid);
            console.log(info.type);
        };

        function errorCallback(error) {
            console.log(error.appid);
            console.log(error.type);
            console.log(error.errorcode);
        };

        function statusChanged(status) {
            if (AmsState.INSTALL_INSTALLING == status.progress) {
                console.log("installing...");
            }

            if (AmsState.INSTALL_FINISHED == status.progress) {
                console.log("install was done!");
            }
        };

        xFace.AMS.installApplication ("geolocation.zip",successCallback，errorCallback, statusChanged);
 * @method installApplication
 * @param {String} packagePath              app安装包所在相对路径（相对于当前app的工作空间）
 * @param {Function} [successCallback]        成功时的回调函数
 * @param {Object} successCallback.info   与app相关信息object,每个object包含如下属性：
 * @param {Number} successCallback.info.type   操作类型,具体类型参考<a href="../classes/AmsOperationType.html" class="crosslink">AmsOperationType</a>
 * @param {String} successCallback.info.appid  app的id号
 * @param {Function} [errorCallback]          失败时的回调函数
 * @param {Object} errorCallback.error   包含错误信息的对象，每个object包含如下属性：
 * @param {Number} errorCallback.error.type  发生错误的ams操作类型,具体类型参考<a href="../classes/AmsOperationType.html" class="crosslink">AmsOperationType</a>
 * @param {String} errorCallback.error.appid  发生错误的app的id号
 * @param {Number} errorCallback.error.errorcode  错误码，具体错误码参考<a href="../classes/AmsError.html" class="crosslink">AmsError</a>
 * @param {Function} [statusChangedCallback]  安装过程的状态回调函数
 * @param {Object} statusChangedCallback.status 安装过程状态，包含如下属性:
 * @param {Number} statusChangedCallback.status.type 指示当前状态是install，uninstall，或update，参考{{#crossLink "AmsOperationType"}}{{/crossLink}}
 * @param {Number} statusChangedCallback.status.progress 安装过程状态码，具体值可参考{{#crossLink "AmsState"}}{{/crossLink}}
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
AMS.prototype.installApplication = function( packagePath, successCallback, errorCallback, statusChangedCallback)
{
   argscheck.checkArgs('sFFF', 'AMS.installApplication', arguments);
   if(!packagePath || typeof packagePath  != "string"){
        if(typeof errorCallback === "function") {
            errorCallback();
        }
        return;
    }
    exec(successCallback, errorCallback, statusChangedCallback, "AMS", "installApplication",[packagePath]);
};

/**
 * 卸载app（Android, iOS, WP8）
 * @example
        function successCallback(info){
            console.log(info.appid);
            console.log(info.type);
        };
        function errorCallback(error){
            console.log(error.appid);
            console.log(error.type);
            console.log(error.errorcode);
        };
        xFace.AMS.uninstallApplication ("mengfGeolocation",successCallback，errorCallback);
 * @method uninstallApplication
 * @param {String} appId                    用于标识待卸载app的id
 * @param {Function} [successCallback]         卸载成功时的回调函数
 * @param {Object}  successCallback.info   与app相关信息object,每个object包含如下属性：
 * @param {Number}  successCallback.info.type   操作类型,具体类型参考<a href="../classes/AmsOperationType.html" class="crosslink">AmsOperationType</a>
 * @param {String}  successCallback.info.appid  app的id号
 * @param {Function} [errorCallback]          卸载失败时的回调函数
 * @param {Object}  errorCallback.error      包含错误信息的对象，每个object包含如下属性：
 * @param {Number}  errorCallback.error.type  发生错误的ams操作类型,具体类型参考<a href="../classes/AmsOperationType.html" class="crosslink">AmsOperationType</a>
 * @param {String}  errorCallback.error.appid  发生错误的app的id号
 * @param {Object}  errorCallback.error.errorcode  错误码，具体错误码参考<a href="../classes/AmsError.html" class="crosslink">AmsError</a>
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
AMS.prototype.uninstallApplication = function( appId, successCallback, errorCallback)
{
   argscheck.checkArgs('sFF', 'AMS.uninstallApplication', arguments);
   if(!appId || typeof appId  != "string"){
        if(typeof errorCallback === "function") {
            errorCallback();
        }
        return;
    }
    exec(
    //Success callback
    function(s)
    {
        //删除app存储的数据
        localStorage.clearAppData(appId);
        successCallback(s);
    }, errorCallback, null, "AMS", "uninstallApplication",[appId]);
};

/**
 * 启动app（Android, iOS, WP8）
 * @example
        function successCallback(info){
            console.log(info.appid);
        };
        function errorCallback(error){
            console.log(error.appid);
        };
        if(isAndroid()){
            xFace.AMS.startApplication("appId", successCallback, errorCallback, "Admin;123");
        }
        if(isIOS()){
            xFace.AMS.startApplication("TodoListAppId", successCallback, errorCallback, "www.acme.com?Quarterly%20Report#200806231300");
        }
 * @method startApplication
 * @param {String} appId                    用于标识待启动app的id
 * @param {Function} [successCallback]        成功时的回调函数
 * @param {Object}  successCallback.info   与app相关信息object,每个object包含如下属性：
 * @param {String}  successCallback.info.appid  app的id号
 * @param {Function} [errorCallback]          失败时的回调函数
 * @param {Object}  errorCallback.error     包含错误信息的对象，每个object包含如下属性:
 * @param {String}  errorCallback.error.appid  发生错误的app的id号
 * @param {String}  [params] 程序启动参数，默认值为空 <br /> <a href="http://developer.apple.com/library/ios/#documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/AdvancedAppTricks/AdvancedAppTricks.html" class="crosslink">iOS: 请参考Custom URL Schemes</a>
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
AMS.prototype.startApplication = function(appId, successCallback, errorCallback, params)
{
    argscheck.checkArgs('s**S', 'AMS.startApplication', arguments);
    //appId check
    if(!appId || typeof appId  != "string"){
        if(typeof errorCallback === "function") {
            errorCallback("noId");
        }
        return;
    }
    var temp = arguments[1];

    //params check 1
    if( arguments.length == 2 && typeof arguments[1] === "string")
    {
        successCallback = null;
        errorCallback = null;
        params = temp;
    }

    //params check 2
    if(params === null || params === undefined)
    {
        params = "";
    }


    exec(successCallback, errorCallback, null, "AMS", "startApplication",[appId,params]);
};

/**
 * 关闭当前应用app（Android, iOS, WP8）
 * 如果当前只有一个app,在android平台上则退出xFace;在iOS平台上由于系统限制不退出xFace!!
 * @example
        xFace.AMS.closeApplication();
 * @method closeApplication
 * @platform Android, iOS, WP8
 * @since 3.0.0
 * @deprecated 若应用想关闭自己，请调用xFace.app.close()
 */
AMS.prototype.closeApplication = function()
{
    // FIXME: 接口应该设计为ams.closeApplication(appId)
    require('xFace/extension/privateModule').execCommand("xFace_close_application:", []);
};

/**
 * 列出系统已经安装的app列表（Android, iOS, WP8）
 * @example
         function successCallback(apps) {
            var count = apps.length;
            alert(count + " InstalledApps.");
            for(var i = 0; i < count; i++) {
                console.log(apps[i].appid);
                console.log(apps[i].name);
                console.log(apps[i].icon);
                console.log(apps[i].icon_background_color);
                console.log(apps[i].version);
                console.log(apps[i].type);
            }
        };
        function errorCallback() {
            alert("list fail!");
        };
       xFace.AMS.listInstalledApplications(successCallback，errorCallback);
 * @method listInstalledApplications
 * @param {Function} successCallback       获取列表成功时的回调函数
 * @param {Array}  successCallback.app 包含当前已经安装的app列表，每个app对象包含如下属性,
 * @param {String} successCallback.app.appid App的唯一id
 * @param {String} successCallback.app.name  App的名字
 * @param {String} successCallback.app.icon  App的图标的url
 * @param {String} successCallback.app.icon_background_color  App的图标背景颜色
 * @param {String} successCallback.app.version  App的版本
 * @param {String} successCallback.app.type  App的类型(nativeApp: napp; webApp:xapp或app)
 * @param {Function} [errorCallback]         获取列表失败时的回调函数
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
AMS.prototype.listInstalledApplications = function(successCallback, errorCallback)
{
    argscheck.checkArgs('fF', 'AMS.listInstalledApplications', arguments);
    exec(successCallback, errorCallback, null, "AMS", "listInstalledApplications",[]);
};

/**
 * 获取默认app可以安装的预设app安装包列表（Android, iOS, WP8）
 * 列表中每一项为一个app安装包的相对路径，可以直接安装/更新
 * @example
        function successCallback(packages){
            var count = packages.length;
            alert(count + " pre set app(s).");
            for(var i = 0; i < count; i++){
                alert(packages[i]);
            }
        }
        function errorCallback(){
            alert("list fail!");
        };
       xFace.AMS.listPresetAppPackages(successCallback，errorCallback);
 * @method listPresetAppPackages
 * @param {Function} successCallback     成功时的回调函数
 * @param {Array} successCallback.packages  预置包名数组对象，每一项均为预置包名
 * @param {Function} [errorCallback]           失败时的回调函数
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
AMS.prototype.listPresetAppPackages = function(successCallback, errorCallback)
{
    argscheck.checkArgs('fF', 'AMS.listPresetAppPackages', arguments);
    exec(successCallback, errorCallback, null, "AMS", "listPresetAppPackages", []);
};

/**
 * 更新app（Android, iOS, WP8）
 * @example
        function successCallback(info){
            console.log(info.appid);
            console.log(info.type);
        };
        function errorCallback(error){
            console.log(error.appid);
            console.log(error.type);
            console.log(error.errorcode);
        };
       xFace.AMS.updateApplication("geolocation.zip",successCallback，errorCallback);
 * @method updateApplication
 * @param {String} packagePath              app更新包所在相对路径（相对于当前app的工作空间）
 * @param {Function} [successCallback]        更新成功时的回调函数
 * @param {Object}  successCallback.info   与app相关信息object,每个object包含如下属性：
 * @param {Number}  successCallback.info.type   操作类型,具体类型参考<a href="../classes/AmsOperationType.html" class="crosslink">AmsOperationType</a>
 * @param {String}  successCallback.info.appid  app的id号
 * @param {Function} [errorCallback]          更新失败时的回调函数
 * @param {Object}  errorCallback.error     包含错误信息的对象，每个object包含如下属性：
 * @param {Number}  errorCallback.error.type  发生错误的ams操作类型,具体类型参考<a href="../classes/AmsOperationType.html" class="crosslink">AmsOperationType</a>
 * @param {String}  errorCallback.error.appid  发生错误的app的id号
 * @param {Object}  errorCallback.error.errorcode  错误码，具体错误码参考<a href="../classes/AmsError.html" class="crosslink">AmsError</a>
 * @param {Function} [statusChangedCallback]  更新过程的状态回调函数
 * @param {Object} statusChangedCallback.status 更新过程状态，包含如下属性:
 * @param {Number} statusChangedCallback.status.type 指示当前状态是install，uninstall，或update，参考{{#crossLink "AmsOperationType"}}{{/crossLink}}
 * @param {Number} statusChangedCallback.status.progress 安装过程状态码，具体值可参考{{#crossLink "AmsState"}}{{/crossLink}}@platform Android, iOS
 * @since 3.0.0
 * @platform Android, iOS, WP8
 */
AMS.prototype.updateApplication = function( packagePath, successCallback, errorCallback, statusChanged)
{
   argscheck.checkArgs('sFFF', 'AMS.updateApplication', arguments);
   if(!packagePath || typeof packagePath  != "string"){
        if(typeof errorCallback === "function") {
            errorCallback();
        }
        return;
    }
    exec(successCallback, errorCallback, statusChanged,"AMS", "updateApplication",[packagePath]);

};

/**
 * 获取startApp的app描述信息（Android, iOS, WP8）
 * @example
       function successCallback(app){
            console.log(app.appid);
            console.log(app.name);
            console.log(app.icon);
            console.log(app.icon_background_color);
            console.log(app.version);
            console.log(app.type);
        };
        function errorCallback(){
            alert("failed");
        };
       xFace.AMS.getStartAppInfo(successCallback，errorCallback);
 * @method getStartAppInfo
 * @param {Function} successCallback      成功时的回调函数
 * @param {Object} successCallback.app    当前启动的app的信息，每个app对象包含如下属性,
 * @param {String} successCallback.app.appid,  App的唯一id
 * @param {String} successCallback.app.name,  App的名字
 * @param {String} successCallback.app.icon  App的图标的url
 * @param {String} successCallback.app.icon_background_color  App的图标背景颜色
 * @param {String} successCallback.app.version  App的版本
 * @param {String} successCallback.app.type  App的类型(nativeApp:napp; webApp:xapp或app)
 * @param {Function} [errorCallback]        失败时的回调函数
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
AMS.prototype.getStartAppInfo = function(successCallback, errorCallback)
{
    argscheck.checkArgs('fF', 'AMS.getStartAppInfo', arguments);
    exec(successCallback, errorCallback, null, "AMS", "getStartAppInfo", []);
};

module.exports = new AMS();
