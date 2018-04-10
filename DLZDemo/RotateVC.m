//
//  RotateVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/4/8.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "RotateVC.h"

@interface RotateVC ()

@end

@implementation RotateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CABasicAnimation *animal=[CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    animal.toValue=[NSNumber numberWithFloat:M_PI];
    animal.duration=3;
    animal.cumulative=YES;
    animal.repeatCount=CGFLOAT_MAX;
//    [_showView.layer addAnimation:animal forKey:@"animaltest"];
    
    CGSize imagesize=_showView.image.size;
    CGFloat height=MAIN_SCREAM_HEIGHT-64;
    CGFloat width=imagesize.width/(imagesize.height/height);

    _showView.frame=CGRectMake(0, 0, width, height);

    CABasicAnimation *animal2=[CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animal2.duration=10;
    animal2.autoreverses=YES;
    animal2.repeatCount=CGFLOAT_MAX;
    animal2.removedOnCompletion=NO;
    
    animal2.fromValue=[NSNumber numberWithFloat:0];
    animal2.toValue=[NSNumber numberWithFloat:MAIN_SCREAM_WIDTH-width];
    [_showView.layer addAnimation:animal2 forKey:@"shake"];
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
