
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
//  XAppRunningMode.m
//  xFaceLib
//
//

#import "XAppRunningMode.h"
#import "XLocalMode.h"
#import "XOnlineMode.h"
#import "XApplication.h"
#import "XAppView.h"

@implementation XAppRunningMode

+ (id)modeWithName:(NSString*)name app:(id<XApplication>)app
{
    if(nil == name || [name isEqualToString:LOCAL_RUNNING_MODE])
    {
        return [[XLocalMode alloc] initWithApp:app];
    }
    else if([name isEqualToString:ONLINE_RUNNING_MODE])
    {
        return [[XOnlineMode alloc] initWithApp:app];
    }
    return nil;
}

- (id)initWithApp:(id<XApplication>)app
{
    //抽象方法，空实现
    return nil;
}

- (id)getURL:(id<XApplication>)app
{
    //抽象方法，空实现
    return nil;
}

- (NSString*)getIconURL:(XAppInfo*)appInfo
{
    //抽象方法，空实现
    return nil;
}

- (id<XResourceIterator>)getResourceIterator:(id<XApplication>)app
{
    //抽象方法，空实现
    return nil;
}

- (void)loadApp:(id<XApplication>)app policy:(id<XSecurityPolicy>)policy
{
    [app.appView loadApp:[self getURL:app]];
}

@end
