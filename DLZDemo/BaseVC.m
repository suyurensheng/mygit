//
//  BaseVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2017/6/2.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()

@end

@implementation BaseVC

-(id)initWithNib{

    NSString *classname=NSStringFromClass(self.class);
    self=[[[NSBundle mainBundle] loadNibNamed:classname owner:self options:nil] lastObject];
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
-(BOOL)shouldAutorotate{
    return NO;
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
