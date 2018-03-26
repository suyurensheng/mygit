//
//  CallManager.h
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/24.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <Hyphenate_CN/EMSDKFull.h>

typedef enum {
    callTypePhone,
    callTypeVideo,
}callType;

@interface CallManager : NSObject

+(instancetype)sharedManager;

@property(nonatomic,strong)AVAudioPlayer *audioPlayer;


-(void)began;

-(void)makeCallWithUser:(NSString*)user calltype:(callType)calltype;

-(void)bindDeviceToken:(NSData *)deviceToken;

- (void)applicationDidEnterBackground:(UIApplication *)application;

- (void)applicationWillEnterForeground:(UIApplication *)application;

@end
