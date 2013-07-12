
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

/*
 * $Id$
 */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');

/**
 * 将消息通过exec()传给echo扩展, 然后由echo扩展将消息传回成功回调。
 * @param successCallback   成功回调
 * @param errorCallback     失败回调
 * @param message           传给echo扩展的消息.
 * @param forceAsync        是否采用异步方式传值(用于测试js桥).
 */
module.exports = function(successCallback, errorCallback, message, forceAsync) {
    argscheck.checkArgs('ffsB', 'echo.echo', arguments);
    var action = forceAsync ? 'echoAsync' : 'echo';
    exec(successCallback, errorCallback, null, "Echo", action, [message]);
};
