
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
//  XQueuedMutableArray.h
//  xFace
//
//


/**
    扩展NSMutableArray的能力，增加队列功能
 */
@interface NSMutableArray (QueueAdditions)

/**
    返回并移除队首元素
    @returns 队首元素
 */
- (id)dequeue;


/**
    返回队首元素，但不移除它
    @returns 队首元素
 */
- (id)head
;

/**
    加入元素到队尾
    @param obj 待添加的对象
 */
- (void)enqueue:(id)obj;

@end

@interface NSMutableArray (Comparisons)

/**
    返回指定索引的元素.
    该接口指定了一个默认值，若在指定索引没有元素或为nil，返回该默认元素，否则返回索引处的元素.
    @param index 索引值
    @param aDefault 调用者指定的默认值
    @returns 返回元素
 */
- (id) objectAtIndex:(NSUInteger)index withDefault:(id)aDefault;

@end
