
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
 * 该模块用于表示各种类型的事件
 * @module event
 */

  /**
  * 该类用于表示进度事件信息（Android, iOS）<br/>
  * 应用场景参考{{#crossLink "FileTransfer"}}{{/crossLink}},{{#crossLink "xFace.AdvancedFileTransfer"}}{{/crossLink}},{{#crossLink "FileReader"}}{{/crossLink}},{{#crossLink "FileWriter"}}{{/crossLink}}
  * @class ProgressEvent
  * @platform Android, iOS
  * @since 3.0.0
  */
 var ProgressEvent = (function() {
    return function ProgressEvent(type, dict) {
        /**
         * 事件类型（Android, iOS）<br/>
         * @property type
         * @type String
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.type = type;
        this.bubbles = false;
        this.cancelBubble = false;
        /**
         * 用于标识报进度的操作是否能够被取消（Android, iOS）
         * @property cancelable
         * @default false
         * @type Boolean
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.cancelable = false;
        /**
         * 用于标识数据总长度是否可获取（Android, iOS）
         * @property lengthAvailable
         * @default false
         * @type Boolean
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.lengthAvailable = false;
        /**
         * 已经处理/加载的数据长度，单位byte（Android, iOS）
         * @property loaded
         * @default 0
         * @type Number
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.loaded = dict && dict.loaded ? dict.loaded : 0;
        /**
         * 要处理/加载的数据总长度，单位byte（lengthAvailable为true时有效）（Android, iOS）
         * @property total
         * @default 0
         * @type Number
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.total = dict && dict.total ? dict.total : 0;
        /**
         * 进度事件的目标对象（Android, iOS）
         * @property target
         * @default null
         * @type Object
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.target = dict && dict.target ? dict.target : null;
    };
})();

module.exports = ProgressEvent;