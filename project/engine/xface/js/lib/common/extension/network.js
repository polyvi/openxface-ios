
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
 * 用于获取网络连接信息.
 * @module connection
 * @main connection
 */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    xFace = require('xFace'),
    channel = require('xFace/channel');

/**
 * 此对象用于获取网络连接信息，如当前的网络连接类型 (Android, iOS, WP8).<br>
 * 该类不能通过new来创建相应的对象，只能通过navigator.network.connection来使用该类定义的属性.<br>
 * 相关参考： {{#crossLink "Connection"}}{{/crossLink}}
 * @class Connection
 * @namespace navigator.network
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var NetworkConnection = function () {
    /**
     * 当前的网络连接类型 (Android, iOS, WP8).<br/>
     * 只读属性，其取值范围参考{{#crossLink "Connection"}}{{/crossLink}}中定义的常量
     * @example
           function checkConnection() {
               var networkState = navigator.network.connection.type;

               var states = {};
               states[Connection.UNKNOWN]  = 'Unknown connection';
               states[Connection.ETHERNET] = 'Ethernet connection';
               states[Connection.WIFI]     = 'WiFi connection';
               states[Connection.CELL_2G]  = 'Cell 2G connection';
               states[Connection.CELL_3G]  = 'Cell 3G connection';
               states[Connection.CELL_4G]  = 'Cell 4G connection';
               states[Connection.NONE]     = 'No network connection';

               alert('Connection type: ' + states[networkState]);
           }

           checkConnection();
     * @property type
     * @type String
     * @default Connection.UNKNOWN
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.type = 'unknown';
    this._firstRun = true;
    this._timer = null;
    this.timeout = 500;

    var me = this;

    channel.onxFaceReady.subscribe(function() {
        me.getInfo(function (info) {
            me.type = info;
            if (info === "none") {
                // 如果在定时器触发时仍然为offline状态，则触发offline事件
                me._timer = setTimeout(function(){
                    xFace.fireDocumentEvent("offline");
                    me._timer = null;
                    }, me.timeout);
            } else {
                // 如果有一个正在处理的offline事件，则清除之
                if (me._timer !== null) {
                    clearTimeout(me._timer);
                    me._timer = null;
                }
                xFace.fireDocumentEvent("online");
            }

            // 确保事件只被触发一次
            if (me._firstRun) {
                me._firstRun = false;
                channel.onxFaceConnectionReady.fire();
            }
        },
        function (e) {
            // 即使获取网络连接信息失败，仍然需要触发ConnectionReady事件，这样deviceready事件才有机会被触发
            if (me._firstRun) {
                me._firstRun = false;
                channel.onxFaceConnectionReady.fire();
            }
            console.log("Error initializing Network Connection: " + e);
        });
    });
};

/**
 * 获得网络连接信息
 *
 * @param successCallback 网络连接数据可用时的回调函数
 * @param errorCallback   在获取网络连接数据时出错后的回调函数（可选）
 */
NetworkConnection.prototype.getInfo = function (successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'NetworkConnection.getInfo', arguments);
    exec(successCallback, errorCallback, null, "NetworkConnection", "getConnectionInfo", []);
};

module.exports = new NetworkConnection();
