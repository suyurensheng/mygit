//
//  VideoView.h
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/21.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallManager.h"

@interface VideoView : UIView{
    NSTimer *_time;
    NSInteger _timeLeft;
    
    BOOL _isFront;
}


@property (weak, nonatomic) IBOutlet UIImageView *backHead;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *showView_my;
@property (weak, nonatomic) IBOutlet UIImageView *head;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *status;

@property(nonatomic,strong)EMCallSession *callInfo;

-(id)initWithCallInfo:(EMCallSession*)callInfo;

- (IBAction)click:(id)sender;

-(void)beganCount;
-(void)dismiss;
@end
