
/*
 Copyright 2012-2013, Polyvi Inc. (http://www.xface3.com)
 This program is distributed under the terms of the GNU General Public License.

 This file is part of xFace.

 xFace is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 xFace is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with xFace.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * 该模块提供条形码扫描的功能
 * @module barcodeScanner
 * @main barcodeScanner
 */

 /**
  * BarcodeScanner扩展提供条形码扫描的功能（Android, iOS, WP8）<br/>
  * 该类不能通过new来创建相应的对象，只能通过xFace.BarcodeScanner对象来直接使用该类中定义的方法
  * @class BarcodeScanner
  * @static
  * @platform Android, iOS, WP8
  * @since 3.0.0
  */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');
function BarcodeScanner(){}

/**
 * 启动条形码扫描器（Android, iOS, WP8）<br/>
 * 该方法通过异步方式尝试扫描条形码。如果扫描成功，成功回调被调用并传回barcode的字符串；否则失败回调被调用。
  @example
      function start() {
          xFace.BarcodeScanner.start(success, fail);
      }
      function success(barcode) {
          alert(barcode);
          alert("success");
      }
      function fail() {
          alert("fail to scanner barcode" );
      }
 * @method start
 * @param {Function} successCallback   成功回调函数
 * @param {String} successCallback.barcode 扫描码结果
 * @param {Function} [errorCallback]   失败回调函数
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
BarcodeScanner.prototype.start = function(successCallback, errorCallback){
    argscheck.checkArgs('fF', 'BarcodeScanner.start', arguments);
    exec(successCallback, errorCallback, null, "BarcodeScanner", "start", []);
};
module.exports = new BarcodeScanner();
