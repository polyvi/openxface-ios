
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
//  XAPElement.m
//  xFace
//
//

#import "XAPElement.h"

@implementation APElement (XAPElement)

- (APElement *)firstChildElementNamed:(NSString *)aName withAttribute:(APAttribute *)anAttribute
{
    NSMutableArray *children = [self childElements:aName];

    APElement *elem = nil;
    for (APElement *child in children)
    {
        if([[child valueForAttributeNamed:[anAttribute name]] isEqualToString:[anAttribute value]])
        {
            elem = child;
            break;
        }
    }
    return elem;
}

- (void)removeChild:(APElement*)anElement
{
    [childElements removeObject:anElement];
}

- (id)elementNamed:(NSString *) aName attribute:(NSString *)attr withValue:(NSString *)aValue
{
    NSMutableArray *urlElements = [self childElements:aName];

    for (APElement *urlElem in urlElements)
    {
        NSString *url = [urlElem valueForAttributeNamed:attr];
        if([url isEqualToString:aValue])
        {
            return urlElem;
        }
    }
    return nil;
}

@end
