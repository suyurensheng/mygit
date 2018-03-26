//
//  ChatVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2016/11/22.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "ChatVC.h"
@interface ChatVC ()

@end

@implementation ChatVC

-(id)init{

    self=[[[NSBundle mainBundle] loadNibNamed:@"ChatVC" owner:self options:nil] lastObject];
    if (self) {
    
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)messagesDidReceive:(NSArray *)aMessages{


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
//    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled=NO;
    
    self.fd_interactivePopDisabled=YES;
}
@end
