
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
 * @module media
 */

/**
 * 此类包含了所有 Media 错误类型的详细描述（Android, iOS, WP8）<br/>
 * 该类不能通过new来创建相应的对象，Media的失败回调会返回该对象的实例
 * @class MediaError
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */

/**
 * 此类包含了所有 Media errors 的相关信息.
 *
 * @constructor
 */
var MediaError = function(code, msg) {

/**
 * 错误码 (Android, iOS, WP8).<br/>
 * 所有的错误类型请参考 {{#crossLink "MediaError"}}{{/crossLink}}中定义的错误码
 * @example
        function errorCallBack(mediaError)
        {
            switch(mediaError.code)
            {
                case MediaError.MEDIA_ERR_NONE_ACTIVE:
                    //handle none atctive error
                    alert(mediaError.message);
                    break;
                case MediaError.MEDIA_ERR_ABORTED:
                    //
                    break;
                case MediaError.MEDIA_ERR_NETWORK:
                    //
                    break;
                case MediaError.MEDIA_ERR_DECODE:
                    //
                    break;
                case MediaError.MEDIA_ERR_NONE_SUPPORTED:
                    //
                    break;
            }
        }
 * @property code
 * @type Number
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
this.code = (code !== undefined ? code : null);

/**
 * 错误码对应的错误描述信息 (Android, iOS, WP8).<br/>
 * 具体用法请参见MediaError.code的示例
 * @property message
 * @type String
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
this.message = msg || "";

};

/**
 * 非活动状态的错误码 (Android, iOS, WP8).
 * @property MEDIA_ERR_NONE_ACTIVE
 * @type Number
 * @final
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
MediaError.MEDIA_ERR_NONE_ACTIVE    = 0;

/**
 * 被中止的错误码 (Android, iOS, WP8).
 * @property MEDIA_ERR_ABORTED
 * @type Number
 * @final
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
MediaError.MEDIA_ERR_ABORTED        = 1;

/**
 * 网络连接失败的错误码 (Android, iOS, WP8).
 * @property MEDIA_ERR_NETWORK
 * @type Number
 * @final
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
MediaError.MEDIA_ERR_NETWORK        = 2;

/**
 * 音频解码出错的错误码 (Android, iOS, WP8).
 * @property MEDIA_ERR_DECODE
 * @type Number
 * @final
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
MediaError.MEDIA_ERR_DECODE         = 3;

/**
 * 文件格式不支持的错误码 (Android, iOS, WP8).
 * @property MEDIA_ERR_NONE_SUPPORTED
 * @type Number
 * @final
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
MediaError.MEDIA_ERR_NONE_SUPPORTED = 4;

module.exports = MediaError;