//
//  VoiceRecogManager.h
//  DLZDemo
//
//  Created by 董力祯 on 2018/4/10.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceRecogManager : NSObject


+(instancetype)sharedManager;

+(void)startRecogi;

@end
