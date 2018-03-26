//
//  VoiceView.h
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/21.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallManager.h"

@interface VoiceView : UIView{
    NSTimer *_time;
    NSInteger _timeLeft;
}
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIImageView *head;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *status;

@property(nonatomic,strong)EMCallSession *callInfo;

-(id)initWithCallInfo:(EMCallSession*)callInfo;

- (IBAction)click:(id)sender;

-(void)beganCount;
-(void)dismiss;
@end
