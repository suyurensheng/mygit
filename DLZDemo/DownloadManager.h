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

@interface VideoEntity : NSObject<NSCoding,NSCopying>

@property(nonatomic,strong)NSString *identifyid;

@property(nonatomic,strong)NSString *orginUrl;

@property(nonatomic,strong)NSString *name;



@property(nonatomic,strong)NSString *savePath;

@property(nonatomic,strong)NSString *cachePath;

/**0:新建   1:下载中  2:已完成*/
@property(nonatomic,assign)NSInteger status;

/**0~100*/
@property(nonatomic,assign)CGFloat progress;

@property(nonatomic,strong)NSURLSessionDownloadTask* task;

@end

@interface DownloadManager : NSObject

@property (nonatomic,strong) AFHTTPSessionManager *manager;


+(instancetype)sharedManager;


-(void)addTaskWithInfo:(VideoEntity*)info complete:(void(^)(ErrorEntity *error))complete;

-(void)cancel;

-(void)checkAndBeganTheDownloadTasks;

-(void)addDownloadStatusChange:(void(^)(NSArray<VideoEntity*> *tasks))change;

@end
