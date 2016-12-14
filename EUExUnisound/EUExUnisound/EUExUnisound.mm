//
//  EUExUnisound.mm
//  EUExUnisound
//
//  Created by Cerino on 15/9/17.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "EUExUnisound.h"


#import "uexUnisoundKeys.h"
#import "USCSpeechUnderstander.h"
#import "USCSpeechResult.h"
#import "USCSpeechSynthesizer.h"





@interface EUExUnisound()<USCSpeechUnderstanderDelegate,USCSpeechSynthesizerDelegate>

@property (nonatomic,strong) USCSpeechUnderstander *speechUnderstander;
@property (nonatomic,strong) USCSpeechSynthesizer *synthesizer;

@property (nonatomic,assign) BOOL isLaunched;
@property (nonatomic,assign) BOOL isInitialized;
@end


@implementation EUExUnisound

#pragma mark - Required Methods


- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    self = [super initWithWebViewEngine:engine];
    if (self) {
        _isLaunched = NO;
        _isInitialized = NO;
    }
    return self;
}




- (void)clean{
    _speechUnderstander = nil;
    _synthesizer = nil;
}

- (void)dealloc{
    [self clean];
}



#pragma mark - Main APIs


/**
 *  初始化插件
 *
 *
 *  @param 
 *  inArgument = {
 *      appKey:,//申请应用后获得的appKey
 *      secret:,//申请应用后获得的Secret
 *  }
 *
 *
 */
- (void)init:(NSMutableArray *)inArguments{

    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *appKey = stringArg(info[cUexUnisoundKey_appKey]);
    NSString *secret = stringArg(info[cUexUnisoundKey_secret]);
    
    if (!appKey || !secret) {
        return;
    }
    
    
    USCSpeechUnderstander *speechUnderstander = [[USCSpeechUnderstander alloc]initWithContext:nil appKey:appKey secret:secret];
    self.speechUnderstander = speechUnderstander;
    self.speechUnderstander.delegate = self;
    
    USCSpeechSynthesizer *synthesizer = [[USCSpeechSynthesizer alloc]initWithAppkey:info[cUexUnisoundKey_appKey]];
    self.synthesizer = synthesizer;
    self.synthesizer.delegate = self;
    self.isInitialized = YES;
    if(!self.isLaunched){
        //如果没调用过start speaking不会有声音= =!
        [self.speechUnderstander start];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(200 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self.speechUnderstander cancel];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(400 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            self.isLaunched = YES;
        });
    }
    

}



- (void)updateRecognizerSettings:(NSMutableArray *)inArguments{

    ACArgsUnpack(NSDictionary *info) = inArguments;
    
    NSNumber *frontNum = numberArg(info[cUexUnisoundKey_frontTime]);
    NSNumber *backNum = numberArg(info[cUexUnisoundKey_backTime]);
    if (frontNum || backNum) {
        int frontTime = frontNum ? frontNum.intValue : 3000;
        int backTime = backNum ? backNum.intValue : 1000;
        [self.speechUnderstander setVadFrontTimeout:frontTime BackTimeout:backTime];
    }
    
    NSNumber *rateNum = numberArg(info[cUexUnisoundKey_rate]);
    if (rateNum) {
        USCBankWidth bandWidth = RATE_16K;
        switch (rateNum.integerValue) {
            case 1:
                bandWidth = BANDWIDTH_AUTO;
                break;
            case 2:
                bandWidth = RATE_8K;
                break;
                
            default:
                break;
        };
        [self.speechUnderstander setBandwidth:bandWidth];
    }
    
    NSNumber *languageNum = numberArg(info[cUexUnisoundKey_language]);

    if(languageNum){
        
        NSString * language = @"chinese";
        switch (languageNum.integerValue) {
            case 2:
                language = @"english";
                break;
            case 3:
                language = @"cantoness";
                break;
                
            default:
                break;
        };
        [self.speechUnderstander setLanguage:language];

    }
    
    NSNumber *engineNum = numberArg(info[cUexUnisoundKey_engine]);
    
    if(engineNum){
        NSString * engine = @"general";
        switch (engineNum.integerValue) {
            case 2:
                engine = @"poi";
                break;
            case 3:
                engine = @"song";
                break;
            case 4:
                engine = @"movietv";
                break;
            case 5:
                engine = @"medical";
                break;
                
            default:
                break;
        };
        [self.speechUnderstander setEngine:engine];

    }
    NSNumber *recognizeNum = numberArg(info[cUexUnisoundKey_recognizationTimeout]);
    if (recognizeNum) {
        float recognizationTimeout =[recognizeNum floatValue];
        
        [self.speechUnderstander setRecognizationTimeout:recognizationTimeout>0?recognizationTimeout:30];
    }
    
    if(info[cUexUnisoundKey_needUnderstander]){
        [self.speechUnderstander setNluEnable:[info[cUexUnisoundKey_needUnderstander] boolValue]];
    }
    
}





