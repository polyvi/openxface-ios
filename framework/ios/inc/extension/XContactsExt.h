
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
//  XContactsExt.h
//  xFace
//
//

#ifdef __XContactsExt__

#import <Foundation/Foundation.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "XExtension.h"

@interface XContactsExt : XExtension<ABNewPersonViewControllerDelegate,
                                     ABPersonViewControllerDelegate,
                                     ABPeoplePickerNavigationControllerDelegate>
{
}

/**
    保存新的联系人或者更新已有的联系人
    @param arguments 参数列表
    - 0 XJsCallback* callback
    @param options 可选参数,存放着联系人的信息
 */
- (void) save:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    删除联系人
    @param arguments 参数列表
    - 0 XJsCallback* callback
    - 1 NSString* 要删除的联系人id
    @param options 可选参数
 */
- (void) remove: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    查找联系人
    @param arguments 参数列表
    - 0 XJsCallback* callback
    - 1 NSString* 要查找的fields
    @param options 可选参数，ContactFindOptions
 */
- (void) search:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    显示联系人UI
    @param arguments 参数列表
    - 0 XJsCallback* callback
    - 1 NSString* 要显示的联系人ID
    @param options 可选参数
        allowsEditing 标识是否可以编辑显示出的联系人
            “true”表示可以编辑
            “false”表示不可以编辑
 */
- (void) displayContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    在联系人UI中创建新的联系人
    @param arguments 参数列表
    - 0 XJsCallback* callback
    @param options 可选参数
 */
- (void) newContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    在联系人UI中选择联系人
    @param arguments 参数列表
    - 0 XJsCallback* callback
    @param options 可选参数
        allowsEditing 标识是否可以编辑显示出的联系人
            “true”表示可以编辑
            “false”表示不可以编辑
 */
- (void) chooseContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
