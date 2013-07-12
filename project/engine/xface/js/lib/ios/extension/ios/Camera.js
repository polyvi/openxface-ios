
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
 * @module camera
 */
var cameraExport = {};

/**
 * 用于清除使用相机拍照存储在程序中的temp文件夹下的照片（iOS）<br/>
 * @example
        function onSuccess() {
             alert('Success!');
        }
        function onError() {
            alert('failed!');
        }

        navigator.camera.cleanup(onSuccess, onError);

 * @method cleanup
 * @for Camera
 * @param {Function} [successCallback] 成功回调方法
 * @param {Function} [errorCallback]   失败回调函数
 * @platform iOS
 * @since 3.0.0
 */
cameraExport.cleanup = function(successCallback, errorCallback) {
    var argscheck = require('xFace/argscheck');
    argscheck.checkArgs('FF', 'Camera.cleanup', arguments);
    exec(successCallback, errorCallback, null, "Camera", "cleanup", []);
};

module.exports = cameraExport;
