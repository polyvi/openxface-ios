
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

module.exports = {
    toURL:function() {
        return "file://localhost" + this.fullPath;
    },
    toURI: function() {
        console.log("DEPRECATED: Update your code to use 'toURL'");
        return "file://localhost" + this.fullPath;
    },
    /**
    * 设置entry对象的Metadata属性.
    */
    setMetadata: function(successCallback, errorCallback, metadataObject) {
        var argscheck = require('xFace/argscheck');
        argscheck.checkArgs('fFO', 'FileEntry.setMetadata', arguments);
        exec(successCallback, errorCallback, null, "File", "setMetadata", [this.fullPath, metadataObject]);
    }
};