/**
 *  开始语音识别
 *
 *  @param inArguments 无
 */

- (void)start:(NSMutableArray *)inArguments{
    if(self.isInitialized){
        self.isLaunched = YES;
    }
    
    [self.speechUnderstander start];
}

/**
 *  停止语音识别
 *
 *  @param inArguments 无
 */
- (void)stop:(NSMutableArray *)array{
    
    [self.speechUnderstander stop];
    
}

/**
 *  取消语音识别
 *  
 *  @discussion 试做放弃本次语音识别任务，不再产生回调
 *  @param inArguments 无
 */
- (void)cancel:(NSMutableArray *)array{
    
    [self.speechUnderstander cancel];
    
}


/**
 *  进行文本语义理解
 *
 *  @param 
 *  var inArguments = {
 *      text:,//需要语义理解的文本
 *  }
 */
- (void)runTextUnderstand:(NSMutableArray *)inArguments{

    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *text = stringArg(info[cUexUnisoundKey_text]);
    if (text) {
        [self.speechUnderstander textUnderstander:text];
    }

}

/**
 *  进行语音合成
 *
 *  @param 
 *  var inArguments = {
 *      text:,//需要语音合成的文本
 *  }
 */
- (void)speaking:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *text = stringArg(info[cUexUnisoundKey_text]);
    if (text) {
        [self.synthesizer speaking:text];
    }
}


/**
 *  取消语音合成
 *
 *  @param 无
 */
- (void)cancelSpeaking:(NSMutableArray *)inArguments{
    [self.synthesizer cancelSpeaking];
}

/**
 *  暂停播放
 *
 *  @discussion 仅暂停语音播放线程，合成线程会继续进行
 *  @param 无
 */
- (void)pauseSpeaking:(NSMutableArray *)inArguments{
    [self.synthesizer pauseSpeaking];
}
/**
 *  恢复播放
 *
 *  @param 无
 */
- (void)resumeSpeaking:(NSMutableArray *)inArguments{
    [self.synthesizer resumeSpeaking];
}





#pragma mark - USCSpeechUnderstander Delegate

/**
 *  检测到用户说话
 *  @discussion 收到此回调代表已检测到用户开始说话。
 */
- (void)onSpeechStart{
    if(!self.isLaunched){
        return;
    }
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"onSpeechStart") arguments:nil];

}

/**
 *  录音开始回调
 *  @discussion 录音初始化完成,识别启动时,回调此方法。
 *  @discussion 由于录音初始化需要时间,如果录音没有初始化完成就开始说话,可能会导致语音前半部分被截断,从而影响识别效果,因此不能调用 start 后就开始说话,而是要等待录音初始化完成才提示用户开始说话。
 */
- (void)onRecordingStart{
    if(!self.isLaunched){
        return;
    }
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"onRecognizerStart") arguments:nil];
}

/**
 *  录音停止回调
 */
- (void)onRecordingStop:(NSData *)data{
    
}

