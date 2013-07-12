
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


module.exports = {
  /**
   * 该类定义一些常量，用于标识camera的目标图像的数据类型（Android, iOS, WP8）<br/>
   * 相关参考： {{#crossLink "Camera"}}{{/crossLink}}
   * @class DestinationType
   * @namespace Camera
   * @static
   * @platform Android, iOS, WP8
   * @since 3.0.0
   */
  DestinationType:{
   /**
    * base64编码格式的数据（Android, iOS, WP8）
    * @property DATA_URL
    * @type Number
    * @final
    * @platform Android, iOS, WP8
    * @since 3.0.0
    */
    DATA_URL: 0,         // Return base64 encoded string
    /**
    * 文件url（iOS, WP8）
    * @property FILE_URI
    * @type Number
    * @final
    * @platform iOS, WP8
    * @since 3.0.0
    */
    FILE_URI: 1,          // Return file uri (content://media/external/images/media/2 for Android)
    /**
    * 本地url（Android）
    * @property NATIVE_URI
    * @type Number
    * @final
    * @platform Android
    * @since 3.0.0
    */
    NATIVE_URI: 2
  },
  /**
   * 该类定义一些常量，用于标识camera的目标图像的编码类型（iOS）<br/>
   * 相关参考： {{#crossLink "Camera"}}{{/crossLink}}
   * @class EncodingType
   * @namespace Camera
   * @static
   * @platform iOS
   * @since 3.0.0
   */
  EncodingType:{
  /**
    * 图片为JPEG格式（iOS）
    * @property JPEG
    * @type Number
    * @final
    * @platform iOS
    * @since 3.0.0
    */
    JPEG: 0,             // Return JPEG encoded image
  /**
    * 图片为PNG格式（iOS）
    * @property PNG
    * @type Number
    * @final
    * @platform iOS
    * @since 3.0.0
    */
    PNG: 1               // Return PNG encoded image
  },
  /**
   * 该类定义一些常量，用于标识camera的媒体文件类型（Android, iOS, WP8）<br/>
   * 相关参考： {{#crossLink "Camera"}}{{/crossLink}}
   * @class MediaType
   * @namespace Camera
   * @static
   * @platform Android, iOS, WP8
   * @since 3.0.0
   */
  MediaType:{
  /**
    * 照片（Android, iOS, WP8）
    * @property PICTURE
    * @type Number
    * @final
    * @platform Android, iOS, WP8
    * @since 3.0.0
    */
    PICTURE: 0,          // allow selection of still pictures only. DEFAULT. Will return format specified via DestinationType
    /**
    * 视频（Android, iOS, WP8）
    * @property VIDEO
    * @type Number
    * @final
    * @platform Android, iOS, WP8
    * @since 3.0.0
    */
    VIDEO: 1,            // allow selection of video only, ONLY RETURNS URL
    /**
    * 所有媒体类型（Android, iOS, WP8）
    * @property ALLMEDIA
    * @type Number
    * @final
    * @platform Android, iOS, WP8
    * @since 3.0.0
    */
    ALLMEDIA : 2         // allow selection from all media types
  },
  /**
   * 该类定义一些常量，用于标识camera的图片源类型（Android, iOS, WP8）<br/>
   * 相关参考： {{#crossLink "Camera"}}{{/crossLink}}
   * @class PictureSourceType
   * @namespace Camera
   * @static
   * @platform Android, iOS, WP8
   * @since 3.0.0
   */
  PictureSourceType:{
    /**
    * 从图片库选择图片（Android, iOS, WP8）
    * @property PHOTOLIBRARY
    * @type Number
    * @final
    * @platform Android, iOS, WP8
    * @since 3.0.0
    */
    PHOTOLIBRARY : 0,    // Choose image from picture library (same as SAVEDPHOTOALBUM for Android, WP8)
    /**
    * 调用设备摄像头照相采集照片（Android, iOS, WP8）
    * @property CAMERA
    * @type Number
    * @final
    * @platform Android, iOS, WP8
    * @since 3.0.0
    */
    CAMERA : 1,          // Take picture from camera
    /**
    * 从相册选择图片，（Android, WP8平台上，与PHOTOLIBRARY等效）（Android, iOS, WP8）
    * @property SAVEDPHOTOALBUM
    * @type Number
    * @final
    * @platform Android, iOS, WP8
    * @since 3.0.0
    */
    SAVEDPHOTOALBUM : 2  // Choose image from picture library (same as PHOTOLIBRARY for Android, WP8)
  }
};