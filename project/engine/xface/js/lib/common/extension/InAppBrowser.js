
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
     * browser提供内置浏览器的功能
     * @module browser
     * @main browser
     */
    var exec = require('xFace/exec');
    var argscheck = require('xFace/argscheck');

    /**
     * InAppBrowser提供内置浏览器的功能(Android, iOS, WP8)<br/>
     * 该类不能通过new来创建相应的对象，只能通过调用window.open方法返回该类的实例对象，<br/>
     * window.open与{{#crossLink "InAppBrowser/open"}}{{/crossLink}}函数用法一�     * @class InAppBrowser
     * @static
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */

     /**
     * 当页面开始加载时，该事件被触发（Android, iOS, WP8�br/>
     * @example
            var inAppBrowser = window.open('http://baidu.com', 'random_string');
            function handler(event) {
                updateEvent('loadstart' + ":" + event.url);
            }
            inAppBrowser.addEventListener("loadstart", handler);
     * @event loadstart
     * @param {Object} event 事件对象
     * @param {String} event.type 事件类型，值为loadstart
     * @param {String} event.url 加载的url
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */

     /**
     * 当页面开始停止加载时，该事件被触发（Android, iOS, WP8�br/>
     * @example
            var inAppBrowser = window.open('http://baidu.com', 'random_string');
            function handler(event) {
                updateEvent('loadstop' + ":" + event.url);
            }
            inAppBrowser.addEventListener("loadstop", handler);
     * @event loadstop
     * @param {Object} event 事件对象
     * @param {String} event.type 事件类型，值为loadstop
     * @param {String} event.url 加载的url
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */

     /**
     * 当退出InAppBrowser时，该事件被触发（Android, iOS, WP8�br/>
     * @example
            var inAppBrowser = window.open('http://baidu.com', 'random_string');
            function handler(event) {
                console.log("InAppBrowser exit!");
            }
            inAppBrowser.addEventListener("exit", handler);
     * @event exit
     * @param {Object} event 事件对象
     * @param {String} event.type 事件类型，值为exit
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */


    function InAppBrowser()
    {
       var _channel = require('xFace/channel');
       this.channels = {
            'loadstart': _channel.create('loadstart'),
            'loadstop' : _channel.create('loadstop'),
            'exit' : _channel.create('exit')
       };
    }

    InAppBrowser.prototype._eventHandler = function(event)
    {
        if (event.type in this.channels) {
            this.channels[event.type].fire(event);
        }
    };
    /**
     * 打开一个网页，通过window.open调用该方法（Android, iOS, WP8�
     @example
          function openInAppBrowser() {
          var browser = window.open('http://baidu.com', 'random_string');
          updateStatus("opening in the in app browser");
          window.setTimeout(function() {
                                browser.close();
                                updateStatus("closed browser");
                            },3000);
          }

          function openInAppBrowserWithoutAddressbar() {
              var browser = open("http://www.baidu.com", '_blank', 'location=no');
              updateStatus("opening in the in app browser without address bar");
              window.setTimeout(function() {
                                    browser.close();
                                    updateStatus("closed browser");
                                },3000);
          }

          function openInSystemBrowser() {
                var inAppBrowser = open("http://www.baidu.com", '_system');
                updateStatus("opening in system browser");
          }

          function openInXFace() {
              updateStatus("opening in xface");
              var browser = open("http://www.baidu.com", '_self');
          }
     * @method open
     * @param {String} strUrl 要打开的网页地址
     * @param {String} [strWindowName="_self"] 打开网页的目标窗口。参数值说� <br/>
                             "\_self":    表示在当前xface页面打开<br/>
                             "\_system":  表示在系统浏览器打开<br/>
                             "\_blank"或其他未定义的� 表示在内置的浏览器打开，也就是在新的窗口打开<br/>
     * @param {String} [strWindowFeatures=""] 特性列表。不能包含空格，格式形如"location=yes,foo=no,bar=yes"。目前只支持location，表示显示地址栏与否�WP8不支持location)
     * @return 返回InAppBrowser实例对象
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    InAppBrowser.open = function(strUrl, strWindowName, strWindowFeatures)
    {
        argscheck.checkArgs('sSS','InAppBrowser.open', arguments);
        var iab = new InAppBrowser();
        var cb = function(eventname) {
           iab._eventHandler(eventname);
        };
        exec(cb, null,null,"InAppBrowser", "open", [strUrl, strWindowName, strWindowFeatures]);
        return iab;
    };
    /**
     * 关闭一个已在内置浏览器打开的网页（Android, iOS, WP8�     @example
          见open方法的示�     * @method close
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    InAppBrowser.prototype.close = function()
    {
        exec(null, null, null, "InAppBrowser", "close", []);
    };

    /**
     * 为InAppBrowser增加一个事件监听器,注意只有在内置的浏览器打开，事件监听器才有效（Android, iOS, WP8�
     @example
          见loadstart、loadstop、exit 事件的示�     * @method addEventListener
     * @param {String} eventname 需要监听的事件，参数说明：<br/>
                                    "loadstart": 表示页面开始加�<br/>
                                    “loadstop":  表示页面停止加载 <br/>
                                    "exit":      表示InAppBrowser关闭 <br/>
     * @param {Function} eventHandler 事件处理函数
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    InAppBrowser.prototype.addEventListener = function(eventname, f)
    {
        argscheck.checkArgs('sf','InAppBrowser.addEventListener', arguments);
        if (eventname in this.channels) {
            this.channels[eventname].subscribe(f);
        }
    };

    /**
     * 去除InAppBrowser一个事件监听器（Android, iOS, WP8�
     @example
          见loadstart、loadstop、exit 事件的示�     * @method removeEventListener
     * @example
          var inAppBrowser = window.open('http://baidu.com', 'random_string');
            function handler() {
                console.log("page load stop!");
            }
            inAppBrowser.removeEventListener("loadstop", handler);
     * @param {String} eventname  需要监听的事件，参数说明：<br/>
                                    "loadstart": 表示页面开始加�<br/>
                                    “loadstop":  表示页面停止加载 <br/>
                                    "exit":      表示InAppBrowser关闭 <br/>
     * @param {Function} eventHandler 事件处理函数
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    InAppBrowser.prototype.removeEventListener = function(eventname, f)
    {
        argscheck.checkArgs('sf','InAppBrowser.removeEventListener', arguments);
        if (eventname in this.channels) {
            this.channels[eventname].unsubscribe(f);
        }
    };

    /**
     * 注入一段js代码并执行（Android, iOS�
     * @example
            var browser = null;
            //给页面注入JS代码
            function replaceHeaderImage() {
                browser.executeScript({
                    code: "var img=document.querySelector('#logo img'); img.src='http://192.168.2.245/develop/InAppbrowser/xFace.png';"
                }, function() {
                    console.log("Image Element Successfully Hijacked");
                });
            }

            //给页面注入JS文件
            function replaceHeaderImageByFile() {
                browser.executeScript({
                    file: "http://192.168.2.245/develop/InAppbrowser/test.js"
                },function() {
                    console.log("Image Element Successfully Hijacked");
                });
            }

            function browserClose(event) {
                 browser.removeEventListener('loadstop', replaceHeaderImage);
                 browser.removeEventListener('exit', browserClose);
            }

            function injectScriptCode() {
                browser = window.open('http://www.baidu.com', '_blank', 'location=yes');
                browser.addEventListener('loadstop', replaceHeaderImage);
                browser.addEventListener('exit', browserClose);
            }

            function injectScriptFile() {
                browser = window.open('http://www.baidu.com', '_blank', 'location=yes');
                browser.addEventListener('loadstop', replaceHeaderImageByFile);
                browser.addEventListener('exit', browserClose);
            }
     * @method executeScript
     * @param {Object} injectDetails  要注入的对象<br/>
     * @param {Function} cb           成功回调函数
     * @platform Android、iOS
     * @since 3.0.0
     */
    InAppBrowser.prototype.executeScript = function(injectDetails, cb)
    {
        argscheck.checkArgs('oF','InAppBrowser.executeScript', arguments);
        if (injectDetails.code) {
            exec(cb, null, null, "InAppBrowser", "injectScriptCode", [injectDetails.code, !!cb]);
        } else if (injectDetails.file) {
            exec(cb, null, null, "InAppBrowser", "injectScriptFile", [injectDetails.file, !!cb]);
        } else {
            throw new Error('executeScript requires exactly one of code or file to be specified');
        }
    };

    /**
     * 注入CSS代码（Android, iOS�
     * @example
            var browser = null;
            //给页面注入CSS代码
            function changeBackgroundColor() {
                browser.insertCSS({
                    code: "body { background: #ffff00}"
                }, function() {
                    console.log("Styles Altered");
                });
            }

            //给页面注入CSS文件
            function changeBackgroundColorByFile() {
                browser.insertCSS({
                    file: "http://192.168.2.245/develop/InAppbrowser/test.css"
                }, function() {
                    console.log("Styles Altered");
                });
            }

            function injectStyleCode() {
                browser = window.open('http://apache.org', '_blank', 'location=yes');
                browser.addEventListener('loadstop', changeBackgroundColor);
                browser.addEventListener('exit', browserClose);
            }

            function injectStyleFile() {
                browser = window.open('http://apache.org', '_blank', 'location=yes');
                browser.addEventListener('loadstop', changeBackgroundColorByFile);
                browser.addEventListener('exit', browserClose);
            }
     * @method insertCSS
     * @param {Object} injectDetails  要注入的对象
     * @param {Function} cb           成功回调函数
     * @platform Android、iOS
     * @since 3.0.0
     */
    InAppBrowser.prototype.insertCSS = function(injectDetails, cb)
    {
        argscheck.checkArgs('oF','InAppBrowser.insertCSS', arguments);
        if (injectDetails.code) {
            exec(cb, null, null, "InAppBrowser", "injectStyleCode", [injectDetails.code, !!cb]);
        } else if (injectDetails.file) {
            exec(cb, null, null, "InAppBrowser", "injectStyleFile", [injectDetails.file, !!cb]);
        } else {
            throw new Error('insertCSS requires exactly one of code or file to be specified');
        }
    };

    module.exports = InAppBrowser.open;

