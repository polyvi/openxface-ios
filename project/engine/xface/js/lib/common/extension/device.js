
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

/**
 * 该模块定义一些设备及其能力相关的信息。
 * @module device
 * @main   device
 */
var argscheck = require('xFace/argscheck'),
    channel = require('xFace/channel'),
    exec = require('xFace/exec');

// Tell xFace channel to wait on the onxFaceInfoReady event
channel.waitForInitialization('onxFaceInfoReady');

/**
 * 用于提供设备及其能力等相关信息（Android，iOS, WP8）<br/>
 * 该类不能通过new来创建相应的对象，只能通过device对象来直接访问其属性<br/>
 *（该类中定义的设备信息由引擎自动初始化，开发人员在deviceready事件触发之后可以访问）
 * @example
        function init() {
            document.addEventListener("deviceready", deviceInfo, true);
        }
        var deviceInfo = function() {
            console.log("OS platform = " + device.platform);
            console.log("OS version = " + device.version);
            console.log("device model = " + device.model);
            console.log("device uuid = " + device.uuid);
            console.log("device imsi = " + device.imsi);
            console.log("device userAgent = " + navigator.userAgent);
            console.log("device name = " + device.name);
            console.log("device availWidth = " + screen.availWidth);
            console.log("device availHeight = " + screen.availHeight);
            console.log("device width = " + device.width);
            console.log("device height = " + device.height);
            console.log("device colorDepth = " + screen.colorDepth);
            console.log("isCameraAvailable = " + device.isCameraAvailable);
            console.log("isFrontCameraAvailable = " + device.isFrontCameraAvailable);
            console.log("isCompassAvailable = " + device.isCompassAvailable);
            console.log("isAccelerometerAvailable = " + device.isAccelerometerAvailable);
            console.log("isLocationAvailable = " + device.isLocationAvailable);
            console.log("isWiFiAvailable = " + device.isWiFiAvailable);
            console.log("isTelephonyAvailable = " + device.isTelephonyAvailable);
            console.log("isSmsAvailable = " + device.isSmsAvailable);
        };
 * @class Device
 * @since 3.0.0
 * @platform Android, iOS, WP8
 */
function Device() {
    /**
     * 用于标识设备的操作系统平台（Android, iOS, WP8）
     * @property platform
     * @default null
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.platform = null;
    /**
     * 用于标识设备的操作系统版本号（Android, iOS, WP8）
     * @property version
     * @default null
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.version = null;
    /**
     * 用于标识设备的名字（Android, iOS, WP8）
     * @property name
     * @default null
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.name = null;
    /**
     * 用于标识设备的Universally Unique Identifier (UUID).（Android, iOS, WP8）
     * @property uuid
     * @default null
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.uuid = null;
    /**
     * 用于标识设备的International Mobile Equipment Identity(IMEI)（Android）
     * @property imei
     * @default null
     * @type String
     * @platform Android
     * @since 3.0.0
     */
    this.imei = null;
    /**
     * 用于标识设备的国际移动用户识别码(IMSI)（Android）
     * @property imsi
     * @default null
     * @type String
     * @platform Android
     * @since 3.0.0
     */
    this.imsi = null;
    /**
     * 用于标识xFace的引擎版本号（Android, iOS, WP8）
     * @property xFaceVersion
     * @default null
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.xFaceVersion = null;
    /**
     * 用于标识程序包的产品版本号（应用版本号），可显示在设备系统软件安装列表中（Android, iOS, WP8）
     * @property productVersion
     * @default null
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.productVersion = null;
    /**
     * 设备的屏幕宽度(单位像素)（Android, iOS, WP8）
     * @property width
     * @default 0
     * @type Number
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.width = 0;
    /**
     * 设备的物理高度(单位像素)（Android, iOS, WP8）
     * @property height
     * @default 0
     * @type Number
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.height = 0;
    /**
     * 用于标识设备的照相机功能是否可用（Android, iOS, WP8）
     * @property isCameraAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.isCameraAvailable = false;
    /**
     * 用于标识设备的前置摄像头功能是否可用（Android, iOS, WP8）
     * @property isFrontCameraAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.isFrontCameraAvailable = false;
    /**
     * 用于标识设备的指南针功能是否可用（Android, iOS, WP8）
     * @property isCompassAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.isCompassAvailable = false;
    /**
     * 用于标识设备的加速计功能是否可用（Android, iOS, WP8）
     * @property isAccelerometerAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.isAccelerometerAvailable = false;
    /**
     * 用于标识设备的定位功能是否可用（Android, iOS, WP8）
     * @property isLocationAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.isLocationAvailable = false;
    /**
     * 用于标识设备的WIFI功能是否可用（Android, iOS, WP8）
     * @property isWiFiAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.isWiFiAvailable = false;
    /**
     * 用于标识设备的电话功能是否可用（Android, iOS, WP8）
     * @property isTelephonyAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.isTelephonyAvailable = false;
    /**
     * 用于标识设备的短信功能是否可用（Android, iOS, WP8）
     * @property isSmsAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.isSmsAvailable = false;
    /**
     * 用于标识设备的设备型号(model)（Android, iOS, WP8）
     * @property model
     * @default null
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.model = null;

    var me = this;

    channel.onxFaceReady.subscribe(function() {
        me.getInfo(function(info) {
            me.platform = info.platform;
            me.version = info.version;
            me.model  = info.model;
            me.name = info.name;
            me.uuid = info.uuid;
            /**ios不支持获取IMEI*/
            me.imei = info.imei === undefined ? "not support" : info.imei;
            /**ios不支持获取IMSI*/
            me.imsi = info.imsi === undefined ? "not support" : info.imsi;
            me.xFaceVersion = info.xFaceVersion;
            me.productVersion = info.productVersion;
            me.width = info.width;
            me.height = info.height;
            /** 获取设备能力*/
            me.isCameraAvailable = info.isCameraAvailable;
            me.isFrontCameraAvailable = info.isFrontCameraAvailable;
            me.isCompassAvailable = info.isCompassAvailable;
            me.isAccelerometerAvailable = info.isAccelerometerAvailable;
            me.isLocationAvailable = info.isLocationAvailable;
            me.isWiFiAvailable = info.isWiFiAvailable;
            me.isTelephonyAvailable = info.isTelephonyAvailable;
            me.isSmsAvailable = info.isSmsAvailable;

            channel.onxFaceInfoReady.fire();
        },function(e) {
            console.log("Error initializing xFace: " + e);
        });
    });
}

