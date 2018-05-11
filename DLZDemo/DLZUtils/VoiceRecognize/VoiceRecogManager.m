//
//  VoiceRecogManager.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/4/10.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "VoiceRecogManager.h"
#import <Speech/Speech.h>

@interface VoiceRecogManager()<SFSpeechRecognizerDelegate>{
    
    AVAudioInputNode *_node;
    
    void(^_recognize)(ErrorEntity *, NSString *);
    
    BOOL _isRecognizing;
}

@property(nonatomic,strong)SFSpeechRecognitionTask *task;
@property (nonatomic,strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic,strong) AVAudioEngine *audioEngine;
@property (nonatomic,strong) SFSpeechRecognizer *speechRecognizer;

@end
@implementation VoiceRecogManager

- (AVAudioEngine *)audioEngine{
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc] init];
    }
    return _audioEngine;
}
- (SFSpeechRecognizer *)speechRecognizer{
    if (!_speechRecognizer) {
        //        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //        NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
        //        NSString *currentLanguage = [languages objectAtIndex:0];
        //为语音识别对象设置语言，这里设置的是中文
        NSLocale *local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _speechRecognizer =[[SFSpeechRecognizer alloc] initWithLocale:local];
        _speechRecognizer.delegate = self;
    }
    return _speechRecognizer;
}
+(instancetype)sharedManager{
    
    static VoiceRecogManager *_shared;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        _shared=[[VoiceRecogManager alloc]init];
    });
    return _shared;
}

-(void)startRecognizeResult:(void (^)(ErrorEntity *, NSString *))recognize{
    if (_isRecognizing) {
        _recognize([ErrorEntity errorInfoWithCode:100 message:@"识别已开始"],@"");
        return;
    }
    CGFloat version=[[[UIDevice currentDevice] systemVersion] floatValue];
    if (version>=10) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                switch (status) {
                    case SFSpeechRecognizerAuthorizationStatusNotDetermined:{
                        _recognize([ErrorEntity errorInfoWithCode:100 message:@"未授权"],@"");
                    }
                        break;
                    case SFSpeechRecognizerAuthorizationStatusDenied:{
                        _recognize([ErrorEntity errorInfoWithCode:100 message:@"拒绝授权"],@"");
                    }
                        break;
                    case SFSpeechRecognizerAuthorizationStatusRestricted:{
                        _recognize([ErrorEntity errorInfoWithCode:100 message:@"功能受限"],@"");
                    }
                        break;
                    case SFSpeechRecognizerAuthorizationStatusAuthorized:{
                        NSLog(@"已授权，可以使用");
                        _recognize=recognize;
                        [self startRecognize];
                    }
                        break;
                    default:
                        break;
                }
            });
        }];
    }else{
        _recognize([ErrorEntity errorInfoWithCode:100 message:@"系统不支持"],@"");
    }
}
-(void)startRecognize{
    
    _isRecognizing=YES;
    if (_task) {
        [_task cancel];
        _task=nil;
    }
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    NSParameterAssert(!error);
    [audioSession setMode:AVAudioSessionModeMeasurement error:&error];
    NSParameterAssert(!error);
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    NSParameterAssert(!error);
    
    _recognitionRequest=[[SFSpeechAudioBufferRecognitionRequest alloc]init];
    NSAssert(_recognitionRequest, @"请求初始化失败");
    
    _recognitionRequest.shouldReportPartialResults=YES;
    
    __weak typeof(self) weakSelf = self;
    _task=[self.speechRecognizer recognitionTaskWithRequest:_recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        BOOL isFinal=NO;
        if (result) {
//            NSLog(@"result=%@",result);
            _recognize([ErrorEntity errorInfoWithCode:0 message:@""],result.bestTranscription.formattedString);
            isFinal=result.isFinal;
        }
        if (error||isFinal) {
            [strongSelf endRecognize];
        }
    }];
    
    _node=self.audioEngine.inputNode;
    NSAssert(_node, @"录入设备没有准备好");
    [_node removeTapOnBus:0];
    AVAudioFormat *format=[_node outputFormatForBus:0];
    [_node installTapOnBus:0 bufferSize:1024 format:format block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.recognitionRequest) {
            [strongSelf.recognitionRequest appendAudioPCMBuffer:buffer];
        }
    }];
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
    NSParameterAssert(!error);
    _recognize([ErrorEntity errorInfoWithCode:0 message:@""],@"开始识别");
}
-(void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available{
    
    if (available) {
        NSLog(@"语音识别可用");
    }else{
        NSLog(@"语音识别不可用");
    }
}

-(void)recognizeLocal:(NSURL *)source result:(void (^)(ErrorEntity *, NSString *))recognize{
    
    NSAssert(source, @"资源不存在");
    if (!source)
        recognize([ErrorEntity errorInfoWithCode:100 message:@"资源不存在"],@"");
    
    SFSpeechURLRecognitionRequest *res =[[SFSpeechURLRecognitionRequest alloc] initWithURL:source];
    [self.speechRecognizer recognitionTaskWithRequest:res resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            recognize([ErrorEntity errorInfoWithCode:100 message:@"语音识别解析失败"],@"");
        }else{
            recognize([ErrorEntity errorInfoWithCode:0 message:@""],result.bestTranscription.formattedString);
        }
    }];
}
-(void)endRecognize{
    
    _isRecognizing=NO;
    if (_task) {
        [self.audioEngine stop];
        [_node removeTapOnBus:0];
        [_recognitionRequest endAudio];
        _recognitionRequest=nil;
        
        [_task cancel];
        _task = nil;
        _recognize([ErrorEntity errorInfoWithCode:0 message:@""],@"结束识别");
    }
}
@end
