
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
  * 用于描述多媒体采集时产生的错误（Android, iOS）<br/>
  * @class CaptureError
  * @platform Android, iOS
  * @since 3.0.0
  */
var CaptureError = function(c) {
   /**
      * 错误码，用于标识具体的错误类型(Android, iOS)
      * @example
             function errorCallback(error) {
                 var msg = 'An error occurred during capture: ' + getErrorMsg(error.code);
                 console.log(msg);
             }
             var getErrorMsg = function(code){
                if(code == CaptureError.CAPTURE_INTERNAL_ERR){
                    return "capture internal error";
                } else if(code == CaptureError.CAPTURE_APPLICATION_BUSY){
                    return "capture application busy";
                }else if(code == CaptureError.CAPTURE_INVALID_ARGUMENT){
                    return "capture invalid argument";
                }else if(code == CaptureError.CAPTURE_NO_MEDIA_FILES){
                    return "capture no media files";
                }else if(code == CaptureError.CAPTURE_NOT_SUPPORTED){
                    return "capture not supported";
                }
                return "";
            }
      * @property code
      * @default null
      * @type Number
      * @platform Android, iOS
      * @since 3.0.0
      */
   this.code = c || null;
};

/**
  * 摄像头/耳机采集图片或声音时失败(Android, iOS)
  * @example
         CaptureError.CAPTURE_INTERNAL_ERR
  * @property CAPTURE_INTERNAL_ERR
  * @type Number
  * @final
  * @platform Android, iOS
  * @since 3.0.0
  */
CaptureError.CAPTURE_INTERNAL_ERR = 0;
/**
  * 摄像头/音频采集程序正在处理别的采集请求(Android, iOS)
  * @example
         CaptureError.CAPTURE_APPLICATION_BUSY
  * @property CAPTURE_APPLICATION_BUSY
  * @type Number
  * @final
  * @platform Android, iOS
  * @since 3.0.0
  */
CaptureError.CAPTURE_APPLICATION_BUSY = 1;
/**
  * api的调用方式不对(例如：limit 参数的值小于1)(Android, iOS)
  * @example
         CaptureError.CAPTURE_INVALID_ARGUMENT
  * @property CAPTURE_INVALID_ARGUMENT
  * @type Number
  * @final
  * @platform Android, iOS
  * @since 3.0.0
  */
CaptureError.CAPTURE_INVALID_ARGUMENT = 2;
/**
  * 在采集到任何信息之前用户退出了摄像头/音频采集程序(Android, iOS)
  * @example
         CaptureError.CAPTURE_NO_MEDIA_FILES
  * @property CAPTURE_NO_MEDIA_FILES
  * @type Number
  * @final
  * @platform Android, iOS
  * @since 3.0.0
  */
CaptureError.CAPTURE_NO_MEDIA_FILES = 3;
/**
  * 设备不支持该采集操作(Android, iOS)
  * @example
         CaptureError.CAPTURE_NOT_SUPPORTED
  * @property CAPTURE_NOT_SUPPORTED
  * @type Number
  * @final
  * @platform Android, iOS
  * @since 3.0.0
  */
CaptureError.CAPTURE_NOT_SUPPORTED = 20;

module.exports = CaptureError;
