//
//  CallManager.m
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/24.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "CallManager.h"

#import "VoiceView.h"
#import "VideoView.h"

#define MUSIC_BUSY  @"busy.wav"
#define MUSIC_RING  @"ring.wav"
#define MUSIC_RINGBACK  @"ringback.wav"

@interface CallManager()<EMCallManagerDelegate>{

    VoiceView *_voice;
    VideoView *_video;
    
    NSInteger _timeLeft;
    NSTimer *_time;
}

@end

@implementation CallManager

-(id)init{

    self=[super init];
    if (self) {
        _timeLeft=0;
    }
    return self;
}
+(instancetype)sharedManager{
    
    static CallManager *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared=[[CallManager alloc]init];
    });
    return _shared;
}

-(void)began{
    EMOptions *options = [EMOptions optionsWithAppkey:@"1359206950#denotest"];
    options.apnsCertName = @"push_dev";
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
-(void)makeCallWithUser:(NSString *)user calltype:(callType)calltype{

    switch (calltype) {
        case callTypePhone:{
            [[EMClient sharedClient].callManager startCall:EMCallTypeVoice remoteName:user ext:nil completion:^(EMCallSession *aCallSession, EMError *aError) {
                if (!aError||aError.code==801) {
                    _voice=[[VoiceView alloc]initWithCallInfo:aCallSession];
                    for (NSInteger i=0; i<5; i++) {
                        if (i!=1) {
                            UIView *view=[_voice viewWithTag:100+i];
                            view.hidden=YES;
                        }
                    }
                    _voice.status.text=@"正在等待对方接听...";
                    [self playVoice:MUSIC_RINGBACK];
                    [[UIApplication sharedApplication].keyWindow addSubview:_voice];
                }else{
                    NSLog(@"%@",aError.errorDescription);
                }
            }];
        }
            break;
        case callTypeVideo:{
            [[EMClient sharedClient].callManager startCall:EMCallTypeVideo remoteName:user ext:nil completion:^(EMCallSession *aCallSession, EMError *aError) {
                if (!aError||aError.code==801) {
                    _video=[[VideoView alloc]initWithCallInfo:aCallSession];
                    for (NSInteger i=0; i<2; i++) {
                        UIView *view=[_video viewWithTag:100+i];
                        view.hidden=YES;
                    }
                    _video.status.text=@"正在等待对方接听...";
                    [self playVoice:MUSIC_RINGBACK];
                    
                    [[UIApplication sharedApplication].keyWindow addSubview:_video];
                }else{
                    NSLog(@"%@",aError.errorDescription);
                }
            }];
        }
            break;
        default:
            break;
    }
}



#pragma mark-calldelegate  A~~B

- (void)callDidConnect:(EMCallSession *)aSession{
    
    if (aSession.type==EMCallTypeVoice) {
        _voice.callInfo=aSession;
    }else{
        _video.callInfo=aSession;
    }
}
- (void)callDidAccept:(EMCallSession *)aSession{
    
    if (aSession.type==EMCallTypeVoice) {
        _voice.callInfo=aSession;
    }else{
        _video.callInfo=aSession;
    }
    
    if (aSession.type==EMCallTypeVoice) {
        _voice.callInfo=aSession;
        [_voice viewWithTag:100].hidden=NO;
        [(UILabel*)[[_voice viewWithTag:101] viewWithTag:333] setText:@"挂断"];
        [_voice viewWithTag:102].hidden=NO;
        [_voice viewWithTag:103].hidden=YES;
        [_voice viewWithTag:104].hidden=YES;
      
        if (_audioPlayer) {
            [_audioPlayer stop];
            _audioPlayer=nil;
        }
        [_voice beganCount];
    }else{
        _video.callInfo=aSession;
        [_video viewWithTag:102].hidden=YES;
        [_video viewWithTag:100].hidden=NO;
        [(UILabel*)[[_video viewWithTag:100] viewWithTag:333] setText:@"挂断"];
        [_video viewWithTag:101].hidden=NO;
        [(UILabel*)[[_video viewWithTag:101] viewWithTag:333] setText:@"切换摄像头"];
        [(UIImageView*)[[_video viewWithTag:101] viewWithTag:222] setImage:[UIImage imageNamed:@"silence_yes"]];

        if (_audioPlayer) {
            [_audioPlayer stop];
            _audioPlayer=nil;
        }
        [_voice beganCount];
        
        _video.head.hidden=YES;
        _video.name.hidden=YES;
        _video.status.hidden=YES;
        
        aSession.remoteVideoView=[[EMCallRemoteView alloc]initWithFrame:_video.backView.bounds];
        aSession.remoteVideoView.hidden = YES;
        aSession.remoteVideoView.backgroundColor = [UIColor clearColor];
        aSession.remoteVideoView.scaleMode = EMCallViewScaleModeAspectFill;
        
        aSession.localVideoView=[[EMCallLocalView alloc] initWithFrame:_video.showView_my.bounds];
        
        [_video.backView addSubview:aSession.remoteVideoView];
        [_video.backView sendSubviewToBack:aSession.remoteVideoView];
        [_video.showView_my addSubview:aSession.localVideoView];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            aSession.remoteVideoView.hidden = NO;
        });
    }
}

