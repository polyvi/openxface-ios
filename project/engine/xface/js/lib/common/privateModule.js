
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
 * 该模块是私有模块，用于获取当前应用程序的ID，是否处于安全模式等
 */
var channel = require('xFace/channel');
//该变量用于保存当前应用的ID
var currentAppId = null;
var securityMode = false;
var privateModule = function() {
};

channel.waitForInitialization('onPrivateDataReady');

/**
 * 由引擎初始化数据
 */
privateModule.prototype.initPrivateData = function(initData) {
    currentAppId = initData[0];
    channel.onPrivateDataReady.fire();
};

privateModule.prototype.getAppId = function() {
    return currentAppId;
};

module.exports = new privateModule();
