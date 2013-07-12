
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
     * IdleWatcher提供用户长时间无操作超时的监听
     * @module idleWatcher
     * @main idleWatcher
     */

    var exec = require('xFace/exec');
    var argscheck = require('xFace/argscheck');

    /**
     * 提供用户长时间无操作超时的监听（Android，iOS）<br/>
     * 该类不能通过new来创建相应的对象，只能通过xFace.IdleWatcher对象来直接使用该类中定义的方法
     * @class IdleWatcher
     * @platform Android, iOS
     */
    var IdleWatcher = function () {
    };

    /**
     * 开始记录用户无操作的时间（Android, iOS）
     * @method start
     * @example
             xFace.IdleWatcher.start(function(){
                                           document.getElementById('result').innerText ="timeout";
                                           },5);
     * @param {Function} eventListener     超时监听函数
     * @param {String}   [timeout=300]     超时时间,单位为秒。注意：超时时间设定的值会被最后一次调用设定的值所覆盖。
     * @param {Function} [successCallback] 成功回调函数
     * @param {Function} [errorCallback]   失败回调函数
     * @platform Android、iOS
     * @since 3.0.0
     */
    IdleWatcher.prototype.start = function(eventListener, timeout, successCallback, errorCallback) {
        var exec = require('xFace/exec');
        argscheck.checkArgs('fNFF','IdleWatcher.start', arguments);
        exec(successCallback, errorCallback, eventListener, "IdleWatcher", "start", [timeout]);
    }

    /**
     * 停止记录用户无操作的时间 （Android, iOS）
     * @method stop
     * @example
            xFace.IdleWatcher.stop();
     * @platform Android、iOS
     * @since 3.0.0
     */
    IdleWatcher.prototype.stop = function()
    {
        exec(null, null, null, "IdleWatcher", "stop", []);
    }
   module.exports = new IdleWatcher();
