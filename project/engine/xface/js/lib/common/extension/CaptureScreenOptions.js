
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
  * 该类封装了屏幕截图功能的配置选项（Android）<br/>
    接口传入的x和y坐标以及高宽构成一块矩形和view矩形区域交集为最终截图区域(x和y可以为负值)<br/>
    本接口中用户某以数据项没输入则默认为0。
    如果不传入任何数据或输入(0, 0, 0, 0)，则默认全屏<br/>
    如果只传入x和y坐标或输入(x, y, 0, 0)，则默认以x和y坐标为起点的截图区域<br/>
    如果只传入x和y坐标，高和宽只输入一项，且输入项为0，则默认以x和y坐标为起点的截图区域<br/>
    如果只传入x和y坐标，高和宽只是输入了一项，且输入项不为0，则报参数不合法错误<br/>
    如果传入的高或者宽小于0，则报参数不合法错误<br/>
  * @class CaptureScreenOptions
  * @constructor
  * @platform Android,iOS
  * @since 3.0.0
  */
var CaptureScreenOptions = function(){
    /**
     * 截取屏幕的横坐标(Android,iOS)<br/>
     * @example
            var options = new CaptureScreenOptions();
            options.x = 3;
            options.y = 10;
            options.width = 200;
            options.height = 250;
            navigator.device.capture.CaptureScreen(captureSuccess, captureError, options);
     * @property x
     * @type Number
     * @default 0
     * @platform Android,iOS
     * @since 3.0.0
     */
    this.x = 0;
    /**
     * 截取屏幕的纵坐标(Android,iOS)<br/>
     * @example
            var options = new CaptureScreenOptions();
            options.x = 3;
            options.y = 10;
            options.width = 200;
            options.height = 250;
            navigator.device.capture.CaptureScreen(captureSuccess, captureError, options);
     * @property y
     * @type Number
     * @default 0
     * @platform Android,iOS
     * @since 3.0.0
     */
    this.y = 0;
    /**
     * 截取屏幕的宽度，如果x,y坐标及高宽都不传则默认截取全屏(Android,iOS)<br/>
     * @example
            var options = new CaptureScreenOptions();
            options.x = 3;
            options.y = 10;
            options.width = 200;
            options.height = 250;
            navigator.device.capture.CaptureScreen(captureSuccess, captureError, options);
     * @property width
     * @type Number
     * @default 0
     * @platform Android,iOS
     * @since 3.0.0
     */
    this.width = 0;
    /**
     * 截取屏幕的高度，如果x,y坐标及高宽都不传则默认截取全屏(Android,iOS)<br/>
     * @example
            var options = new CaptureScreenOptions();
            options.x = 3;
            options.y = 10;
            options.width = 200;
            options.height = 250;
            navigator.device.capture.CaptureScreen(captureSuccess, captureError, options);
     * @property height
     * @type Number
     * @default 0
     * @platform Android,iOS
     * @since 3.0.0
     */
    this.height = 0;
    /**
     * 截屏完成后目标图像的数据类型，DATA_URL返回base64编码的数据；FILE_URI返回文件url(Android,iOS)<br/>
     * @example
            //返回截屏结果base64编码格式的数据
            var options = new CaptureScreenOptions();
            options.destinationType = DestinationType.DATA_URL;
            navigator.device.capture.CaptureScreen(captureSuccess, captureError, options);
            //返回截屏结果的文件url
            var options = new CaptureScreenOptions();
            options.destinationType = DestinationType.FILE_URI;
            navigator.device.capture.CaptureScreen(captureSuccess, captureError, options);
     * @property DestinationType
     * @type String
     * @default DestinationType.DATA_URL
     * @platform Android,iOS
     * @since 3.0.0
     */
    this.destinationType = CaptureScreenOptions.DestinationType.DATA_URL;
    /**
     * 当DestinationType为FILE_URI时此选项有效，用于表示截屏完成后截屏图片存储路径(Android,iOS)<br/>
     * @example
            var options = new CaptureScreenOptions();
            options.destionationFile = "file://sdcard/test.png";
            navigator.device.capture.CaptureScreen(captureSuccess, captureError, options);
     * @property destionationFile
     * @type String
     * @default " "
     * @platform Android,iOS
     * @since 3.0.0
     */
    this.destionationFile = " ";
};

  /**
   * 该类定义一些常量，用于标识截屏的目标图像的数据类型（Android, iOS）<br/>
   * 相关参考： {{#crossLink "capture"}}{{/crossLink}}
   * @class DestinationType
   * @namespace CaptureScreenOptions
   * @static
   * @platform Android, iOS
   * @since 3.0.0
   */
  CaptureScreenOptions.DestinationType = {
   /**
    * base64编码格式的数据（Android, iOS）
    * @property DATA_URL
    * @type Number
    * @final
    * @platform Android, iOS
    * @since 3.0.0
    */
    DATA_URL: 0,
    /**
    * 文件url（Android, iOS）
    * @property FILE_URI
    * @type Number
    * @final
    * @platform Android, iOS
    * @since 3.0.0
    */
    FILE_URI: 1
  },
module.exports = CaptureScreenOptions;