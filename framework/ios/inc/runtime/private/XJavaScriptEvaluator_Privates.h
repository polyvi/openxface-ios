
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
//  XJavaScriptEvaluator_Privates.h
//  xFaceLib
//
//

#import <UIKit/UIKit.h>
#import "XJavaScriptEvaluator.h"

@interface XJavaScriptEvaluator ()

/**
    执行js语句的辅助方法，可以根据当前情况决定是否立即执行js语句
    @param js 待执行的js语句
 */
- (void)evalJsHelper:(NSString*)js;

/**
    立即执行js语句
    @param NSString 待执行的js语句：
 */
- (void)evalJs:(NSString *)js;

@end
