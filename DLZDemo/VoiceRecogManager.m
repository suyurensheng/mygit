//
//  VoiceRecogManager.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/4/10.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "VoiceRecogManager.h"

@implementation VoiceRecogManager

+(instancetype)sharedManager{
    
    static VoiceRecogManager *_shared;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        _shared=[[VoiceRecogManager alloc]init];
    });
    return _shared;
}
@end
