
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
var exec = require('xFace/exec'),
    argscheck = require('xFace/argscheck'),
    ContactError = require('xFace/extension/ContactError');

/**
 * Provides iOS Contact.display API.
 */
module.exports = {
    /**
     * 弹出系统联系人界面，并显示该条记录,并可以根据options参数来决定是否可以修改该记录（iOS）<br/>
     * @example
            function onSaveSuccess(contact) {
                contact.display(onError,{allowsEditing:"true"});
            }
            function onError(contactError) {
                alert('failed!');
            }

            var contact = navigator.contacts.create();
            contact.displayName = "Bob Gates";
            contact.nickname = "BG";
            contact.note = "Good Friend";
            contact.save(onSaveSuccess);

     * @method display
     * @for Contact
     * @param {Function} [errorCallback]   失败回调函数
     * @param {ContactError} errorCallback.error   错误码
     * @param {object} [options] 可选参数<br/>
     * @param {Boolean} options.allowsEditing    表示是否可以修改显示的联系人
     * @platform iOS
     * @since 3.0.0
     */
    display : function(errorCB, options) {
        argscheck.checkArgs('FO', 'contact.display', arguments);
        if (this.id === null) {
            if (typeof errorCB === "function") {
                var errorObj = new ContactError(ContactError.UNKNOWN_ERROR);
                errorCB(errorObj);
            }
        }
        else {
            exec(null, errorCB, null, "Contacts","displayContact", [this.id, options]);
        }
    }
};