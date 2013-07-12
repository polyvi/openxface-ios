
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
//  XSystemBootstrap.h
//  xFace
//
//

@class XAppManagement;

/*
    该代理用于通知工作环境准备成功或失败
 */
@protocol XSystemBootstrapDelegate <NSObject>

/**
    启动参数
 */
@property (strong, readonly, nonatomic) NSString *bootParams;

/*
    Tells the delegate that the work environment has been prepared.
 */
-(void)didFinishPreparingWorkEnvironment;

/*
     Tells the delegate that fail to prepare work environment.
 */
-(void)didFailToPrepareEnvironmentWithError:(NSError*)error;

@end

/**
   定义系统启动的接口
 */
@protocol XSystemBootstrap <NSObject>

/**
    用于通知工作环境准备成功或失败
 */
@property (nonatomic, weak) id<XSystemBootstrapDelegate> bootDelegate;

/**
    启动之前的准备工作
 */
-(void) prepareWorkEnvironment;

/**
    系统启动的入口
 */
-(void) boot:(XAppManagement*)appManagement;

@end