- (void)callDidReceive:(EMCallSession *)aSession{
    
    if (aSession.type==EMCallTypeVoice) {
        _voice=[[VoiceView alloc]initWithCallInfo:aSession];
        for (NSInteger i=0; i<3; i++) {
            UIView *view=[_voice viewWithTag:100+i];
            view.hidden=YES;
        }
        _voice.status.text=@"邀请您接听";
        [self playVoice:MUSIC_RING];
        [[UIApplication sharedApplication].keyWindow addSubview:_voice];
    }else{
        _video=[[VideoView alloc]initWithCallInfo:aSession];
        [_video viewWithTag:102].hidden=YES;
        _video.status.text=@"邀请您接听";
        [self playVoice:MUSIC_RING];
        [[UIApplication sharedApplication].keyWindow addSubview:_video];
    }
}

- (void)callDidEnd:(EMCallSession *)aSession reason:(EMCallEndReason)aReason error:(EMError *)aError{
    
    if (aSession.type==EMCallTypeVoice) {
        if (aReason==EMCallEndReasonBusy||aReason==EMCallEndReasonNoResponse||aReason==EMCallEndReasonDecline||aError.code==EMErrorCallRemoteOffline) {//对方通话中，没有响应，拒接
            [self playVoice:MUSIC_BUSY];
        }else if(aReason==EMCallEndReasonHangup){
            _voice.status.text=@"通话结束";
            [self performSelector:@selector(voiceCancel) withObject:nil afterDelay:2];
        }else{
            _voice.status.text=@"通话失败";
            if (_audioPlayer) {
                [_audioPlayer stop];
                _audioPlayer=nil;
            }
            [self performSelector:@selector(voiceCancel) withObject:nil afterDelay:2];
        }
    }else{
        if (aReason==EMCallEndReasonBusy||aReason==EMCallEndReasonNoResponse||aReason==EMCallEndReasonDecline||aError.code==EMErrorCallRemoteOffline) {//对方通话中，没有响应，拒接
            [self playVoice:MUSIC_BUSY];
        }else if(aReason==EMCallEndReasonHangup){
            _video.status.text=@"通话结束";
            [self performSelector:@selector(videoCancel) withObject:nil afterDelay:2];
        }else{
            _video.status.text=@"通话失败";
            if (_audioPlayer) {
                [_audioPlayer stop];
                _audioPlayer=nil;
            }
            [self performSelector:@selector(videoCancel) withObject:nil afterDelay:2];
        }
    }
}
-(void)voiceCancel{
    [_voice dismiss];
}
-(void)videoCancel{

    [_video dismiss];
}
- (void)callStateDidChange:(EMCallSession *)aSession type:(EMCallStreamingStatus)aType{
    
    if (aSession.type==EMCallTypeVoice) {
        _voice.callInfo=aSession;
    }else{
        _video.callInfo=aSession;
    }
}
-(void)playVoice:(NSString*)music{
    
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer=nil;
    }
    NSURL *url=[[NSBundle mainBundle]URLForResource:music withExtension:Nil];
    _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
    _audioPlayer.numberOfLoops=NSIntegerMax;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}

-(void)bindDeviceToken:(NSData *)deviceToken{

    [[EMClient sharedClient] bindDeviceToken:deviceToken];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{

    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application{

    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

@end
