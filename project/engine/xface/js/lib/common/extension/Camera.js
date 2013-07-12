
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
 * 该模块提供对图像采集的访问.
 * @module camera
 * @main camera
 */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    Camera = require('xFace/extension/CameraConstants');

/**
 * 该类定义了图像采集的相关接口（Android, iOS, WP8）<br/>
 * 该类不能通过new来创建相应的对象，只能通过navigator.camera对象来直接使用该类中定义的方法<br/>
 * @class Camera
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var cameraExport = {};

// Tack on the Camera Constants to the base camera plugin.
for (var key in Camera) {
    cameraExport[key] = Camera[key];
}

/**
 * 根据"options.sourceType"从 source中获取一张图片,并根据"options.destinationType"
 * 决定返回图片的结果（Android, iOS, WP8）
 * @example
        navigator.camera.getPicture(onSuccess, onFail, { quality: 50,
        destinationType: Camera.DestinationType.FILE_URI,
        sourceType: Camera.PictureSourceType.CAMERA,
        targetWidth: 260,
        targetHeight: 200});

 * @method getPicture
 * @param {Function} successCallback 成功回调方法
 * @param {String} successCallback.data options.destinationType为DATA_URL返回base64编码的数据；<br/>options.destinationType为FILE_URI返回文件url
 * @param {Function} [errorCallback] 失败回调方法
 * @param {String} errorCallback.msg 错误信息
 * @param {Object} [options] 可选参数<br/>
 * @param {Number} options.quality    图像质量(0-100)，iOS设置在50 以下，避免在一些设备上出现内存错误
 * @param {Number} options.destinationType    目标图像的数据类型,取值范围参见{{#crossLink "Camera.DestinationType"}}{{/crossLink}}
 * @param {Number} options.sourceType    图像资源类型,取值范围参见{{#crossLink "Camera.PictureSourceType"}}{{/crossLink}}
 * @param {Boolean} options.allowEdit    是否允许编辑<br/>WP8不支持,Android系统下当allowEdit设置为true时，在取得picture后会出现一个由targetWidth和targetHeight指定大小的裁剪框，裁剪后图片大小由targetWidth和targetHeight指定<br/>
                                         iOS下allowEdit设置为true时，在取得picture后会出现一个固定大小的裁剪框，targetWidth和targetHeight用来设置裁剪后图片的大小
 * @param {Number} options.encodingType  编码类型，Android不支持，取值范围参见{{#crossLink "Camera.EncodingType"}}{{/crossLink}}
 * @param {Number} options.targetWidth   图像宽度
 * @param {Number} options.targetHeight  图像高度
 * @param {Number} options.mediaType     媒体文件类型，取值范围参见{{#crossLink "Camera.MediaType"}}{{/crossLink}}
 * @param {Boolean} options.saveToPhotoAlbum    图像是否保存到设备的相册
 * @param {Boolean} cropToSize           是否按指定的尺寸裁剪，默认为false
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
cameraExport.getPicture = function(successCallback, errorCallback, options) {
    argscheck.checkArgs('fFO', 'camera.getPicture', arguments);
    var quality = 50;
    if (options && typeof options.quality == "number") {
        quality = options.quality;
    } else if (options && typeof options.quality == "string") {
        var qlity = parseInt(options.quality, 10);
        if (isNaN(qlity) === false) {
            quality = qlity.valueOf();
        }
    }

    var destinationType = Camera.DestinationType.FILE_URI;
    if (typeof options.destinationType == "number") {
        destinationType = options.destinationType;
    }

    var sourceType = Camera.PictureSourceType.CAMERA;
    if (typeof options.sourceType == "number") {
        sourceType = options.sourceType;
    }

    var targetWidth = -1;
    if (typeof options.targetWidth == "number") {
        targetWidth = options.targetWidth;
    } else if (typeof options.targetWidth == "string") {
        var width = parseInt(options.targetWidth, 10);
        if (isNaN(width) === false) {
            targetWidth = width.valueOf();
        }
    }

    var targetHeight = -1;
    if (typeof options.targetHeight == "number") {
        targetHeight = options.targetHeight;
    } else if (typeof options.targetHeight == "string") {
        var height = parseInt(options.targetHeight, 10);
        if (isNaN(height) === false) {
            targetHeight = height.valueOf();
        }
    }

    var encodingType = Camera.EncodingType.JPEG;
    if (typeof options.encodingType == "number") {
        encodingType = options.encodingType;
    }

    var mediaType = Camera.MediaType.PICTURE;
    if (typeof options.mediaType == "number") {
        mediaType = options.mediaType;
    }
    var allowEdit = false;
    if (typeof options.allowEdit == "boolean") {
        allowEdit = options.allowEdit;
    } else if (typeof options.allowEdit == "number") {
        allowEdit = options.allowEdit <= 0 ? false : true;
    }
    var correctOrientation = false;
    if (typeof options.correctOrientation == "boolean") {
        correctOrientation = options.correctOrientation;
    } else if (typeof options.correctOrientation == "number") {
        correctOrientation = options.correctOrientation <=0 ? false : true;
    }
    var saveToPhotoAlbum = false;
    if (typeof options.saveToPhotoAlbum == "boolean") {
        saveToPhotoAlbum = options.saveToPhotoAlbum;
    } else if (typeof options.saveToPhotoAlbum == "number") {
        saveToPhotoAlbum = options.saveToPhotoAlbum <=0 ? false : true;
    }
    var cropToSize = false;
    if (typeof options.cropToSize == "boolean") {
        cropToSize = options.cropToSize;
    } else if (typeof options.cropToSize == "number") {
        cropToSize = options.cropToSize <=0 ? false : true;
    }
   /**
    * @param options 获取图片的参数
    * - 0 NSString* callbackId
    * - 1 quality 压缩质量百分比
    * - 2 destinationType 目标结果的类型
    * - 3 sourceType 图像来源;如 相片库/照相机/保存的相片
    * - 4 targetWidth 目标尺寸宽度
    * - 5 targetHeight 目标尺寸高度
    * - 6 encodingType 编码格式
    * - 7 mediaType 媒体类型
    * - 8 allowEdit 是否允许编辑
    * - 9 correctOrientation 正确的方向
    * - 10 saveToPhotoAlbum 保存到相册
    * - 11 cropToSize 是否按指定的尺寸裁剪，默认为false
    */
   exec(successCallback, errorCallback, null, "Camera", "takePicture", [quality, destinationType, sourceType, targetWidth, targetHeight, encodingType, mediaType, allowEdit, correctOrientation, saveToPhotoAlbum, cropToSize]);
};

module.exports = cameraExport;
