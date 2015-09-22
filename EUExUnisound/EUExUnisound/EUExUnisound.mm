//
//  EUExUnisound.mm
//  EUExUnisound
//
//  Created by Cerino on 15/9/17.
//  Copyright (c) 2015年 AppCan. All rights reserved.
//

#import "EUExUnisound.h"
#import "JSON.h"
#import "EUtility.h"

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


-(instancetype)initWithBrwView:(EBrowserView *)eInBrwView{
    self=[super initWithBrwView:eInBrwView];
    if(self){
        self.isLaunched=NO;
        self.isInitialized=NO;
        
    }
    return self;
}


-(void)clean{
    if (self.speechUnderstander) {
        self.speechUnderstander =nil;
    }
    
    if(self.synthesizer){
        self.synthesizer =nil;
    }

}

-(void)dealloc{
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
-(void)init:(NSMutableArray *)inArguments{
    if([inArguments count] < 1){
        return;
    }
    id info = [inArguments[0] JSONValue];
    if(!info || ![info isKindOfClass:[NSDictionary class]]||![info objectForKey:cUexUnisoundKey_appKey]||![info objectForKey:cUexUnisoundKey_secret]){
        return;
    }
    USCSpeechUnderstander *speechUnderstander = [[USCSpeechUnderstander alloc]initWithContext:nil appKey:info[cUexUnisoundKey_appKey] secret:info[cUexUnisoundKey_secret]];
    self.speechUnderstander = speechUnderstander;
    self.speechUnderstander.delegate = self;
    
    USCSpeechSynthesizer *synthesizer = [[USCSpeechSynthesizer alloc]initWithAppkey:info[cUexUnisoundKey_appKey]];
    self.synthesizer =synthesizer;
    self.synthesizer.delegate = self;
    self.isInitialized=YES;
    if(!self.isLaunched){
        //如果没调用过start 他喵的speaking竟然没声音= =!
        [self.speechUnderstander start];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(200 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self.speechUnderstander cancel];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(400 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            self.isLaunched=YES;
        });
    }

}



