
/*
 Copyright 2012-2013, Polyvi Inc. (http://polyvi.github.io/openxface)
 This program is distributed under the terms of the GNU General Public License.

 This file is part of xFace.

 xFace is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 xFace is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with xFace.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  XMutableURLRequest.h
//  xFaceLib
//
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
