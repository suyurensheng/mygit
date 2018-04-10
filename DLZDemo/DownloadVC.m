//
//  DownloadVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/4/8.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "DownloadVC.h"

#import "DownloadManager.h"


@interface DownloadVC ()

@end

@implementation DownloadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[DownloadManager sharedManager] checkAndBeganTheDownloadTasks];
    VideoEntity *info=[[VideoEntity alloc]init];
    info.identifyid=@"78789";
    info.orginUrl=@"http://123.56.76.242:8090/data/img/yzx/tmp/video/2016/05/23/2756.mp4";
    info.name=@"test";
    VideoEntity *info2=[[VideoEntity alloc]init];
    info2.identifyid=@"78745";
    info2.orginUrl=@"http://123.56.76.242:8090/data/img/yzx/tmp/video/2016/05/23/2756.mp4";
    info2.name=@"test2";
    VideoEntity *info3=[[VideoEntity alloc]init];
    info3.identifyid=@"78676";
    info3.orginUrl=@"http://123.56.76.242:8090/data/img/yzx/tmp/video/2016/05/23/2756.mp4";
    info3.name=@"test3";
    
    [[DownloadManager   sharedManager] addTaskWithInfo:info complete:^(ErrorEntity *error) {
    }];
    [[DownloadManager   sharedManager] addTaskWithInfo:info2 complete:^(ErrorEntity *error) {
    }];
    [[DownloadManager   sharedManager] addTaskWithInfo:info3 complete:^(ErrorEntity *error) {
    }];
    
    UILabel *testView=[[UILabel alloc]initWithFrame:CGRectMake(10, 200, MAIN_SCREAM_WIDTH-20, 100)];
    testView.backgroundColor=[UIColor whiteColor];
    testView.numberOfLines=0;
    [self.view addSubview:testView];
    
    [[DownloadManager sharedManager] addDownloadStatusChange:^(NSArray<VideoEntity *> *tasks) {
        NSMutableArray  *array=[[NSMutableArray alloc]init];
        
        for (VideoEntity *video in tasks) {
            switch (video.status) {
                case 0:{
                    [array addObject:[NSString stringWithFormat:@"视频id：%@ 进度：等待下载",video.identifyid]];
                }
                    break;
                case 1:{
                    [array addObject:[NSString stringWithFormat:@"视频id：%@ 进度：%f",video.identifyid,video.progress]];
                }
                    break;
                case 2:{
                    BOOL hasfile=[[NSFileManager defaultManager] fileExistsAtPath:video.filePath];
                    if (hasfile) {
                        [array addObject:[NSString stringWithFormat:@"视频id：%@ 进度：已完成",video.identifyid]];
                    }else{
                        [array addObject:[NSString stringWithFormat:@"视频id：%@ 进度：下载出错",video.identifyid]];
                    }
                }
                    break;
                default:
                    break;
            }
        }
        testView.text=[array componentsJoinedByString:@"\n"];
    }];
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
