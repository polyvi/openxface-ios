
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
 * CaptureScreenResult用于表示文件操作出现的具体的错误（Android, iOS）<br/>
 * @class CaptureScreenResult
 * @platform Android, iOS
 * @since 3.0.0
 */
function CaptureScreenResult(code, result) {
  /**
   * 截屏执行完毕的结果码Android, iOS)<br/>
   * 其取值范围参考{{#crossLink "CaptureScreenResult"}}{{/crossLink}}中定义的常量
   * @example
        function save_defaultWorkspace(){
            document.getElementById('status').innerText = "printScreen";
            document.getElementById('result').innerText = "";
            var options = getOptions();
            options.destinationType = CaptureScreenOptions.DestinationType.FILE_URI;
            navigator.device.capture.captureScreen(success, error, options);
        }

        function success(result) {
            console.log("success: " + result.result);
        }

        function error(result) {
            var msg = "unkown error";
            if(result.code == CaptureScreenResult.ARGUMENT_ERROR) {
                msg = "invalid argument";
            } else if(result.code == CaptureScreenResult.IO_ERROR) {
                msg = "io exception";
            } 
            console.log("error:" + msg);
        }
   * @property code
   * @type Number
   * @platform Android, iOS
   * @since 3.0.0
   */
  this.code = code || null;
  
  /**
   * 截屏执行完毕后返回的截屏数据(Android, iOS)<br/>
   * 其取值范围参考{{#crossLink "CaptureScreenResult"}}{{/crossLink}}中定义的常量
   * @example
        function save_defaultWorkspace(){
            document.getElementById('status').innerText = "printScreen";
            document.getElementById('result').innerText = "";
            var options = getOptions();
            options.destinationType = CaptureScreenOptions.DestinationType.FILE_URI;
            navigator.device.capture.captureScreen(success, error, options);
        }

        function success(result) {
            console.log("success: " + result.result);
        }

        function error(result) {
            var msg = "unkown error";
            if(result.code == CaptureScreenResult.ARGUMENT_ERROR) {
                msg = "invalid argument";
            } else if(result.code == CaptureScreenResult.IO_ERROR) {
                msg = "io exception";
            } 
            console.log("error:" + msg);
        }
   * @property result
   * @type String
   * @platform Android, iOS
   * @since 3.0.0
   */
  this.result = result || null;
}

// CaptureScreen result codes
// Found in DOMException

/**
 * 表示截屏执行成功（Android，iOS）
 * @property SUCCESS
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
CaptureScreenResult.SUCCESS = 0;

/**
 * 表示传入的参数有错误（Android，iOS）
 * @property ARGUMENT_ERROR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
CaptureScreenResult.ARGUMENT_ERROR = 1;

/**
 * 表示执行IO的时候发生了错误（Android，iOS）<br/>
 * @property IO_ERROR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
CaptureScreenResult.IO_ERROR = 2;

module.exports = CaptureScreenResult;