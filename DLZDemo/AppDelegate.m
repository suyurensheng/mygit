//
//  AppDelegate.m
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/20.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "LoginVC.h"

#import "AppDelegate.h"

#import "CallManager.h"
#import "DownloadManager.h"

#import <UserNotifications/UserNotifications.h>

#import <AMapFoundationKit/AMapFoundationKit.h>
#import "ViewController.h"

#import "HttpManager.h"
#import "CalendarManager.h"
#import "BaseNavVC.h"

#define IOS7      [[[UIDevice currentDevice] systemVersion] floatValue]>=7&&[[[UIDevice currentDevice] systemVersion] floatValue]<8
#define IOS8      [[[UIDevice currentDevice] systemVersion] floatValue]>=8&&[[[UIDevice currentDevice] systemVersion] floatValue]<9
#define IOS9      [[[UIDevice currentDevice] systemVersion] floatValue]>=9&&[[[UIDevice currentDevice] systemVersion] floatValue]<10
#define IOS10    [[[UIDevice currentDevice] systemVersion] floatValue]>=10&&[[[UIDevice currentDevice] systemVersion] floatValue]<11

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//

    ViewController *vc=[[ViewController alloc]init];
    BaseNavVC *nvc=[[BaseNavVC alloc]initWithRootViewController:vc];
    self.window.rootViewController=nvc;
    
    if (IOS8) {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else{
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    }
//    else{
//        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
//        UIRemoteNotificationTypeSound |
//        UIRemoteNotificationTypeAlert;
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
//    }
    [[CallManager sharedManager] began];
    
    
    [AMapServices sharedServices].apiKey=@"26e92fbc21e3e87c36113e96cfc5b067";
    
    [self downTest];
    
    
//    [[CalendarManager sharedCalendarManager] creatCalendarEventWithTitle:@"你好" content:@"日历功能测试" startTime:@"20180223160000" endTime:@"20180223163000" alertTimes:@[@"-3000",@"-60",@"-234"] complete:^(NSString *errorMessage) {
//        if (errorMessage.length) {
//            NSLog(@"添加失败%@",errorMessage);
//        }else{
//            NSLog(@"添加成功");
//        }
//    }];
    
    return YES;
}
-(void)downTest{
    
    //    NSString *test=@"➑hg🐰哈哈";
    //    BOOL hasemoj=[ApplicationUtils hasEmoji:test];
    //    test=[ApplicationUtils disable_emoji:test];
    //    DLog("length=%lu",(unsigned long)test.length);
    //
    //    NSRange range;
    //    for (NSInteger i=0; i<test.length; i+=range.length) {
    //        range=[test rangeOfComposedCharacterSequenceAtIndex:i];
    //        DLog("test=%@",[test substringWithRange:range]);
    //    }
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
    [self.window.rootViewController.view addSubview:testView];
    
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
    
    //    [[HttpManager sharedHttpManager] getNetSpeedComplete:^(CGFloat speedin, CGFloat speedout) {
    //        NSLog(@"下载：%f  上传 :%f",speedin,speedout);
    //    }];
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {

}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^__strong _Nonnull)(void))completionHandler{

}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[CallManager sharedManager] bindDeviceToken:deviceToken];
    NSLog(@"deviceToken绑定成功");
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{

  
}
// 注册deviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"error -- %@",error);
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[CallManager sharedManager] applicationDidEnterBackground:application];
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){
        //程序在10分钟内未被系统关闭或者强制关闭，则程序会调用此代码块，可以在这里做一些保存或者清理工作
        NSLog(@"程序关闭1");
    }];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[CallManager sharedManager] applicationWillEnterForeground:application];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"程序关闭2");
}
//-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
//
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}

@end
