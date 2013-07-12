
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
//  NSString+XStartParams.m
//  xFaceLib
//
//

#import "NSString+XStartParams.h"
#import "XConstants.h"
#import "XUtils.h"
#import "iToast.h"

#define START_PAGE_COMPONENT_KEY @"startPage"
#define DATA_COMPONENT_KEY       @"data"

@implementation NSString (XURL)

- (NSString *)appId
{
    NSURL *url = [self convertToValidURL];
    if (!url)
    {
        XLogW(@"Failed to parse start params (%@) due to it's an invalid URL!", self);
        return nil;
    }

    NSString  *appId;
    NSScanner *theScanner = [NSScanner scannerWithString:[[url absoluteString] paramsForNative]];
    [theScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"?"] intoString:&appId];
    return [appId length] ? appId : nil;
}

- (NSString *)startPage
{
    NSURL *url = [self convertToValidURL];
    if (!url)
    {
        XLogW(@"Failed to parse start params (%@) due to it's an invalid URL!", self);
        return nil;
    }

    NSDictionary *components = [self getComponents:[url query]];
    NSString *startPageComponent = CAST_TO_NIL_IF_NSNULL([components objectForKey:START_PAGE_COMPONENT_KEY]);

    NSString *startPage = [self extractValueFromExpression:startPageComponent];
    return startPage;
}

- (NSString *)data
{
    NSURL *url = [self convertToValidURL];
    if (!url)
    {
        XLogW(@"Failed to parse start params (%@) due to it's an invalid URL!", self);
        return nil;
    }

    NSString *data;
    NSDictionary *components = [self getComponents:[url query]];
    NSString *dataComponent = CAST_TO_NIL_IF_NSNULL([components objectForKey:DATA_COMPONENT_KEY]);

    if (NSOrderedSame == [dataComponent compare:@"data=" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 5)])
    {
        data = [self extractValueFromExpression:dataComponent];
    }
    else
    {
        data = [dataComponent length] ? dataComponent : nil;
    }
    return data;
}

- (NSString *)paramsForNative
{
    NSURL *url = [self convertToValidURL];
    if (!url)
    {
        XLogW(@"Failed to parse start params (%@) due to it's an invalid URL!", self);
        return nil;
    }

    NSString *paramsForNative;
    NSRange range = [[url absoluteString] rangeOfString:NATIVE_APP_CUSTOM_URL_PARAMS_SEPERATOR];
    if(NSNotFound != range.location)
    {
        paramsForNative = [[url absoluteString] substringFromIndex:(range.location + range.length)];
    }
    return [paramsForNative length] ? paramsForNative : nil;
}

@end

@implementation NSString (Privates)

- (NSString *) extractValueFromExpression:(NSString *)theExpression
{
    NSString *value;
    NSArray *components = [theExpression componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
    if ([components count] > 1)
    {
        value = [components objectAtIndex:1];
    }
    if ([value hasSuffix:@";"])
    {
        value = [value substringToIndex:[value length] - 1];
    }
    return [value length] ? value : nil;
}

- (NSDictionary *) getComponents:(NSString *)theString
{
    if (![theString length])
    {
        return nil;
    }

    NSString *startPageComponent;
    NSString *dataComponent;
    if (NSOrderedSame == [theString compare:@"startpage=" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 10)])
    {
        NSRange range = [theString rangeOfString:@";" options:NSCaseInsensitiveSearch];
        if (range.length)
        {
            startPageComponent = [theString substringToIndex:range.location];
            dataComponent = [theString substringFromIndex:(range.location + 1)];
        }
        else
        {
            startPageComponent = theString;
        }
    }
    else
    {
        dataComponent = theString;
    }

    NSDictionary *dict = @{START_PAGE_COMPONENT_KEY:CAST_TO_NSNULL_IF_NIL(startPageComponent),
                           DATA_COMPONENT_KEY:CAST_TO_NSNULL_IF_NIL(dataComponent)};
    return dict;
}

- (NSURL *)convertToValidURL
{
    NSURL *url = [NSURL URLWithString:self];
    if (!url || ![url scheme])
    {
        //如果url没有scheme,则人为添加一个scheme，以便于后面解析启动参数
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"xFace://", self]];
    }
    return url;
}

@end

