//
//  VoiceRecogiNewVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/4/9.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "VoiceRecogiNewVC.h"
#import <Speech/Speech.h>

@interface VoiceRecogiNewVC ()<SFSpeechRecognizerDelegate>{
    
    AVAudioInputNode *_node;
}

@property(nonatomic,strong)SFSpeechRecognitionTask *task;
@property (nonatomic,strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic,strong) AVAudioEngine *audioEngine;
@property (nonatomic,strong) SFSpeechRecognizer *speechRecognizer;


@end

@implementation VoiceRecogiNewVC

- (AVAudioEngine *)audioEngine{
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc] init];
    }
    return _audioEngine;
}
- (SFSpeechRecognizer *)speechRecognizer{
    if (!_speechRecognizer) {
        //为语音识别对象设置语言，这里设置的是中文
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
//        NSString *currentLanguage = [languages objectAtIndex:0];
        
        NSLocale *local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _speechRecognizer =[[SFSpeechRecognizer alloc] initWithLocale:local];
        _speechRecognizer.delegate = self;
    }
    return _speechRecognizer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat version=[[[UIDevice currentDevice] systemVersion] floatValue];
    if (version>=10) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                switch (status) {
                    case SFSpeechRecognizerAuthorizationStatusNotDetermined:{
                        NSLog(@"未授权");
                    }
                        break;
                    case SFSpeechRecognizerAuthorizationStatusDenied:{
                        NSLog(@"拒绝授权");
                    }
                        break;
                    case SFSpeechRecognizerAuthorizationStatusRestricted:{
                        NSLog(@"功能受限");
                    }
                        break;
                    case SFSpeechRecognizerAuthorizationStatusAuthorized:{
                        NSLog(@"已授权，可以使用");
   //                     [self recognizeLocal];
                        [self startRecognize];
                    }
                        break;
                    default:
                        break;
                }
            });
        }];
    }else{
        NSLog(@"系统不支持");
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self endRecognize];
}
-(void)startRecognize{
    
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
            NSLog(@"result=%@",result);
            [strongSelf newWordGet:result.bestTranscription.formattedString];
            isFinal=result.isFinal;
        }
        if (error||isFinal) {
            
            [strongSelf endRecognize];
//            [strongSelf.audioEngine stop];
//            [_node removeTapOnBus:0];
//            strongSelf.task=nil;
//            [_recognitionRequest endAudio];
//            _recognitionRequest=nil;
//            [strongSelf newWordGet:@"结束识别"];
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
    [self newWordGet:@"开始识别"];
}
-(void)endRecognize{
    
    if (_task) {
        [self.audioEngine stop];
        [_node removeTapOnBus:0];
        [_recognitionRequest endAudio];
        _recognitionRequest=nil;
        
        [_task cancel];
        _task = nil;
        
        [self newWordGet:@"结束识别"];
    }
}

-(void)newWordGet:(NSString*)word{
    
    self.result.text=[self.result.text stringByAppendingString:[NSString stringWithFormat:@"\n%@",word]];
}
-(void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available{
    
    if (available) {
        [self newWordGet:@"语音识别可用"];
    }else{
        [self newWordGet:@"语音识别不可用"];
    }
}

-(void)recognizeLocal{
    
    NSURL *url =[[NSBundle mainBundle] URLForResource:@"voicetest.m4a" withExtension:nil];
    if (!url) return;
    SFSpeechURLRecognitionRequest *res =[[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
//    __weak typeof(self) weakSelf = self;
    [self.speechRecognizer recognitionTaskWithRequest:res resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"语音识别解析失败,%@",error);
        }else{
            [self newWordGet:result.bestTranscription.formattedString];
        }
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
