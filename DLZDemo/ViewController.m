//
//  ViewController.m
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/20.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "ViewController.h"
#import "EMClient+Call.h"
#import "LoginVC.h"
#import "VoiceView.h"
#import "CallManager.h"
#import "MapVC.h"
#import "ChatVC.h"
#import "XuanranViewController.h"
#import "BlueVC.h"
#import "LiveVC.h"
#import "AlbumVC.h"
#import "MyMoveVC.h"
#import "QRVC.h"
#import "DataVC.h"
#import "DownloadVC.h"
#import "RotateVC.h"
#import "VoiceRecogiNewVC.h"
#import "GrainVC.h"
#import "ARVC.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,EMCallManagerDelegate>{

    VoiceView *_voice;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"功能列表";
//    _source=@[@"通话",@"切换账号",@"地图",@"聊天",@"渲染",@"蓝牙",@"直播",@"相册",@"我的电影",@"二维码",@"数据库",@"下载",@"旋转",@"语音识别",@"粒子效果",@"AR"];
    _source=@[@"地图",@"渲染",@"蓝牙",@"直播",@"相册",@"我的电影",@"二维码",@"数据库",@"下载",@"旋转",@"语音识别",@"粒子效果",@"AR"];

    
    _listTable=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
    _listTable.delegate=self;
    _listTable.dataSource=self;
    _listTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTable];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _source.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"test"];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"test"];
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text=[_source objectAtIndex:indexPath.row];
    if (indexPath.row%2==0) {
        cell.backgroundColor=[UIColor redColor];
    }else{
        cell.backgroundColor=[UIColor orangeColor];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 60;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *test=[_source objectAtIndex:indexPath.row];
    if ([test isEqualToString:@"通话"]) {
        
        if (!_callView) {
            _callView=[[ShowView alloc]init];
            [_callView.phoneBtn addTarget:self action:@selector(phoneCall) forControlEvents:UIControlEventTouchUpInside];
            [_callView.videoBtn addTarget:self action:@selector(videoCall) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.navigationController.view addSubview:_callView];
    }else if ([test isEqualToString:@"切换账号"]){
        
        EMError *error = [[EMClient sharedClient] logout:YES];
        if (!error) {
            NSLog(@"退出成功");
            LoginVC *lvc=[[LoginVC alloc]init];
            [UIApplication  sharedApplication].keyWindow.rootViewController=lvc;
        }
    }else if ([test isEqualToString:@"地图"]){
        
        MapVC *mvc=[[MapVC alloc]init];
        [self.navigationController pushViewController:mvc animated:YES];
    }else if ([test isEqualToString:@"聊天"]){
        
        ChatVC *mvc=[[ChatVC alloc]init];
        [self.navigationController pushViewController:mvc animated:YES];
    }else if ([test isEqualToString:@"渲染"]){
        
        XuanranViewController *xvc=[[XuanranViewController alloc]init];
        [self.navigationController pushViewController:xvc animated:YES];
    }else if ([test isEqualToString:@"蓝牙"]){
        
        BlueVC *xvc=[[BlueVC alloc]init];
        [self.navigationController pushViewController:xvc animated:YES];
    }else if ([test isEqualToString:@"直播"]){
        
        LiveVC *xvc=[[LiveVC alloc]initWithNib];
        [self.navigationController pushViewController:xvc animated:YES];
    }else if ([test isEqualToString:@"相册"]){
        
        AlbumVC *cvc=[[AlbumVC alloc]initWithTarget:self];
        [self.navigationController pushViewController:cvc animated:YES];
    }else if ([test isEqualToString:@"我的电影"]){
        
        MyMoveVC *cvc=[[MyMoveVC alloc]init];
        [self.navigationController pushViewController:cvc animated:YES];
    }else if ([test isEqualToString:@"二维码"]){
        
        QRVC *cvc=[[QRVC alloc]init];
        [self.navigationController pushViewController:cvc animated:YES];
    }else if ([test isEqualToString:@"数据库"]){
        
        DataVC *cvc=[[DataVC alloc]initWithNib];
        [self.navigationController pushViewController:cvc animated:YES];
    }else if ([test isEqualToString:@"下载"]){
        
        DownloadVC *cvc=[[DownloadVC alloc]init];
        [self.navigationController pushViewController:cvc animated:YES];
    }else if ([test isEqualToString:@"旋转"]){
        
        RotateVC *cvc=[[RotateVC alloc]initWithNib];
        [self.navigationController pushViewController:cvc animated:YES];
    }else if ([test isEqualToString:@"语音识别"]){
        
        VoiceRecogiNewVC *cvc=[[VoiceRecogiNewVC alloc]initWithNib];
        [self.navigationController pushViewController:cvc animated:YES];
    }else if ([test isEqualToString:@"粒子效果"]){
        
        GrainVC *cvc=[[GrainVC alloc]init];
        [self.navigationController pushViewController:cvc animated:YES];
    }else if ([test isEqualToString:@"AR"]){
        
        ARVC *cvc=[[ARVC alloc]init];
        [self.navigationController pushViewController:cvc animated:YES];
    }
}

-(void)phoneCall{

    [_callView removeFromSuperview];
    [[CallManager sharedManager] makeCallWithUser:_callView.inView.text calltype:callTypePhone];
}
-(void)videoCall{
    
    [_callView removeFromSuperview];
    [[CallManager sharedManager] makeCallWithUser:_callView.inView.text calltype:callTypeVideo];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}
// Returns interface orientation masks.
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
}
- (BOOL)shouldAutorotate{
    //是否允许自动转屏
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