/**
 * 获得设备的相关属性（Android, iOS, WP8）<br/>
 * @example
        var errorCallback = function(){};
        var successCallback = function(deviceInfo) {
            console.log("OS platform = " + deviceInfo.platform);
            console.log("OS version = " + deviceInfo.version);
            console.log("device model = " + deviceInfo.model);
            console.log("device uuid = " + deviceInfo.uuid);
            console.log("device imsi = " + deviceInfo.imsi);
            console.log("device userAgent = " + navigator.userAgent);
            console.log("device name = " + deviceInfo.name);
            console.log("device availWidth = " + screen.availWidth);
            console.log("device availHeight = " + screen.availHeight);
            console.log("device width = " + device.width);
            console.log("device height = " + device.height);
            console.log("device colorDepth = " + screen.colorDepth);
            console.log("isCameraAvailable = " + deviceInfo.isCameraAvailable);
            console.log("isFrontCameraAvailable = " + deviceInfo.isFrontCameraAvailable);
            console.log("isCompassAvailable = " + deviceInfo.isCompassAvailable);
            console.log("isAccelerometerAvailable = " + deviceInfo.isAccelerometerAvailable);
            console.log("isLocationAvailable = " + deviceInfo.isLocationAvailable);
            console.log("isWiFiAvailable = " + deviceInfo.isWiFiAvailable);
            console.log("isTelephonyAvailable = " + deviceInfo.isTelephonyAvailable);
            console.log("isSmsAvailable = " + deviceInfo.isSmsAvailable);
        }
        device.getInfo(successCallback, errorCallback);
 * @method getInfo
 * @deprecated 该类中定义的设备信息由引擎自动初始化，开发人员在deviceready事件触发之后可以访问。
 * @param {Function} [successCallback] 成功回调函数.
 * @param {String} successCallback.uuid 设备的Universally Unique Identifier (UUID).（Android, iOS, WP8）
 * @param {String} successCallback.imei 设备的International Mobile Equipment Identity(IMEI).（Android）
 * @param {String} successCallback.imsi 设备的的国际移动用户识别码(IMSI)（Android）
 * @param {String} successCallback.version 设备的os version.（Android, iOS, WP8）
 * @param {String} successCallback.platform 设备的操作系统平台如android或iOS.（Android, iOS, WP8）
 * @param {String} successCallback.name 设备的product name.（Android, iOS, WP8）
 * @param {String} successCallback.xFaceVersion 设备的xFace的版本号.（Android, iOS, WP8）
 * @param {String} successCallback.productVersion 程序包的产品名称，其值就是<manifest> 的标签versionName属性值.（Android, iOS, WP8）
 * @param {String} successCallback.model 设备的的设备型号(model).（Android, iOS, WP8）
 * @param {Number} successCallback.width 设备的屏幕宽度(单位像素).（Android, iOS, WP8）
 * @param {Number} successCallback.height 设备的的屏幕高度(单位像素).（Android, iOS, WP8）
 * @param {Boolean} successCallback.isCameraAvailable 设备的照相机功能是否可用.（Android, iOS, WP8）
 * @param {Boolean} successCallback.isFrontCameraAvailable 设备的前置摄像头是否可用.（Android, iOS, WP8）
 * @param {Boolean} successCallback.isCompassAvailable 设备的指南针功能是否可用.（Android, iOS, WP8）
 * @param {Boolean} successCallback.isAccelerometerAvailable 设备的加速度计功能是否可用.（Android, iOS, WP8）
 * @param {Boolean} successCallback.isTelephonyAvailable 设备的电话功能是否可用.（Android, iOS, WP8）
 * @param {Boolean} successCallback.isSmsAvailable 设备的短信功能是否可用.（Android, iOS, WP8）
 * @param {Boolean} successCallback.isLocationAvailable 设备的定位功能是否可用.（Android, iOS, WP8）
 * @param {Boolean} successCallback.isWiFiAvailable 设备的WIFI功能是否可用.（Android, iOS, WP8）
 * @param {Function} [errorCallback] 失败回调函数.
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Device.prototype.getInfo = function(successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'Device.getInfo', arguments);
    exec(successCallback, errorCallback, null, "Device", "getDeviceInfo", []);
};

module.exports = new Device();