
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

require('xFace/ajax');

module.exports = {
    objects: {
        xFace: {
            path: 'xFace',
            children: {
                app:{
                  path: 'xFace/app'
                },
                exec: {
                    path: 'xFace/exec'
                },
                AMS:{
                    path:'xFace/extension/ams'
                },
                Message: {
                    path: 'xFace/extension/Message'
                },
                Messaging: {
                    path: 'xFace/extension/Messaging'
                },
                MessageTypes: {
                    path: 'xFace/extension/MessageTypes'
                },
                Telephony: {
                    path: 'xFace/extension/Telephony'
                },
                AdvancedFileTransfer: {
                    path: 'xFace/extension/AdvancedFileTransfer'
                },
                XMLHttpRequest: {
                    path: 'xFace/extension/XMLHttpRequest'
                 },
                Security: {
                   path: 'xFace/extension/Security'
                },
                Setting: {
                   path: 'xFace/extension/Setting'
                },
                PushNotification: {
                   path: 'xFace/extension/PushNotification'
                },
                Zip: {
                   path: 'xFace/extension/Zip'
                },
                BarcodeScanner: {
                   path:'xFace/extension/BarcodeScanner'
                },
                IdleWatcher:{
                    path: 'xFace/extension/IdleWatcher'
                },
                ui: {
                    children: {
                        Calendar:{
                            path:'xFace/extension/Calendar'
                        }
                    }
                }
            }
        },
        navigator: {
            children: {
                app: {
                    path: 'xFace/extension/app'
                },
                accelerometer: {
                    path: 'xFace/extension/accelerometer'
                },
                compass: {
                    path: 'xFace/extension/compass'
                },
                network: {
                    children: {
                        connection: {
                            path: 'xFace/extension/network'
                        }
                    }
                },
                contacts: {
                    path: 'xFace/extension/contacts'
                },
                notification: {
                    path: 'xFace/extension/Notification'
                },
                battery:{
                    path: 'xFace/extension/battery'
                },
                camera:{
                    path: 'xFace/extension/Camera'
                },
                device:{
                    children:{
                        capture: {
                            path: 'xFace/extension/capture'
                        }
                    }
                },
                splashscreen: {
                    path: 'xFace/extension/splashscreen'
                }
            }
        },
        Acceleration: {
            path: 'xFace/extension/Acceleration'
        },
        Camera:{
            path: 'xFace/extension/CameraConstants'
        },
        Connection: {
            path: 'xFace/extension/Connection'
        },
        Contact: {
            path: 'xFace/extension/Contact'
        },
        ContactAddress: {
            path: 'xFace/extension/ContactAddress'
        },
        ContactError: {
            path: 'xFace/extension/ContactError'
        },
        ContactField: {
            path: 'xFace/extension/ContactField'
        },
        ContactAccountType: {
            path: 'xFace/extension/ContactAccountType'
        },
        ContactFindOptions: {
            path: 'xFace/extension/ContactFindOptions'
        },
        ContactName: {
            path: 'xFace/extension/ContactName'
        },
        ContactOrganization: {
            path: 'xFace/extension/ContactOrganization'
        },
        device: {
            path: 'xFace/extension/device'
        },
        DirectoryEntry: {
            path: 'xFace/extension/DirectoryEntry'
        },
        DirectoryReader: {
            path: 'xFace/extension/DirectoryReader'
        },
        Entry: {
            path: 'xFace/extension/Entry'
        },
        FileEntry: {
            path: 'xFace/extension/FileEntry'
        },
        File: {
            path: 'xFace/extension/File'
        },
        FileError: {
            path: 'xFace/extension/FileError'
        },
        FileWriter: {
            path: 'xFace/extension/FileWriter'
        },
        FileReader: {
            path: 'xFace/extension/FileReader'
        },
        FileTransfer: {
            path: 'xFace/extension/FileTransfer'
        },
        FileTransferError: {
            path: 'xFace/extension/FileTransferError'
        },
        FileUploadOptions: {
            path: 'xFace/extension/FileUploadOptions'
        },
        FileUploadResult: {
            path: 'xFace/extension/FileUploadResult'
        },
        FileSystem: {
            path: 'xFace/extension/FileSystem'
        },
        Flags: {
            path: 'xFace/extension/Flags'
        },
        LocalFileSystem: {
            path: 'xFace/extension/LocalFileSystem'
        },
        Metadata: {
            path: 'xFace/extension/Metadata'
        },
        requestFileSystem: {
            path: 'xFace/extension/requestFileSystem'
        },
        resolveLocalFileSystemURI: {
            path: 'xFace/extension/resolveLocalFileSystemURI'
        },
        ProgressEvent: {
            path: 'xFace/extension/ProgressEvent'
        },
        CompassHeading:{
            path: 'xFace/extension/CompassHeading'
        },
        CompassOptions:{
            path: 'xFace/extension/CompassOptions'
        },
        CompassError:{
            path: 'xFace/extension/CompassError'
        },
        CaptureError: {
            path: 'xFace/extension/CaptureError'
        },
        CaptureAudioOptions:{
            path: 'xFace/extension/CaptureAudioOptions'
        },
        CaptureImageOptions: {
            path: 'xFace/extension/CaptureImageOptions'
        },
        CaptureVideoOptions: {
            path: 'xFace/extension/CaptureVideoOptions'
        },
        CaptureScreenOptions: {
            path: 'xFace/extension/CaptureScreenOptions'
        },
        CaptureScreenResult: {
            path: 'xFace/extension/CaptureScreenResult'
        },
        ConfigurationData: {
            path: 'xFace/extension/ConfigurationData'
        },
        Media: {
            path: 'xFace/extension/Media'
        },
        MediaError: {
            path: 'xFace/extension/MediaError'
        },
        MediaFile: {
            path: 'xFace/extension/MediaFile'
        },
        MediaFileData:{
            path: 'xFace/extension/MediaFileData'
        },
        ZipError: {
             path: 'xFace/extension/ZipError'
        },
        ZipOptions:{
             path: 'xFace/extension/ZipOptions'
        },
        AmsError: {
             path: 'xFace/extension/AmsError'
        },
        AmsState: {
             path: 'xFace/extension/AmsState'
        },
        AmsOperationType: {
             path: 'xFace/extension/AmsOperationType'
        },
        SecurityOptions: {
            path: 'xFace/extension/SecurityOptions'
        },
        StringEncodeType: {
            path: 'xFace/extension/StringEncodeType'
        }
    },
    merges: {
    }
};
