
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
 * 封装设备所支持参数的一个集合
 */
function ConfigurationData() {
    // 小写的ASCII编码字符串，表示多媒体类型
    this.type = null;
    // height 属性表示图片或者视频的高度（像素）
    // 如果是音频，此属性为0
    this.height = 0;
    // width 属性表示图片或者视频的宽度（像素）
    // 如果是音频，此属性为0
    this.width = 0;
}

module.exports = ConfigurationData;