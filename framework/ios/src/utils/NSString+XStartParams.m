
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

@implementation NSString (XStartParams)

- (NSString *)startPage
{
    NSDictionary *components = [self getComponents];
    NSString *startPageComponent = CAST_TO_NIL_IF_NSNULL([components objectForKey:START_PAGE_COMPONENT_KEY]);

    NSString *startPage = [self extractValueFromExpression:startPageComponent];

    NSRange whitespaceRange = [startPage rangeOfString:@"\\s*" options:NSCaseInsensitiveSearch | NSRegularExpressionSearch];

    if (whitespaceRange.location == 0 && whitespaceRange.length > 0) {
        startPage= [startPage substringFromIndex:whitespaceRange.length];
    }

    return [startPage length] == 0 ? nil : startPage;
}

- (NSString *)data
{
    NSString *data;
    NSDictionary *components = [self getComponents];
    NSString *dataComponent = CAST_TO_NIL_IF_NSNULL([components objectForKey:DATA_COMPONENT_KEY]);

    NSRange range = [dataComponent rangeOfString:@"\\s*data\\s*=" options:NSCaseInsensitiveSearch | NSRegularExpressionSearch];
    if (range.length > 0 && range.location == 0)
    {
        data = [self extractValueFromExpression:dataComponent];
    }
    else
    {
        data = [dataComponent length] ? dataComponent : nil;
    }

    NSRange whitespaceRange = [data rangeOfString:@"\\s*" options:NSCaseInsensitiveSearch | NSRegularExpressionSearch];

    if (whitespaceRange.location == 0 && whitespaceRange.length > 0) {
        data = [data substringFromIndex:whitespaceRange.length];
    }

    return [data length] == 0 ? nil : data;
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

- (NSDictionary *) getComponents
{
    if (![self length])
    {
        return nil;
    }

    NSString *startPageComponent;
    NSString *dataComponent;
    NSRange range = [self rangeOfString:@"\\s*startpage\\s*=" options:NSCaseInsensitiveSearch | NSRegularExpressionSearch];
    if (range.length > 0 && range.location == 0)
    {
        NSRange range = [self rangeOfString:@";" options:NSCaseInsensitiveSearch];
        if (range.length)
        {
            startPageComponent = [self substringToIndex:range.location];
            dataComponent = [self substringFromIndex:(range.location + 1)];
        }
        else
        {
            startPageComponent = self;
        }
    }
    else
    {
        dataComponent = self;
    }

    NSDictionary *dict = @{START_PAGE_COMPONENT_KEY:CAST_TO_NSNULL_IF_NIL(startPageComponent),
                           DATA_COMPONENT_KEY:CAST_TO_NSNULL_IF_NIL(dataComponent)};
    return dict;
}

@end

