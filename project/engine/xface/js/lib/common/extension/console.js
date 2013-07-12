
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

/**该模块负责向控制台输出log信息
 * @module console
 * @main console
 */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');

/**
 * 该类向控制台输出log信息，如果没有调用setLevel函数，则默认打印所有类型log信息（Android, iOS, WP8）<br/>
 * 只能通过console对象来直接使用该类中定义的方法
 * @class Console
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var DebugConsole = function() {
    this.winConsole = window.console;
    this.logLevel = DebugConsole.INFO_LEVEL;
};

/**
 * 能成功打印所有类型log信息,和INFO_LEVEL相同
 */
DebugConsole.ALL_LEVEL    = 1;

/**
 * 能成功打印所有类型log信息
 */
DebugConsole.INFO_LEVEL   = 1;

/**
 * 能成功打印警告、错误log信息
 */
DebugConsole.WARN_LEVEL   = 2;

/**
 * 只能成功打印错误log信息
 */
DebugConsole.ERROR_LEVEL  = 4;

/**
 * 所有打印log信息的api都不能正常输出log信息
 */
DebugConsole.NONE_LEVEL   = 8;

/**
 * 设置当前log信息输出的最高级别（Android, iOS, WP8）
 * @example
        console.setLevel(1);
 * @method setLevel
 * @param {Number} level 表示当前log信息输出的最高级别,有四个等级:<br/>
                         1: 所有log信息；2：警告、错误log信息；4：错误log信息；8：不输出log信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
DebugConsole.prototype.setLevel = function(level) {
    argscheck.checkArgs('n', 'console.setLevel', arguments);
    this.logLevel = level;
};

/**
 * 返回输入的Object对象的String类型
 */
var stringify = function(message) {
    try{
       if(typeof message === "object" && JSON && JSON.stringify) {
           return JSON.stringify(message);
       } else {
           return message.toString();
       }
    } catch (e) {
       return e.toString;
    }
};

/**
 * 向控制台打印一条普通log信息（Android, iOS, WP8）
 * @example
        var str = "This is just a log information! ";
        console.log(str);
 * @method log
 * @param {Object} message 需要打印的log信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
DebugConsole.prototype.log = function(message) {
    argscheck.checkArgs('*', 'console.log', arguments);
    if (this.logLevel <= DebugConsole.INFO_LEVEL) {
        exec(null, null, null, 'Console', 'log', [ stringify(message), { logLevel: 'INFO' } ]);
    } else {
       this.winConsole.log(message);
    }
 };

/**
 * 向控制台打印一条警告log信息（Android, iOS, WP8）
 * @example
        var str = "This is just a warn information! ";
        console.warn(str);
 * @method warn
 * @param {Object} message 需要打印的log信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
DebugConsole.prototype.warn = function(message) {
    argscheck.checkArgs('*', 'console.warn', arguments);
    if (this.logLevel <= DebugConsole.WARN_LEVEL)
        exec(null, null, null, 'Console', 'log', [ stringify(message), { logLevel: 'WARN' } ]);
    else
        this.winConsole.error(message);
};

/**
 * 向控制台打印一条错误log信息（Android, iOS, WP8）
 * @example
        var str = "This is just an error information! ";
        console.error(str);
 * @method error
 * @param {Object} message 需要打印的log信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
DebugConsole.prototype.error = function(message) {
    argscheck.checkArgs('*', 'console.error', arguments);
    if (this.logLevel <= DebugConsole.ERROR_LEVEL)
        exec(null, null, null, 'Console', 'log', [ stringify(message), { logLevel: 'ERROR' }]);
    else
        this.winConsole.error(message);
};

module.exports = new DebugConsole();