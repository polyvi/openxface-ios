
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
 * 用于保存app之间静态共享的数据
 * @module setting
 */
var argscheck = require('xFace/argscheck'),
    xFace = require('xFace');
var utils = require("xFace/utils");
var gstorage = require('xFace/localStorage');


 /**
 * 此类用于保存app之间静态共享的数据，如xFace.Setting.setPreference("key","value")用来保存一个键值对。
 * 此类不能通过new来创建相应的对象，只能通过xFace.Setting对象来直接使用该类中定义的方法(Android,iOS,WP8)
 * @class Setting
 * @static
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
var Setting  = function() {};

var m_localStorage_setItem = gstorage.getOriginalLocalStorage().setItem;
var m_localStorage_getItem = gstorage.getOriginalLocalStorage().getItem;
var m_localStorage_removeItem = gstorage.getOriginalLocalStorage().removeItem;

var keyPrefix = "_";
var keySeparator = ",";

var id = "settingPreference";

function getNewKey(id, key){
    var newKey = id + keyPrefix + key;
    return newKey;
}

/**
 * 存储一个键值对(Android,iOS,WP8)
 * @example
        xFace.Setting.setPreference("key", "value");
 * @method setPreference
 * @param {String} key         键值对的键
 * @param {String} value       键值对的键所对应的数据
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
Setting.prototype.setPreference = function(key, value){
    argscheck.checkArgs('ss', 'xFace.Setting.setPreference', arguments);
    var newKey = getNewKey(id, key);
    m_localStorage_setItem.call(localStorage, newKey, value);
    //更新以id为键值的数据，其中存储的是所有属于Setting的key值
    var keyList = m_localStorage_getItem.call(localStorage, id);
    if(null === keyList || "" === keyList){
        keyList = key;
        m_localStorage_setItem.call(localStorage, id, keyList);
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
            m_localStorage_setItem.call(localStorage, id, keyList);
        }
    }
};

/**
 * 获取一个键对应的值(Android,iOS,WP8)
 * @example
        xFace.Setting.getPreference("key");
 * @method getPreference
 * @param {String} key         键值对的键
 * @return {String}         返回指定键所对应的键值
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
Setting.prototype.getPreference = function(key){
    argscheck.checkArgs('s', 'xFace.Setting.getPreference', arguments);
    var newKey = getNewKey(id, key);
    var value = m_localStorage_getItem.call(localStorage, newKey);
    return value;
};

/**
 * 删除配置中的一个键及其对应的值(Android,iOS,WP8)
 * @example
        xFace.Setting.removePreference("key");
 * @method removePreference
 * @param {String} key         键值对的键
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
Setting.prototype.removePreference = function(key){
    argscheck.checkArgs('s', 'xFace.Setting.removePreference', arguments);
    var newKey = getNewKey(id, key);
    m_localStorage_removeItem.call(localStorage, newKey);
    //更新保存的keyList，删除相应的key
    var keyList = m_localStorage_getItem.call(localStorage, id);
    if(null !== keyList){
        var keyArray = keyList.split(keySeparator);
        for ( var index = 0; index < keyArray.length; index++){
            var tempKey = keyArray[index];
            if(key == tempKey){
                keyArray.splice(index, 1);
                break;
            }
        }
        m_localStorage_setItem.call(localStorage, id, keyArray.join(keySeparator));
    }
};

/**
 * 获取指定下标所在位置的键(Android,iOS,WP8)
 * @examle
        xFace.Setting.key(1);
 * @method key
 * @param {String} index 键所在位置的下标
 * @return {String}  返回指定位置的键的名称
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
Setting.prototype.key = function(index){
    argscheck.checkArgs('s', 'xFace.Setting.key', arguments);
    var nonNegative = /^\d+(\.\d+)?$/;
    if(nonNegative.test(index)){
        var realIndex = Math.floor(index);
        var keyList = m_localStorage_getItem.call(localStorage, id);
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

/**
 * 删除配置中存储的所有键值对(Android,iOS,WP8)
 * @example
        xFace.Setting.clear();
 * @method clear
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
Setting.prototype.clear = function(){
    //删除setting的数据，keyList保存了所有属于Setting的key值，根据它的信息
    //可以删除全部的数据
    var keyList = m_localStorage_getItem.call(localStorage, id);
    if(null !== keyList){
        var keyArray = keyList.split(keySeparator);
        for ( var index = 0; index < keyArray.length; index++){
            var key = keyArray[index];
            var newKey = getNewKey(id, key);
            m_localStorage_removeItem.call(localStorage, newKey);
        }
    }
    m_localStorage_removeItem.call(localStorage, id);
};

module.exports = new Setting();