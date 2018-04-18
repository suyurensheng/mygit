//
//  GrainVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/4/18.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "GrainVC.h"

@interface GrainVC ()

@end

@implementation GrainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CAEmitterLayer *layer=[CAEmitterLayer layer];
    layer.frame=CGRectMake((MAIN_SCREAM_WIDTH-200)/2, (MAIN_SCREAM_HEIGHT-200-64)/2, 200, 200);
    layer.borderWidth=1;
    layer.borderColor=[UIColor whiteColor].CGColor;
    layer.emitterPosition=CGPointMake(100, 100);
    
    layer.emitterMode=kCAEmitterLayerSurface;
    layer.emitterShape=kCAEmitterLayerLine;
    
    [self.view.layer addSublayer:layer];
    
    CAEmitterCell *cell=[[CAEmitterCell alloc]init];
    cell.birthRate=5;
    cell.lifetime=50;
    cell.velocity=50;
    cell.velocityRange=3;
    cell.yAcceleration=10;
    cell.emissionRange=0.5 *M_PI*3;
    cell.contents=(__bridge id _Nullable)([UIImage imageNamed:@"snow_1.jpg"].CGImage);
    layer.emitterCells=@[cell];
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
