//
//  LiveVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2017/6/1.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "LiveVC.h"

@interface LiveVC ()

@end

@implementation LiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    NSURL *url = [NSURL URLWithString:@"http://123.56.76.242:8090/data/img/yzx/tmp/video/2016/05/23/2756.mp4"];
    _playView=[[MPMoviePlayerController alloc]init];
    _playView.movieSourceType=MPMovieSourceTypeStreaming;
    [_playView setControlStyle:MPMovieControlStyleNone];
    
    _playView.view.frame=_playBack.bounds;
    [_playView setContentURL:url];
    _playView.initialPlaybackTime = -1;
    [_playBack addSubview:_playView.view];
    
    _playView.view.translatesAutoresizingMaskIntoConstraints=NO;
    
    NSLayoutConstraint *top=[NSLayoutConstraint constraintWithItem:_playView.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_playBack attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *left=[NSLayoutConstraint constraintWithItem:_playView.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_playBack attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *bottom=[NSLayoutConstraint constraintWithItem:_playView.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_playBack attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *right=[NSLayoutConstraint constraintWithItem:_playView.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_playBack attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];

    [_playBack addConstraints:@[top,left,bottom,right]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [_playView prepareToPlay];
    
    [_playView play];
}
-(void)myMovieFinishedCallback{

    NSLog(@"play finished");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}
-(void)screenOrientationDidChange{
    

    NSLog(@"currentFame=%@",NSStringFromCGRect(self.view.frame));
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate{
    //是否允许自动转屏
    return YES;
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)full:(id)sender {
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];//这句话是防止手动先把设备置为横屏,导致下面的语句失效.
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
}
@end
