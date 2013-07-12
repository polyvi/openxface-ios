
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

var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    FileReader = require('xFace/extension/FileReader'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

module.exports = {
    readAsText:function(file, encoding) {
    argscheck.checkArgs('oS', 'FileReader.readAsText', arguments);
        this.fileName = '';
        if (typeof file.fullPath === 'undefined') {
            this.fileName = file;
        } else {
            this.fileName = file.fullPath;
        }

        if (this.readyState == FileReader.LOADING) {
            throw new FileError(FileError.INVALID_STATE_ERR);
        }

        this.readyState = FileReader.LOADING;

        if (typeof this.onloadstart === "function") {
            this.onloadstart(new ProgressEvent("loadstart", {target:this}));
        }

        var enc = encoding ? encoding : "UTF-8";

        var me = this;
        exec(
            function(r) {
                if (me.readyState === FileReader.DONE) {
                    return;
                }

                me.result = decodeURIComponent(r);

                if (typeof me.onload === "function") {
                    me.onload(new ProgressEvent("load", {target:me}));
                }

                me.readyState = FileReader.DONE;

                if (typeof me.onloadend === "function") {
                    me.onloadend(new ProgressEvent("loadend", {target:me}));
                }
            },

            function(e) {
                if (me.readyState === FileReader.DONE) {
                    return;
                }

                me.readyState = FileReader.DONE;

                me.result = null;

                me.error = new FileError(e);

                if (typeof me.onerror === "function") {
                    me.onerror(new ProgressEvent("error", {target:me}));
                }

                if (typeof me.onloadend === "function") {
                    me.onloadend(new ProgressEvent("loadend", {target:me}));
                }
            },
            null, "File", "readAsText", [this.fileName, enc]);
    }
};