//
//  USCSpeechUnderstander.h
//  nlu&asr
//
//  Created by yunzhisheng on 14-12-1.
//  Copyright (c) 2014年 usc. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 属性
 */
typedef enum
{
    USC_ASR_SERVICE_ADDRESS = 100,
    USC_NLU_URL = 1000
}USCSpeechUnderstanderProperty;
/*!
 识别采样率
 */
typedef enum
{
    RATE_8K = 8000,
    RATE_16K =16000,
    BANDWIDTH_AUTO,
}USCBankWidth;
/*!
 识别语言
 */
typedef enum {
    USCSpeechRecognizeLanguage_CN,// 中文
    USCSpeechRecognizeLanguage_EN,// 英文
    USCSpeechRecognizeLanguage_CO // 粤语
}USCSpeechRecognizeLanguage;
/*!
 日志等级
 */
typedef enum
{
    LOG_E = 1,// 日志打印等级
    LOG_W, // 警告
    LOG_I,// 信息
    LOG_D,// debug
    LOG_V // 全部
}LOGLEVEL;

@class USCScene,USCSpeechResult,USCSceneManage;

#pragma mark -
#pragma mark 代理
@protocol USCSpeechUnderstanderDelegate <NSObject>

/**
 *  检测到用户说话
 */
- (void)onSpeechStart;

/**
 *  录音开始回调
 */
- (void)onRecordingStart;

/**
 *  录音停止回调
 */
- (void)onRecordingStop:(NSData *)data;

/**
 *  识别开始回调
 */
- (void)onRecognizerStart;

/**
 *  vad 超时回调
 */
- (void)onVADTimeout;

/**
 *  识别结果回调
 *
 *  @param result 结果
 *  @param isLast 是否是最后一次
 */
- (void)onRecognizerResult:(NSString *)result isLast:(BOOL)isLast;

/**
 *  音量大小回调
 *
 *  @param volume 音量大小
 */
- (void)onUpdateVolume:(int)volume;

/**
 *  语义返回结果回调
 *
 *  @param result 结果
 */
- (void)onUnderstanderResult:(USCSpeechResult *)result;

/**
 *  整个过程结束回调
 *
 *  @param error error = nil 正常结束
 */
- (void)onEnd:(NSError *)error;

@end

#pragma mark -
#pragma mark 类
// @class - 语音理解类
// @brief - 语音识别和语义理解
@interface USCSpeechUnderstander : NSObject

@property (nonatomic,weak) id<USCSpeechUnderstanderDelegate> delegate;

/**
 *  初始化
 *
 *  @param context context
 *  @param appKey  appKey description
 *  @param secret  secret description
 */
- (id)initWithContext:(NSString *)context appKey:(NSString *)appKey secret:(NSString *)secret;

/**
 *  设置语义理解场景
 *
 *  @param scene 场景
 */
- (void)setNluScenario:(NSString *)scenario;

/**
 *  语义理解
 *
 *  @param text 要理解的内容
 */
- (void)textUnderstander:(NSString *)text;

/**
 *  设置vad超时时间，单位ms
 *
 *  @param frontTime ：开始说话之前的停顿超时时间，默认3000ms
 *  @param backTime  ：开始说话之后的停顿超时时间，默认1000ms
 */
- (void)setVadFrontTimeout:(int)frontTime BackTimeout:(int)backTime;

/**
 *
 *  上传个性化数据
 *
 *  @param userData 用户数据
 */
- (void)setUserData:(NSDictionary *)userData;

/**
 *
 *  获取session id
 *
 *  @return 当前识别会话ID
 */
- (NSString *)getSessionId;

/**
 *
 *  设置识别领域
 *
 *  @param engine 领域
 *
 *  @return 成功返回YES，失败返回NO
 */
- (BOOL)setEngine:(NSString *)engine;

/**
 *  设置语言（DEPRECATED）
 *
 *  @param language 语言：目前支持的语言 @"chinese"(中文)，@"english"(英文)，@"cantoness"(粤语).
 *
 *  不再推荐使用方法，推荐使用下面一个方法设置识别语言
 */
- (void)setLanguage:(NSString *)language;

/**
 *  设置识别语言
 *
 *  @param recognizeLanguage 识别语言，参数值为枚举，USCSpeechRecognizeLanguage定义在第30行。
 */
- (void)setRecognizeLanguage:(USCSpeechRecognizeLanguage)recognizeLanguage;

/**
 *
 *  @brief  设置远近讲
 *
 *  @param voiceField 远近讲,@"far" (远讲),@"near"(近讲)
 *
 *  @return  成功返回YES,失败返回NO
 */
- (BOOL)setVoiceField:(NSString *)voiceField;

/**
 *  @brief 直接识别音频文件，注意调用这个方法后，会直接开始识别，不需要调用start方法。音频文件的格式只支持PCM和WAV。
 *
 *  @param audioFilePath 音频文件的路径
 */
- (void)recognizeAudioFile:(NSString *)audioFilePath;

/**
 *  设置别超时时间
 *
 *  @param recognizationTime 超时时间
 */
- (void)setRecognizationTimeout:(float)recognizationTime;

/**
 *  开始
 */
- (void)start;

/**
 *  停止录音；并开始等待识别结束
 */
- (void)stop;

/**
 * 取消识别
 */
- (void)cancel;

/**
 * 设置在线识别带宽
 *
 *  @param rate 录音采样率，支持参数BANDWIDTH_AUTO、RATE_8K、RATE_16K，默认为RATE_16K.
 */
- (void)setBandwidth:(int)rate;

/*
 设置标点符号
 */
- (void)setPunctuation:(BOOL)isEnable;

/*
 设置是否允许播放提示音
 */
-(void)setPlayingBeep:(BOOL)isAllowed;

/*!
 *  设置是否返回语义理解结果，默认每次识别结束后都会返回对应的语义理解结果。
 *
 *  @param enable YES:每次返回, NO:不返回
 */
- (void)setNluEnable:(BOOL)enable;

/**
 *
 *  设置属性
 *
 *  @param property 属性value
 *  @param key      属性key
 */
- (void)setProperty:(NSString *)property forKey:(int)key;

/**
 *  获取当前sdk版本号
 *
 *  @return 版本号
 */
+ (NSString *)getVersion;

/*!
 *
 *  @brief  是否开启log
 *
 *  @param show YES or NO
 */

+ (void)showLog:(BOOL)show;
/*!
 *
 *  @brief  设置log等级
 *
 *  @param level 等级
 */
+ (void)setLogLevel:(LOGLEVEL)level;
@end
