
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
//  XApplicationTests.h
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>

@protocol XApplication;

@class XRuntime;
@class XAppWebView;

/**
    用作所有依赖于app的测试的基类
 */
@interface XApplicationTests : SenTestCase
{
    XRuntime             *runtime;
    XAppWebView          *appView;
    id<XApplication>      app;
}

@property (strong, nonatomic, readonly)XRuntime         *runtime;
@property (strong, nonatomic, readonly)XAppWebView      *appView;
@property (strong, nonatomic, readonly)id<XApplication>  app;

@end
