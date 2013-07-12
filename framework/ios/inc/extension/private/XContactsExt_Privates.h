
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

//
//  XContactsExt_Privates.h
//  xFaceLib
//
//

#ifdef __XContactsExt__

#import "XContactsExt.h"

enum XContactError
{
    UNKNOWN_ERROR = 0,
    INVALID_ARGUMENT_ERROR = 1,
    TIMEOUT_ERROR = 2,
    PENDING_OPERATION_ERROR = 3,
    IO_ERROR = 4,
    NOT_SUPPORTED_ERROR = 5,
    PERMISSION_DENIED_ERROR = 20
};
typedef NSUInteger XContactError;


@class XJsCallback;

@interface XContactsExt ()

/**
    处理创建ABAddressBookRef失败的结果通知
    @param errorCode 创建AddressBook时产生的错误码
    @param callback XJsCallback对象
 */
- (void) handleCreatingAddressBookFailure:(int)errorCode with:(XJsCallback*)callback;

@end


@interface XContactsPicker : ABPeoplePickerNavigationController
{
    BOOL allowsEditing;
    XJsCallback* jsCallback;
    NSDictionary* options;
    NSDictionary* pickedContactDictionary;
}

@property BOOL allowsEditing;
@property (strong) XJsCallback* jsCallback;
@property (nonatomic, strong) NSDictionary* options;
@property (nonatomic, strong) NSDictionary* pickedContactDictionary;

@end

@interface XNewContactsController : ABNewPersonViewController
{
    XJsCallback* jsCallback;
}

@property (strong) XJsCallback* jsCallback;

@end

/* ABPersonViewController does not have any UI to dismiss.  Adding navigationItems to it does not work properly,  then avigationItems are lost when the app goes into the background.
 The solution was to create an empty NavController in front of the ABPersonViewController.
 This causes the ABPersonViewController to have a back button. By subclassing the
 ABPersonViewController,we can override viewWillDisappear and take down the entire
 NavigationController at that time.
 */
@interface XDisplayContactViewController : ABPersonViewController
{

}

@end

/**
    用于保存 访问系统通讯录的错误
 */
@interface XAddressBookAccessError : NSObject
{

}
@property (assign) XContactError errorCode;

- (XAddressBookAccessError*)initWithCode:(XContactError)code;

@end

typedef void (^XAddressBookWorkerBlock)(
ABAddressBookRef addressBook,
XAddressBookAccessError * error
);

/**
    提供系统通讯录资源对象的创建的方法
 */
@interface XAddressBookHelper : NSObject
{

}

/**
    创建ABAddressBookRef
    @param workerBlock 处理操作ABAddressBookRef逻辑的代码块,（如：错误处理，访问联系人等逻辑 配合ABAddressBookRequestAccessCompletionHandler一起使用）
 */
- (void)createAddressBook:(XAddressBookWorkerBlock)workerBlock;

/**
    创建ABAddressBookRef
    @param error 保存返回创建AddressBook时产生的错误
    @return 返回ABAddressBookRef指针,创建失败返回NULL
 */
+ (ABAddressBookRef)createAddressBook:(XAddressBookAccessError**) error;

@end
#endif
