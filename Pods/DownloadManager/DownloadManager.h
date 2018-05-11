//
//  DownloadManager.h
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/28.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_DOWN_NUM  2

#import <AFNetworking.h>

@interface VideoEntity : NSObject<NSCoding>

@property(nonatomic,strong)NSString *identifyid;

@property(nonatomic,strong)NSString *orginUrl;

@property(nonatomic,strong)NSString *name;

/**0:新建   1:下载中  2:已完成*/
@property(nonatomic,assign)NSInteger status;


@property(nonatomic,strong)NSData *cacheData;


@property(nonatomic,strong)NSURLSessionDownloadTask* task;

/**0~100*/
-(CGFloat)progress;

-(NSString*)filePath;

@end

@interface DownloadManager : NSObject

@property (nonatomic,strong) AFHTTPSessionManager *manager;


+(instancetype)sharedManager;


-(void)addTaskWithInfo:(VideoEntity*)info complete:(void(^)(ErrorEntity *error))complete;

-(void)checkAndBeganTheDownloadTasks;

-(void)addDownloadStatusChange:(void(^)(NSArray<VideoEntity*> *tasks))change;

@end
