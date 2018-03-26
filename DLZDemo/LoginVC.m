//
//  LoginVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/20.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "LoginVC.h"
#import <Hyphenate_CN/EMSDKFull.h>
#import "ViewController.h"

@interface LoginVC ()

@end

@implementation LoginVC

-(id)init{

    self=[[[NSBundle mainBundle] loadNibNamed:@"LoginVC" owner:self options:nil] lastObject];
    if (self) {
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

- (IBAction)login:(id)sender {
    
    [self.view endEditing:YES];
    if (_inView.text.length) {
        EMError *error = [[EMClient sharedClient] registerWithUsername:_inView.text password:@"111111"];
        if (error==nil||error.code==203) {
            NSLog(@"注册成功");
            EMError *error = [[EMClient sharedClient] loginWithUsername:_inView.text password:@"111111"];
            if (!error||error.code==200) {
                NSLog(@"登录成功");
                [[EMClient sharedClient].options setIsAutoLogin:YES];
                
                ViewController *vc=[[ViewController alloc]init];
                UINavigationController *nvc=[[UINavigationController alloc]initWithRootViewController:vc];
                [UIApplication  sharedApplication].keyWindow.rootViewController=nvc;
            }
        }
    }
}
@end
