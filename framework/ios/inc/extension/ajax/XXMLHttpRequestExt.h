//
//  XXMLHttpRequestExt.h
//  xFaceLib
//
//  Created by huanghf on 13-6-18.
//  Copyright (c) 2013年 Polyvi Inc. All rights reserved.
//
#ifdef __XXMLHttpRequestExt__

#import "XExtension.h"
@class XMutableURLRequest;

@interface XXMLHttpRequestExt : XExtension 
{
    NSMutableDictionary* _requests;
}

/*
    打开ajax请求
    @param arguments
    - 0 id     ajax的标识符
    - 1 method 操作类型，post或者get
    - 2 url    链接地址
    @param options
    - 0 XJsCallback  *callback  js回调对象
    - 1 id<XApplication> app     关联的app
 */
- (void)open:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/*
    发送ajax请求
    @param arguments
    - 0 id     ajax的标识符
    - 1 data   待发送的数据
    @param options
    - 0 XJsCallback  *callback  js回调对象
    - 1 id<XApplication> app     关联的app
 */
- (void)send:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/*
    设置http头部
    @param arguments
    - 0 id       ajax的标识符
    - 1 field    数据域
    - 2 value    数据域的新值
    @param options
    - 0 XJsCallback  *callback  js回调对象
    - 1 id<XApplication> app     关联的app
 */
- (void)setRequestHeader:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/*
    停止请求
    @param arguments
    - 0 id       ajax的标识符
    @param options
    - 0 XJsCallback  *callback  js回调对象
    - 1 id<XApplication> app     关联的app
 */
- (void)abort:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
#endif
