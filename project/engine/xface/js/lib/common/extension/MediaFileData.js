
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
 * 封装了多媒体文件的格式信息（Android, iOS, WP8）
 * @class MediaFileData
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var MediaFileData = function(codecs, bitrate, height, width, duration){
    /**
      * 音频/视频文件内容的实际格式（三个平台都不支持）
      */
    this.codecs = codecs || null;
    /**
     * 文件内容的平均比特率(iOS)<br/>
     * 仅支持iOS4以上的设备，对于图像/视频文件，属性值为0
     * @example
            function getFormatData() {
                mediaFile.getFormatData(successCallback, errorCallback);
            }
            function successCallback(media) {
                console.log("media.bitrate = " + media.bitrate);
            }
     * @property bitrate
     * @type Number
     * @default 0
     * @platform iOS
     * @since 3.0.0
     */
    this.bitrate = bitrate || 0;
    /**
     * 图像/视频的高度，音频剪辑的该属性值为0（以像素为单位）(Android, iOS),WP8 只支持图像高度,视频/音频该属性值为0<br/>
     * @example
            function successCallback(media) {
                console.log("media.height = " + media.height);
            }
     * @property height
     * @type Number
     * @default 0
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.height = height || 0;
    /**
     * 图像/视频的宽度，音频剪辑的该属性值为0（以像素为单位）(Android, iOS),WP8 只支持图像宽度,视频/音频该属性值为0<br/>
     * @example
            function successCallback(media) {
                console.log("media.width = "+media.width);
            }
     * @property width
     * @type Number
     * @default 0
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.width = width || 0;
    /**
     * 视频/音频剪辑时长，图像剪辑的该属性值为0（以秒为单位）(Android, iOS)<br/>
     * @example
            function successCallback(media) {
                console.log("media.duration = "+media.duration);
            }
     * @property duration
     * @type Number
     * @default 0
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.duration = duration || 0;
};

module.exports = MediaFileData;