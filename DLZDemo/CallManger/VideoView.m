//
//  VideoView.m
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/21.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "VideoView.h"
@implementation VideoView

-(id)initWithCallInfo:(EMCallSession *)callInfo{
    self=[[[NSBundle mainBundle] loadNibNamed:@"VideoView" owner:self options:nil] lastObject];
    if (self) {
        CGRect frame=[UIScreen mainScreen].bounds;
        self.frame=frame;
        
        _callInfo=callInfo;
        
        _head.layer.masksToBounds=YES;
        _head.layer.cornerRadius=_head.frame.size.width/2;
        _head.layer.borderColor=[UIColor whiteColor].CGColor;
        _head.layer.borderWidth=2;
        
        _showView_my.layer.masksToBounds=YES;
        _showView_my.layer.cornerRadius=3;
        
        _isFront=YES;
    }
    return self;
}


- (IBAction)click:(id)sender {
    NSString *text=[(UILabel*)[[(UIButton*)sender superview] viewWithTag:333] text];
    if ([text isEqualToString:@"取消"]) {
        [[EMClient sharedClient].callManager endCall:_callInfo.callId reason:EMCallEndReasonHangup];
        [self dismiss];
    }else if ([text isEqualToString:@"挂断"]) {
        [[EMClient sharedClient].callManager endCall:_callInfo.callId reason:EMCallEndReasonHangup];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallCompleted" object:nil];
        [self dismiss];
    }else if ([text isEqualToString:@"拒绝"]){
        [[EMClient sharedClient].callManager endCall:_callInfo.callId reason:EMCallEndReasonDecline];
        [self dismiss];
    }else if ([text isEqualToString:@"接听"]){
        [[EMClient sharedClient].callManager answerIncomingCall:_callInfo.callId];
    }else if ([text isEqualToString:@"切换摄像头"]){
        _isFront=!_isFront;
        [_callInfo switchCameraPosition:_isFront];
    }
}
-(void)beganCount{
    _time=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
}
-(void)timeChange{
    
    _timeLeft++;
    NSInteger s=_timeLeft%60;
    NSInteger m=_timeLeft/60%60;
    NSInteger h=_timeLeft/3600;
    _status.text=[NSString stringWithFormat:@"%ld:%02ld:%02ld",h,m,s];
}

-(void)dismiss{
    if (_time) {
        _timeLeft=0;
        [_time invalidate];
        _time=nil;
    }
    if ([CallManager sharedManager].audioPlayer) {
        [[CallManager sharedManager].audioPlayer stop];
        [CallManager sharedManager].audioPlayer=nil;
    }
    [self removeFromSuperview];
}
@end
