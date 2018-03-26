//
//  QRGetVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/1/31.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "QRGetVC.h"

@interface QRGetVC (){
    
    UIViewController *_target;
}

@end

@implementation QRGetVC

-(id)initWithTarget:(UIViewController *)target{
    
    self=[super init];
    if (self) {
        _target=target;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
