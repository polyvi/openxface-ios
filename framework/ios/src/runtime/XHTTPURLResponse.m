
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
//  XHTTPURLResponse.m
//  xFaceLib
//
//

#import "XHTTPURLResponse.h"

#define HTTP_STATUS_CODE_OK                200             //OK
#define HTTP_STATUS_CODE_UNAUTHORIZED      401             //Unauthorized
#define RESPONSE_MIME_TYPE_TEXT_PLAIN      @"text/plain"
#define RESPONSE_ENCODING_NAME_UTF8        @"UTF-8"

@implementation XHTTPURLResponse

@synthesize statusCode;

- (id)initWithUnauthorizedURL:(NSURL *)url
{
    self = [super initWithURL:url MIMEType:RESPONSE_MIME_TYPE_TEXT_PLAIN expectedContentLength:-1 textEncodingName:RESPONSE_ENCODING_NAME_UTF8];
    if (self)
    {
        self.statusCode = HTTP_STATUS_CODE_UNAUTHORIZED;
    }
    return self;
}

- (id)initWithBlankResponse:(NSURL *)url
{
    self = [super initWithURL:url MIMEType:RESPONSE_MIME_TYPE_TEXT_PLAIN expectedContentLength:-1 textEncodingName:RESPONSE_ENCODING_NAME_UTF8];
    if (self)
    {
        self.statusCode = HTTP_STATUS_CODE_OK;
    }
    return self;
}

- (NSDictionary*)allHeaderFields
{
    return nil;
}

@end
