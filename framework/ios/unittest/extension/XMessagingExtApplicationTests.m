
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
//  XMessagingExtApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XMessagingExt.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJsCallback.h"
#import "XJsCallback+ExtensionResult.h"
#import "XConstants.h"
#import "XApplication.h"

#define MESSAGE_TYPE_SMS       @"SMS"
#define MESSAGE_TYPE_EMAIL     @"Email"
#define DESTINATION_ADDRESS    @"10086"
#define MESSAGE_BODY           @"messageBody"
#define SUBJECT                @"subject"

@interface XMessagingExtApplicationTests : XApplicationTests
{
    @private
    XMessagingExt* messagingExt;
}

@end

@implementation XMessagingExtApplicationTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    self->messagingExt = [[XMessagingExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];
    STAssertNotNil(self->messagingExt, @"Failed to create messaging extension instance");
}

- (void) testSendMessage
{
    //创建测试环境
    //Message
    NSString *callbackId = @"Accelerometer0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"start"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:4];
    [arguments addObject:MESSAGE_TYPE_SMS];
    [arguments addObject:DESTINATION_ADDRESS];
    [arguments addObject:MESSAGE_BODY];
    [arguments addObject:SUBJECT];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];
    STAssertNoThrow([self->messagingExt sendMessage:arguments withDict:options],nil);
    //分支
    //Mail
    [arguments replaceObjectAtIndex:0 withObject:MESSAGE_TYPE_EMAIL];
    STAssertNoThrow([self->messagingExt sendMessage:arguments withDict:options],nil);
    //分支
    [arguments replaceObjectAtIndex:0 withObject:@""];
    STAssertNoThrow([self->messagingExt sendMessage:arguments withDict:options],nil);
    STAssertEquals([NSNumber numberWithInt:STATUS_ERROR], [[callback getXExtensionResult] status], nil);
    //异常参数
    [arguments replaceObjectAtIndex:1 withObject:@""];
    [arguments replaceObjectAtIndex:2 withObject:@""];
    [arguments replaceObjectAtIndex:3 withObject:@""];
    STAssertNoThrow([self->messagingExt sendMessage:arguments withDict:options],nil);

    //NSNULL 对象
    [arguments replaceObjectAtIndex:1 withObject:[NSNull null]];
    [arguments replaceObjectAtIndex:2 withObject:[NSNull null]];
    [arguments replaceObjectAtIndex:3 withObject:[NSNull null]];
    STAssertNoThrow([self->messagingExt sendMessage:arguments withDict:options],nil);
}

- (void)testMessageComposeViewControllerdidFinishWithResult
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    MessageComposeResult result = MessageComposeResultSent;
    STAssertNoThrow([self->messagingExt messageComposeViewController:controller didFinishWithResult:result],nil);
    //分支
    result = MessageComposeResultFailed;
    STAssertNoThrow([self->messagingExt messageComposeViewController:controller didFinishWithResult:result],nil);
}

-(void)testMailComposeControllerdidFinishWithResult
{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    MFMailComposeResult result = MFMailComposeResultSent;
    NSError *error = nil;
    STAssertNoThrow([self->messagingExt mailComposeController:controller didFinishWithResult:result error:error],nil);
    //分支
    result = MFMailComposeResultFailed;
    STAssertNoThrow([self->messagingExt mailComposeController:controller didFinishWithResult:result error:error],nil);
}

@end
