
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
 * 该模块提供多媒体的功能，包括音频和视频
 * @module media
 * @main media
 */
var argscheck = require('xFace/argscheck'),
    utils = require('xFace/utils'),
    exec = require('xFace/exec');

var mediaObjects = {};

/**
 *  Media 扩展提供播放音频和录音的功能（Android, iOS, WP8）
 @example
      var src = "test.mp3";
      var localAudio = new Media(src, onSuccess, onError, onStatusChange);

      function onSuccess() {}

      function onError(error) {
          alert('Error : ' + ERROR_MSG[error.code]);
      }

      function onStatusChange(state) {
          alert("Status now is : " + Media.MEDIA_MSG[state]);
      }

 * @class Media
 * @constructor
 * @param {String} [src] 源文件地址
 * @param {Function} [successCallback]   成功回调函数
 * @param {Function} [errorCallback]   失败回调函数
 * @param {MediaError} errorCallback.error   error参数，详情请参见{{#crossLink "MediaError"}}{{/crossLink}}
 * @param {Function} [statusCallback]  状态变化回调
 * @param {Number} statusCallback.state 状态值，包括Media.MEDIA_STARTING、Media.MEDIA_RUNNING和Media.MEDIA_PAUSED等
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var Media = function(src, successCallback, errorCallback, statusCallback) {
    argscheck.checkArgs('SFFF', 'Media.Media', arguments);
    this.id = utils.createUUID();
    mediaObjects[this.id] = this;
    this.src = src;
    this.successCallback = successCallback;
    this.errorCallback = errorCallback;
    this.statusCallback = statusCallback;
    this._duration = -1;
    this._position = -1;
};

Media.MEDIA_STATE = 1;
Media.MEDIA_DURATION = 2;
Media.MEDIA_POSITION = 3;
Media.MEDIA_ERROR = 4;

/**
 * 音频未知状态的常量 (Android, iOS, WP8).
 * @example
        Media.MEDIA_NONE
 * @property MEDIA_NONE
 * @type Number
 * @final
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.MEDIA_NONE = 0;

/**
 * 音频准备播放状态的常量 (Android, iOS, WP8).
 * @example
        Media.MEDIA_STARTING
 * @property MEDIA_STARTING
 * @type Number
 * @final
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.MEDIA_STARTING = 1;

/**
 * 音频正在播放状态的常量 (Android, iOS, WP8).
 * @example
        Media.MEDIA_RUNNING
 * @property MEDIA_RUNNING
 * @type Number
 * @final
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.MEDIA_RUNNING = 2;

/**
 * 音频暂停状态的常量 (Android, iOS, WP8).
 * @example
        Media.MEDIA_PAUSED
 * @property MEDIA_PAUSED
 * @type Number
 * @final
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.MEDIA_PAUSED = 3;

/**
 * 音频停止状态的常量 (Android, iOS, WP8).
 * @example
        Media.MEDIA_STOPPED
 * @property MEDIA_STOPPED
 * @type Number
 * @final
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.MEDIA_STOPPED = 4;

/**
 * 音频状态的对应字符串信息 (Android, iOS, WP8).
 * @example
       function onStatusChange(state) {
          alert("Status now is : " + Media.MEDIA_MSG[state]);
       }
 * @property MEDIA_MSG
 * @type Array
 * @final
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.MEDIA_MSG = ["None", "Starting", "Running", "Paused", "Stopped"];

// "static" 函数返回已存在的对象.
Media.get = function(id) {
    return mediaObjects[id];
};

/**
 * 播放音频文件（Android, iOS, WP8）
 @example
      media.play();
 * @method play
 * @param {Object} [options] 可选参数（Android无效）<br/>
 * @param {boolean} [options.playAudioWhenScreenIsLocked=true] 表示是否允许锁屏时播放音频
 * @param {Number} [options.numberOfLoops=0] 播放循环次数
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.prototype.play = function(options) {
    argscheck.checkArgs('O', 'Media.play', arguments);
    exec(null, null, null, "Audio", "play", [this.id, this.src, options]);
};

/**
 * 停止正在播放的音频（Android, iOS, WP8）
 @example
      media.stop();
 * @method stop
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.prototype.stop = function() {
    var me = this;
    exec(
        function() {
            me._position = 0;
            me.successCallback();
        },
        this.errorCallback,
        null,
        "Audio", "stop", [this.id]
    );
};

/**
 * 跳转到指定时间点（Android, iOS, WP8）
 @example
      media.seekTo(50000);
 * @method seekTo
 * @param {Number} milliseconds 时间点，以毫秒为单位
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.prototype.seekTo = function(milliseconds) {
    argscheck.checkArgs('n', 'Media.seekTo', arguments);
    var me = this;
    exec(
        function(p) {
            me._position = p;
        },
        this.errorCallback,
        null,
        "Audio", "seekTo", [this.id, milliseconds]
    );
};

/**
 * 暂停正在播放的音频（Android, iOS, WP8）
 @example
      media.pause();
 * @method pause
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.prototype.pause = function() {
    exec(null, this.errorCallback, null, "Audio", "pause", [this.id]);
};

/**
 * 获取音频的片长（Android, iOS, WP8）<br/>
 * 该函数仅对处于下列播放状态的 audio 有效：playing, paused 或者 stopped.
 @example
      var duration = media.getDuration();
 * @method getDuration
 * @return {Number}    片长已知时则返回实际值，否则返回 -1，以秒为单位
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.prototype.getDuration = function() {
    return this._duration;
};

/**
 * 获取音频当前的播放位置（Android, iOS, WP8）
 @example
      media = new Media(src, onSuccess, onError, onStatusChange);
      // 获取音频的当前播放位置
      media.getCurrentPosition(
          // 成功回调
          function(position) {
              if (position > -1) {
                  setAudioPosition((position) + " sec");
              }
          },
          // 失败回调
          function() {
              console.log("Error getting pos");
              setAudioPosition("Error");
          }
      );
 * @method getCurrentPosition
 * @param {Function} successCallback 成功回调函数
 * @param {String} successCallback.position 当前的播放位置，以秒为单位
 * @param {Function} [errorCallback] 失败回调函数
 * @param {String} errorCallback.error 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.prototype.getCurrentPosition = function(successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'Media.getCurrentPosition', arguments);
    var me = this;
    exec(
        function(position) {
            me._position = position;
            successCallback(position);
        },
        errorCallback,
        null,
        "Audio", "getCurrentPosition", [this.id]
    );
};

/**
 * 设置音频的播放音量（Android, iOS, WP8）
 @example
      media.setVolume();
 * @method setVolume
 * @param {Number} value 音量值(取值范围从0.0 到 1.0)
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.prototype.setVolume = function(value) {
    argscheck.checkArgs('n', 'Media.setVolume', arguments);
    exec(null,this.errorCallback,null,"Audio", "setVolume", [this.id,value]);
};

/**
 * 释放资源（Android, iOS, WP8）
 @example
      media.release();
 * @method release
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.prototype.release = function() {
    exec(null, this.errorCallback, null, "Audio", "release", [this.id]);
};

/**
 * 开始录音（Android, iOS, WP8）
 @example
      // 录音
      var mediaRec;
      function startRecord() {
          mediaRec = new Media("recording.mp3", onSuccess, onError);
          mediaRec.startRecord();
      }
 * @method startRecord
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.prototype.startRecord = function() {
    exec(this.successCallback, this.errorCallback, null, "Audio", "startRecording", [this.id, this.src]);
};

/**
 * 停止录音（Android, iOS, WP8）
 @example
      function stopRecord() {
          if (mediaRec != null) {
              mediaRec.stopRecord();
          }
      }
 * @method stopRecord
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Media.prototype.stopRecord = function() {
    exec(this.successCallback, this.errorCallback, null, "Audio", "stopRecording", [this.id]);
};

/**
 * Audio 的状态回调.
 * PRIVATE
 *
 * @param id            audio 对象的 id (string)
 * @param status        状态码 (int)
 * @param msg           状态信息 (string)
 */
Media.onStatus = function(id, msg, value) {
    var media = mediaObjects[id];
    // 如果状态有更新
    if (msg === Media.MEDIA_STATE) {
        if (value === Media.MEDIA_STOPPED) {
            if (media.successCallback) {
                media.successCallback();
            }
        }

        if (media.statusCallback) {
            media.statusCallback(value);
        }
    } else if (msg === Media.MEDIA_DURATION) {
        media._duration = value;
    } else if (msg === Media.MEDIA_ERROR) {
        if (media.errorCallback) {
            media.errorCallback(value);
        }
    } else if (msg === Media.MEDIA_POSITION) {
        media._position = value;
    }
};

module.exports = Media;
