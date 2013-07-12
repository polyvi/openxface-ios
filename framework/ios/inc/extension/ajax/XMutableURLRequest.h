//
//  XMutableURLRequest.h
//  xFaceLib
//
//  Created by huanghf on 13-6-18.
//  Copyright (c) 2013年 Polyvi Inc. All rights reserved.
//

#ifdef __XXMLHttpRequestExt__

#import <Foundation/Foundation.h>

typedef uint State;

@class XJsCallback;

@interface XMutableURLRequest : NSMutableURLRequest <NSURLConnectionDelegate>
{
    NSMutableData* _data;
    NSURLConnection* _theConnection;
    NSHTTPURLResponse* _response;
}

/**
    ajax的唯一标识符
 */
@property NSString* Id;

/**
    接收的字符串
 */
@property NSString* responseText;

/**
    ajax状态
 */
@property (nonatomic) State readyState;

/**
    网络状态
 */
@property int status;

/**
    成功回调
    @param ajax ajax对应的js对象
 */
@property (strong)void (^successCallBack)(NSDictionary* ajax);

/**
    失败回调
    @param error  错误对象
 */
@property (strong)void (^errorCallBack)(NSDictionary* error);

/**
    打开ajax
    @param method  操作类型，post或者get
    @param url     链接地址
 */
- (void)open:(NSString*)method url:(NSString*)url;

/**
    发送请求
    @param data 需要post的数据
 */
- (void)sendData:(id)data;

/**
    停止请求
 */
- (void)abort;

@end

#endif