/**
 *  识别开始回调
 */
- (void)onRecognizerStart{
    
}

/**
 *  vad 超时回调
 *  @discussion 录音过程中,如果用户间隔一段时间没有说话,会回调此方法。 用户可以在此方法中调用 stop 方法停止录音,等待识别结果。
 */
- (void)onVADTimeout{
    if(!self.isLaunched){
        return;
    }
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"onVADTimeout") arguments:nil];
}

/**
 *  识别结果回调
 *
 *  @param result 结果
 *  @param isLast 是否是最后一次
 */
- (void)onRecognizerResult:(NSString *)result isLast:(BOOL)isLast{
    if(!self.isLaunched){
        return;
    }
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:result forKey:cUexUnisoundKey_result];
    [dict setValue:@(isLast) forKey:cUexUnisoundKey_isLast];
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"onReceiveRecognizerResult") arguments:ACArgsPack(dict.ac_JSONFragment)];
}

/**
 *  音量大小回调
 */
- (void)onUpdateVolume:(int)volume{
    if(!self.isLaunched){
        return;
    }
     NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:@(volume) forKey:@"volume"];
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"onUpdateVolume") arguments:ACArgsPack(dict.ac_JSONFragment)];
}

/**
 *  语义返回结果回调
 */
- (void)onUnderstanderResult:(USCSpeechResult *)result{
    if(!self.isLaunched){
        return;
    }
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:result.requestText forKey:@"requestText"];
    [dict setValue:result.responseText forKey:@"responsText"];
    [dict setValue:result.stringResult forKey:@"stringResult"];
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"onReceiveUnderstanderResult") arguments:ACArgsPack(dict.ac_JSONFragment)];
}
/**
 *  整个过程结束回调
 */
- (void)onEnd:(NSError *)error{
    if(!self.isLaunched){
        return;
    }
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    if(!error){
        [dict setValue:@0 forKey:cUexUnisoundKey_result];
    }else{
        [dict setValue:@(error.code) forKey:cUexUnisoundKey_result];
    }
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"onEnd") arguments:ACArgsPack(dict.ac_JSONFragment)];
}

#pragma mark - USCSpeechSynthesizer Delegate


/**
 *  合成器启动
 */
- (void)synthesizerSpeechStart{
    
}

/**
 *  开始朗读回调
 */
- (void)synthesizerSpeechStartSpeaking{
    //NSLog(@"开始播放");
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"onSpeakingStart") arguments:nil];
}

/**
 *  合成取消回调,包括取消合成和取消播放
 */
- (void)synthesizerDidCanceled{
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"onSpeakingCancel") arguments:nil];
}

/**
 *  朗读暂停回调
 */
- (void)synthesizerSpeechDidPaused{
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"cbPauseSpeaking") arguments:nil];
}

/**
 *  朗读恢复回调
 */
- (void)synthesizerSpeechDidResumed{
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"cbResumeSpeaking") arguments:nil];
}

/**
 *  朗读结束回调
 */
- (void)synthesizerSpeechDidFinished{
    //NSLog(@"播放完成");
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"onSpeakingFinish") arguments:nil];
}

/**
 *  TTS中间出错回调
 *
 *  @param error 错误对象
 */
- (void)synthesizerErrorOccurred:(NSError *)error{
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:[error localizedDescription] forKey:@"errorStr"];
    [dict setValue:@(error.code) forKey:@"errorCode"];
    [self.webViewEngine callbackWithFunctionKeyPath:cbFunc(@"onSpeakingErrorOccurr") arguments:ACArgsPack(dict.ac_JSONFragment)];
}

/*
 *  返回合成的音频数据，数据是PCM格式
 *
 *  @return 音频数据
 */
- (void)synthesizedData:(NSData *)data{
    
}

#pragma mark - JSON Callback

static inline NSString * cbFunc(NSString *funcName){
    return [@"uexUnisound." stringByAppendingString:funcName];
}



@end
