
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
//  XInstallListenerStub.m
//  xFaceLib
//
//

#import "XInstallListenerStub.h"

@implementation XInstallListenerStub

@synthesize applicationId;
@synthesize operationType;
@synthesize status;
@synthesize amsError;
@synthesize isOnSuccessInvoked;
@synthesize isOnErrorInvoked;
@synthesize isOnProgressUpdatedInvoked;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self reset];
    }
    return self;
}

- (void)reset
{
    [self setApplicationId:nil];
    [self setOperationType:INSTALL];
    [self setStatus:INITIALIZED];
    [self setAmsError:UNKNOWN];
    [self setIsOnErrorInvoked:NO];
    [self setIsOnProgressUpdatedInvoked:NO];
    [self setIsOnSuccessInvoked:NO];
}

#pragma mark XInstallListener

- (void) onProgressUpdated:(OPERATION_TYPE)type withStatus:(PROGRESS_STATUS)progressStatus
{
    [self setIsOnProgressUpdatedInvoked:YES];
    [self setOperationType:type];
    [self setStatus:progressStatus];
}

- (void) onSuccess:(OPERATION_TYPE)type withAppId:(NSString *)appId
{
    [self setIsOnSuccessInvoked:YES];
    [self setOperationType:type];
    [self setApplicationId:appId];
}

- (void) onError:(OPERATION_TYPE)type withAppId:(NSString *)appId withError:(AMS_ERROR)error
{
    [self setIsOnErrorInvoked:YES];
    [self setOperationType:type];
    [self setApplicationId:appId];
    [self setAmsError:error];
}

@end
