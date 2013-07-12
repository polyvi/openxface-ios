
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

var xFace = require('xFace');
var privateModule = require('xFace/privateModule');

var m_window_addEventListener = window.addEventListener;
var m_window_removeEventListener = window.removeEventListener;

var m_localStorage_setItem = localStorage.setItem;
var m_localStorage_getItem = localStorage.getItem;
var m_localStorage_removeItem = localStorage.removeItem;

var localstorageFunMap = {};
var keyPrefix = "_";
var keySeparator = ",";

function getNewKey(appId, key){
    var newKey = appId + keyPrefix + key;
    return newKey;
}

window.addEventListener = function(evt, handler, capture) {
    var evtLowCase = evt.toLowerCase();
    if("storage" == evtLowCase){
            var storageCallback = function(storageEvent){
            var key = storageEvent.key;
            var endAppIdIndex = key.indexOf(keyPrefix);
            var eventAppId = key.substr(0, endAppIdIndex);
            if(privateModule.getAppId() == eventAppId){
                handler.call(window, evt, capture);
            }
        };
        localstorageFunMap[handler] = storageCallback;
        m_window_addEventListener.call(window, evt, storageCallback, capture);
    } else {
        m_window_addEventListener.call(window, evt, handler, capture);
    }
};

window.removeEventListener = function(evt, handler, capture) {
    var e = evt.toLowerCase();
    if("storage" == e){
        m_document_removeEventListener.call(window, evt, localstorageFunMap[handler], capture);
    } else {
        m_window_removeEventListener.call(window, evt, handler, capture);
    }
};

localStorage.setItem = function(key, value){
    var currentAppId = privateModule.getAppId();
    var newKey = getNewKey(currentAppId, key);
    m_localStorage_setItem.call(localStorage, newKey, value);
    //更新以appId为键值的数据，其中存储的是所有属于该app的key值
    var keyList = m_localStorage_getItem.call(localStorage, currentAppId);
    if(null === keyList || "" === keyList){
        keyList = key;
        m_localStorage_setItem.call(localStorage, currentAppId, keyList);
    }else{
        var isNewKey = true;
        var keyArray = keyList.split(keySeparator);
        for ( var index = 0; index < keyArray.length; index++){
            var tempKey = keyArray[index];
            if(key == tempKey){
                isNewKey = false;
                break;
            }
        }
        if(isNewKey){
            keyList = keyList + keySeparator + key;
            m_localStorage_setItem.call(localStorage, currentAppId, keyList);
        }
    }
};

localStorage.getItem = function(key){
    var newKey = getNewKey(privateModule.getAppId(), key);
    var value = m_localStorage_getItem.call(localStorage, newKey);
    return value;
};

localStorage.removeItem = function(key){
    var currentAppId = privateModule.getAppId();
    var newKey = getNewKey(currentAppId, key);
    m_localStorage_removeItem.call(localStorage, newKey);
    //更新保存的keyList，删除相应的key
    var keyList = m_localStorage_getItem.call(localStorage, currentAppId);
    if(null !== keyList){
        var keyArray = keyList.split(keySeparator);
        for ( var index = 0; index < keyArray.length; index++){
            var tempKey = keyArray[index];
            if(key == tempKey){
                keyArray.splice(index, 1);
                break;
            }
        }
        m_localStorage_setItem.call(localStorage, currentAppId, keyArray.join(keySeparator));
    }
};

localStorage.key = function(index){
    var nonNegative = /^\d+(\.\d+)?$/;
    if(nonNegative.test(index)){
        var realIndex = Math.floor(index);
        var keyList = m_localStorage_getItem.call(localStorage, privateModule.getAppId());
        if((null !== keyList) && ("" !== keyList)){
            var keyArray = keyList.split(keySeparator);
            if(realIndex < keyArray.length){
                var key = keyArray[realIndex];
                return key;
            }
        }
    }
    return null;
};

localStorage.clear = function(){
    //删除当前的app所有的数据，keyList保存了所有属于该app的key值，根据它的信息
    //可以删除全部的数据
    self.clearAppData(privateModule.getAppId());
};

var self = {
    //删除指定的appId所对应的应用的数据。
    clearAppData : function(appId) {
        var keyList = m_localStorage_getItem.call(localStorage, appId);
        if(null !== keyList){
            var keyArray = keyList.split(keySeparator);
            for ( var index = 0; index < keyArray.length; index++){
                var key = keyArray[index];
                var newKey = getNewKey(appId, key);
                m_localStorage_removeItem.call(localStorage, newKey);
            }
        }
        m_localStorage_removeItem.call(localStorage, appId);
    },
    getOriginalLocalStorage : function() {
        return {'setItem': m_localStorage_setItem, 'getItem': m_localStorage_getItem, 'removeItem': m_localStorage_removeItem};
    }
};

module.exports = self;