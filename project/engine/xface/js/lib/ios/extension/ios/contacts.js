
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
 * @module contacts
 */
var exec = require('xFace/exec');
    argscheck = require('xFace/argscheck');

/**
 * Provides iOS enhanced contacts API.
 */
module.exports = {
     /**
     * 启动系统ui界面用于创建一个新的联系人（iOS）<br/>
     * @example
            navigator.contacts.newContactUI (onSuccess);

            function onSuccess(contactId) {
                alert("success!");
            }

     * @method newContactUI
     * @for Contacts
     * @param {Function} [successCallback]   成功回调函数
     * @param {String} successCallback.contactId   新生成的Contact的id
     * @platform iOS
     * @since 3.0.0
     */
    newContactUI : function(successCallback) {
        argscheck.checkArgs('f', 'contacts.newContactUI', arguments);
        exec(successCallback, null, null, "Contacts","newContact", []);
    }
};