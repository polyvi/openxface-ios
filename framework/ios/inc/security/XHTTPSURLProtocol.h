//
//  XHTTPSURLProtocol.h
//  xFaceLib
//
//  Created by huanghf on 13-6-27.
//  Copyright (c) 2013年 Polyvi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
	该类用于处理https类型的ajax请求
 */
@interface XHTTPSURLProtocol : NSURLProtocol
{
    NSMutableData* _data;
}

@end
