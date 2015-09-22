//
//  USCSpeechResult.h
//  nlu&asr
//
//  Created by yunzhisheng-zy on 14-12-1.
//  Copyright (c) 2014年 usc. All rights reserved.
//

#import <Foundation/Foundation.h>

// @class - 理解结果类
// @brief - 包括了要理解的结果，场景，结果，
@interface USCSpeechResult : NSObject
/**
 *  请求返回的json结果
 */
@property (nonatomic,strong) NSString  *stringResult;
/**
 *  json中的text
 */
@property (nonatomic,strong) NSString *responseText;
/**
 *  请求文本
 */
@property (nonatomic,strong) NSString *requestText;
/**
 *  场景名字
 */
@property (nonatomic,strong) NSString *scenario;

@end