-(void)updateRecognizerSettings:(NSMutableArray *)inArguments{
    if([inArguments count] < 1||!self.isInitialized){
        return;
    }
    id info = [inArguments[0] JSONValue];
    if(!info || ![info isKindOfClass:[NSDictionary class]]){
        return;
    }
    
    if([info objectForKey:cUexUnisoundKey_frontTime]||[info objectForKey:cUexUnisoundKey_backTime]){
        int frontTime,backTime;
        frontTime=info[cUexUnisoundKey_frontTime]?[info[cUexUnisoundKey_frontTime] intValue]:3000;
        backTime=info[cUexUnisoundKey_backTime]?[info[cUexUnisoundKey_backTime] intValue]:1000;
        [self.speechUnderstander setVadFrontTimeout:frontTime BackTimeout:backTime];
    }

    if([info objectForKey:cUexUnisoundKey_rate]){
        USCBankWidth bandWidth = RATE_16K;
        switch ([info[cUexUnisoundKey_rate] integerValue]) {
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
    
    if([info objectForKey:cUexUnisoundKey_language]){
        
        NSString * language = @"chinese";
        switch ([info[cUexUnisoundKey_language] integerValue]) {
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
    
    if([info objectForKey:cUexUnisoundKey_engine]){
        NSString * engine = @"general";
        switch ([info[cUexUnisoundKey_engine] integerValue]) {
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
                engine =@"medical";
                break;
                
            default:
                break;
        };
        [self.speechUnderstander setEngine:engine];

    }
    
    if([info objectForKey:cUexUnisoundKey_recognizationTimeout]){
        float recognizationTimeout =[[info objectForKey:cUexUnisoundKey_recognizationTimeout] floatValue];
        
        [self.speechUnderstander setRecognizationTimeout:recognizationTimeout>0?recognizationTimeout:30];
    }
    if([info objectForKey:cUexUnisoundKey_needUnderstander]){
        
        [self.speechUnderstander setNluEnable:[info[cUexUnisoundKey_needUnderstander] boolValue]];
    }
    
}





/**
 *  开始语音识别
 *
 *  @param inArguments 无
 */

-(void)start:(NSMutableArray *)inArguments{
    if(self.isInitialized){
        self.isLaunched=YES;
    }
    
    [self.speechUnderstander start];
}

/**
 *  停止语音识别
 *
 *  @param inArguments 无
 */
-(void)stop:(NSMutableArray *)array{
    
    [self.speechUnderstander stop];
    
}

/**
 *  取消语音识别
 *  
 *  @discussion 试做放弃本次语音识别任务，不再产生回调
 *  @param inArguments 无
 */
-(void)cancel:(NSMutableArray *)array{
    
    [self.speechUnderstander cancel];
    
}

/**
 *  进行文件语音识别
 *
 *
 *  @param 
 *  var inArguments = {
 *      filePath:,//语音文件路径
 *  }
 *
 */

//
/*
-(void)recognizeFile:(NSMutableArray *)inArguments{
    if([inArguments count] < 1){
        return;
    }
    id info = [inArguments[0] JSONValue];
    if(!info || ![info isKindOfClass:[NSDictionary class]]||![info objectForKey:cUexUnisoundKey_filePath]){
        return;
    }
    //坑爹啊 这个方法实际上不存在！！
    [self.speechUnderstander recognizeAudioFile:[self absPath:info[cUexUnisoundKey_filePath]]];
}
*/
/**
 *  进行文本语义理解
 *
 *  @param 
 *  var inArguments = {
 *      text:,//需要语义理解的文本
 *  }
 */
-(void)runTextUnderstand:(NSMutableArray *)inArguments{
    if([inArguments count] < 1){
        return;
    }
    id info = [inArguments[0] JSONValue];
    if(!info || ![info isKindOfClass:[NSDictionary class]]||![info objectForKey:cUexUnisoundKey_text]){
        return;
    }
    [self.speechUnderstander textUnderstander:info[cUexUnisoundKey_text]];
}

/**
 *  进行语音合成
 *
 *  @param 
 *  var inArguments = {
 *      text:,//需要语音合成的文本
 *  }
 */
-(void)speaking:(NSMutableArray *)inArguments{
    if([inArguments count] < 1){
        return;
    }
    id info = [inArguments[0] JSONValue];
    if(!info || ![info isKindOfClass:[NSDictionary class]]||![info objectForKey:cUexUnisoundKey_text]){
        return;
    }
    
        

    [self.synthesizer speaking:info[cUexUnisoundKey_text]];

}


/**
 *  取消语音合成
 *
 *  @param 无
 */
-(void)cancelSpeaking:(NSMutableArray *)inArguments{
    [self.synthesizer cancelSpeaking];
}

/**
 *  暂停播放
 *
 *  @discussion 仅暂停语音播放线程，合成线程会继续进行
 *  @param 无
 */
-(void)pauseSpeaking:(NSMutableArray *)inArguments{
    [self.synthesizer pauseSpeaking];
}
/**
 *  恢复播放
 *
 *  @param 无
 */
-(void)resumeSpeaking:(NSMutableArray *)inArguments{
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
    [self callBackJsonWithName:@"onSpeechStart" object:nil];
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
    [self callBackJsonWithName:@"onRecognizerStart" object:nil];
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
    [self callBackJsonWithName:@"onVADTimeout" object:nil];
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
    [self callBackJsonWithName:@"onReceiveRecognizerResult" object:dict];
}

/**
 *  音量大小回调
 *
 *  @param volume 音量大小
 */
- (void)onUpdateVolume:(int)volume{
    if(!self.isLaunched){
        return;
    }
     NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:@(volume) forKey:@"volume"];
    [self callBackJsonWithName:@"onUpdateVolume" object:dict];
}

/**
 *  语义返回结果回调
 *
 *  @param result 结果
 */
- (void)onUnderstanderResult:(USCSpeechResult *)result{
    if(!self.isLaunched){
        return;
    }
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:result.requestText forKey:@"requestText"];
    [dict setValue:result.responseText forKey:@"responsText"];
    [dict setValue:result.stringResult forKey:@"stringResult"];
    [self callBackJsonWithName:@"onUpdateVolume" object:dict];
}
/**
 *  整个过程结束回调
 *
 *  @param error error = nil 正常结束
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
    [self callBackJsonWithName:@"onEnd" object:dict];
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
    [self callBackJsonWithName:@"onSpeakingStart" object:nil];
}

/**
 *  合成取消回调,包括取消合成和取消播放
 */
- (void)synthesizerDidCanceled{
    [self callBackJsonWithName:@"onSpeakingCancel" object:nil];
}

/**
 *  朗读暂停回调
 */
- (void)synthesizerSpeechDidPaused{
    [self callBackJsonWithName:@"cbPauseSpeaking" object:nil];
}

/**
 *  朗读恢复回调
 */
- (void)synthesizerSpeechDidResumed{
    [self callBackJsonWithName:@"cbResumeSpeaking" object:nil];
}

/**
 *  朗读结束回调
 */
- (void)synthesizerSpeechDidFinished{
    //NSLog(@"播放完成");
    [self callBackJsonWithName:@"onSpeakingFinish" object:nil];
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
    [self callBackJsonWithName:@"onSpeakingErrorOccurr" object:dict];
}

/*
 *  返回合成的音频数据，数据是PCM格式
 *
 *  @return 音频数据
 */
- (void)synthesizedData:(NSData *)data{
    
}

#pragma mark - JSON Callback

-(void)callBackJsonWithName:(NSString *)name object:(id)obj{
    static NSString * pluginName = @"uexUnisound";
    NSString *result=[obj JSONFragment];
    NSString *jsStr = [NSString stringWithFormat:@"if(%@.%@ != null){%@.%@('%@');}",pluginName,name,pluginName,name,result];
    
    [EUtility brwView:meBrwView evaluateScript:jsStr];
    
}
@end
