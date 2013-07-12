
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
 * @module capture
 */

 /**
  * 该类封装了图像采集功能的配置选项（Android, WP8）<br/>
  * @class CaptureImageOptions
  * @constructor
  * @platform Android, WP8
  * @since 3.0.0
  */
var CaptureImageOptions = function(){
    /**
     * 在单个采集操作期间能够记录的图像剪辑数量最大值，必须设定为大于等于1(Android, WP8)<br/>
     * @example
            var options = new CaptureImageOptions();
            options.limit = 3;
            navigator.device.capture.captureImage(captureSuccess, captureError, options);
     * @property limit
     * @type Number
     * @default 1
     * @platform Android, WP8
     * @since 3.0.0
     */
    this.limit = 1;
    /**
     * 选定的音频模式（两个平台都不支持）<br/>
     */
     // TODO: 支持capture.supportedImageModes
    this.mode = null;
};

module.exports = CaptureImageOptions;