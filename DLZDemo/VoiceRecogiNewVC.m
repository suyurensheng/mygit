//
//  VoiceRecogiNewVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/4/9.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "VoiceRecogiNewVC.h"
#import "DLZUtils/VoiceRecognize/VoiceRecogManager.h"
@interface VoiceRecogiNewVC ()




@end

@implementation VoiceRecogiNewVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[VoiceRecogManager sharedManager] startRecognizeResult:^(ErrorEntity *error, NSString *result) {
        if (error.code==0) {
            [self newWordGet:result];
        }else{
            [self newWordGet:error.message];
        }
    }];
//    [[VoiceRecogManager sharedManager] recognizeLocal:[[NSBundle mainBundle] URLForResource:@"voicetest.m4a" withExtension:nil] result:^(ErrorEntity *error, NSString *result) {
//        if (error.code==0) {
//            [self newWordGet:result];
//        }else{
//            [self newWordGet:error.message];
//        }
//    }];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}



-(void)newWordGet:(NSString*)word{
    
    self.result.text=[self.result.text stringByAppendingString:[NSString stringWithFormat:@"\n%@",word]];
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
