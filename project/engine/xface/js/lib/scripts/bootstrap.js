
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

(function (context) {
    var channel = require("xFace/channel"),
        _self = {
            boot: function (data) {

                /**
                 * Create all xFace objects once page has fully loaded and native side is ready.
                 */
                channel.join(function() {
                    var builder = require('xFace/builder'),
                        base = require('xFace/common'),
                        platform = require('xFace/platform');

                    // Drop the common globals into the window object, but be nice and don't overwrite anything.
                    builder.build(base.objects).intoButDontClobber(window);

                    // Drop the platform-specific globals into the window object
                    // and clobber any existing object.
                    builder.build(platform.objects).intoAndClobber(window);
                    // Merge the platform-specific overrides/enhancements into
                    // the window object.
                    if (typeof base.merges !== 'undefined') {
                        builder.build(base.merges).intoAndMerge(window);
                    }
                    if (typeof platform.merges !== 'undefined') {
                        builder.build(platform.merges).intoAndMerge(window);
                    }
                    // Call the platform-specific initialization
                    platform.initialize();
                    // Fire event to notify that all objects are created
                    channel.onxFaceReady.fire();

                    // Fire onDeviceReady event once all constructors have run and
                    // xFace info has been received from native side.
                    channel.join(function() {
                        require('xFace').fireDocumentEvent('deviceready',  {"data":data});
                    }, channel.deviceReadyChannelsArray);

                }, [ channel.onDOMContentLoaded, channel.onNativeReady ]);
            }
        };

    // boot up once native side is ready
    channel.onNativeReady.subscribe(_self.boot);

    // _nativeReady is global variable that the native side can set
    // to signify that the native code is ready. It is a global since
    // it may be called before any xFace JS is ready.
    if (window._nativeReady) {
        channel.onNativeReady.fire();
    }

}(window));
