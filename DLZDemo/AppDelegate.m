//
//  AppDelegate.m
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/20.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "LoginVC.h"

#import "AppDelegate.h"

#import "DLZUtils/CallManger/CallManager.h"

#import <UserNotifications/UserNotifications.h>

#import <AMapFoundationKit/AMapFoundationKit.h>
#import "ViewController.h"

#import "DLZUtils/HttpManager/HttpManager.h"
#import "CalendarManager.h"
#import "BaseNavVC.h"
#import <DLZkeyChain/DLZKeyChain.h>

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

    [[CallManager sharedManager] began];
    
    
    [AMapServices sharedServices].apiKey=@"26e92fbc21e3e87c36113e96cfc5b067";
    
    
//    [[CalendarManager sharedCalendarManager] creatCalendarEventWithTitle:@"你好" content:@"日历功能测试" startTime:@"20180223160000" endTime:@"20180223163000" alertTimes:@[@"-3000",@"-60",@"-234"] complete:^(NSString *errorMessage) {
//        if (errorMessage.length) {
//            NSLog(@"添加失败%@",errorMessage);
//        }else{
//            NSLog(@"添加成功");
//        }
//    }];
    [self test];
    
    
    return YES;
}
-(NSString*)test{
//        NSString *test=@"➑hg🐰哈哈";
//        BOOL hasemoj=[ApplicationUtils hasEmoji:test];
//        test=[ApplicationUtils disable_emoji:test];
//        DLog("length=%lu",(unsigned long)test.length);
//
//        NSRange range;
//        for (NSInteger i=0; i<test.length; i+=range.length) {
//            range=[test rangeOfComposedCharacterSequenceAtIndex:i];
//            DLog("test=%@",[test substringWithRange:range]);
//        }
    
    
 //   NSAssert(NO, @"测试");
//    NSParameterAssert(NO);
    
    
//    dispatch_queue_t queue=dispatch_queue_create("com.updatedata", NULL);//串行
//    dispatch_queue_t queue2=dispatch_queue_create("com.updatedata2", NULL);//串行
//
////    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//并行
////    dispatch_queue_t queue=dispatch_get_main_queue();//主线程
//
//    NSArray *test=@[@"10000000",@"10",@"10000"];
//    for (NSInteger i=0; i<test.count; i++) {
//        dispatch_async(queue, ^{
//            dispatch_async(queue2, ^{
//                NSInteger num=[test[i] integerValue];
//                NSInteger start=0;
//                do {
//                    start++;
//                } while (start<=num);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSLog(@"quene2=%ld",(long)i);
//                });
//            });
//            NSLog(@"quene1=%ld",(long)i);
//        });
//    }
    
    
//    NSMutableArray *array=[[NSMutableArray alloc]init];
//    for (NSInteger i=1; i<=5; i++) {
//        [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",i]]];
//    }
    NSArray *array=@[@(21),@(3),@(24),@(65),@(76),@(24),@(4)];
    NSArray *result=[array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSLog(@"result=%@",result);
    result=[array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2 compare:obj1   ];
    }];
    NSLog(@"result=%@",result);
//    [HttpManager uploadImages:array progress:^(CGFloat precent) {
//        NSLog(@"progress=%f",precent);
//    } complete:^(ErrorEntity *error, NSArray *imageslist) {
//        NSLog(@"images=%@",imageslist);
//    }];
    [[DataUtils sharedDataUtils] getMemoryStatus:^(double available, double used) {
        NSLog(@"available=%f,used=%f",available,used);
    }];
    return @"haha";
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


@end
