//
//  DownloadManager.h
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/28.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking.h>

@interface VideoEntity : NSObject

@property(nonatomic,strong)NSString *orginUrl;

@property(nonatomic,strong)NSString *name;


@property(nonatomic,strong)NSString *savePath;


@end

@interface DownloadManager : NSObject{
    
    NSURLSessionDownloadTask* _downloadTask;
}


@property (nonatomic,strong) AFHTTPSessionManager *manager;

+(instancetype)sharedManager;

-(void)checkAndBeganTheDownloadTasks;

-(void)addTaskWithInfo:(VideoEntity*)info;

@end
