
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

module.exports = {
    id: "ios",
    initialize:function() {
        var channel = require('xFace/channel');
        var xFace = require('xFace');
        var privateModule = require('xFace/privateModule');

        channel.onVolumeDownKeyDown = xFace.addDocumentEventHandler('volumedownbutton');
        channel.onVolumeUpKeyDown = xFace.addDocumentEventHandler('volumeupbutton');

        /**
         * 当商圈退出的时候，会触发该事件（iOS）<br/>
         document.addEventListener("circlemessagereceived", onCircleMessageReceived, false);
         * @event circlemessagereceived
         * @for BaseEvent
         * @param {String} status 状态信息.<br/>
         *            0：退出 <br/>
         *            1：回首页<br/>
         *            2：注册长时间无操作的监听
         * @platform iOS
         * @since 3.0.0
         */
        channel.onCircleMessageReceived = xFace.addDocumentEventHandler('circlemessagereceived');

        // TODO:处理geolocation

        //重写window.openDatabase接口
        // 给每个app的数据库的名字加appId，以避免不同的app使用同名字的数据库
        var currentAppId = privateModule.getAppId();
        var originalOpenDatabase = window.openDatabase;
        window.openDatabase = function(name, version, desc, size) {
            var db = null;
            var newname = currentAppId + name;
            db = originalOpenDatabase(newname, version, desc, size);
            return db;
        };
    },
    objects: {
        File: { // exists natively, override
            path: 'xFace/extension/File'
        },
        FileReader:{
            path: 'xFace/extension/FileReader'
        },
        console: {
            path: 'xFace/extension/console'
        },
        localStorage : {
            path : 'xFace/localStorage'
        },
        MediaError: {
            path: 'xFace/extension/MediaError'
        },
        open: { // exists natively, override
            path: 'xFace/extension/InAppBrowser'
        }
    },
    merges:{
        Entry:{
            path: 'xFace/extension/ios/Entry'
        },
        FileReader:{
            path: 'xFace/extension/ios/FileReader'
        },
        Contact:{
            path: 'xFace/extension/ios/Contact'
        },
        navigator:{
            children:{
                contacts:{
                    path: 'xFace/extension/ios/contacts'
                },
                camera:{
                    path: 'xFace/extension/ios/Camera'
                }
            }
        }
    }
};
