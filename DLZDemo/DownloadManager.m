//
//  DownloadManager.m
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/28.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "DownloadManager.h"

@implementation VideoEntity

-(void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key{

}
@end
@implementation DownloadManager

-(id)init{
    
    self=[super init];
    if (self) {
        _manager=[AFHTTPSessionManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.attemptsToRecreateUploadTasksForBackgroundSessions = YES;
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        _manager.securityPolicy = securityPolicy;
        //设置超时时间
        [_manager.requestSerializer setTimeoutInterval:20];
    }
    return self;
}

+(instancetype)sharedManager{
    
    static DownloadManager *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared=[[DownloadManager alloc]init];
    });
    return _shared;
}
-(void)checkAndBeganTheDownloadTasks{



}

-(void)addTaskWithInfo:(VideoEntity *)info{
    
    NSString *savePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"videos"];
    
    NSString *temPath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"temps"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:temPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    info.savePath=[savePath stringByAppendingPathComponent:info.name];
    temPath=[temPath stringByAppendingPathComponent:info.name];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:info.orginUrl]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:temPath]) {
        NSData *data=[NSData dataWithContentsOfFile:temPath];
        _downloadTask=[_manager downloadTaskWithResumeData:data progress:^(NSProgress * _Nonnull downloadProgress) {
            double p = 100 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
            NSLog(@"progress=%lf",p);
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:info.savePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"downlaodcomplete path=%@",filePath);
                [[NSFileManager defaultManager] removeItemAtPath:temPath error:nil];
            }
        }];
    }else{
        _downloadTask =[_manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            double p = 100*downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
            NSLog(@"progress=%lf",p);
            if (p==40) {
                [_downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    [resumeData writeToFile:temPath  atomically:YES];
                }];
            }
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            return [NSURL fileURLWithPath:info.savePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"downlaodcomplete path=%@",filePath);
            }
        }];
    }
    [_downloadTask resume];
}
//#pragma mark ------------------文件下载相关的模块---File download related modules-------------------
///*
// * 添加了分用户功能
// * 添加了在线断点和离线断点续传功能（IOS9 杀死APP问题，后期需要修改技术方案）
// * 添加了多并发同事下载多个文件，多线程队列执行任务
// * 添加了取消所有网络请求功能
// * 实现了网络异常资源异常断点
// */
//- (void)loadDownloadTask{
//    
//    NSArray *wait=[DataUtils readDataWithName:DOWNLOAD_WAIT];
//    NSArray *ing=[DataUtils readDataWithName:DOWNLOAD_ING];
//    NSMutableArray *array=[NSMutableArray array];
//    [array addObjectsFromArray:ing];
//    [array addObjectsFromArray:wait];
//    for (VideoEntity *videoInfo in array) {
//        [self downloadVideoWithVideoInfo:videoInfo];
//    }
//}
//
//-(void)downloadVideoWithVideoInfo:(VideoEntity *)videoInfo{
//    
//    NSString *name=[[videoInfo.videoPath componentsSeparatedByString:@"/"] lastObject];
//    NSString* usrid =  [NSString stringWithFormat:@"%ld",(long)[UserinfoEntity sharedUserInfo].userid];
//    NSString *path=[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@/%@",usrid,name]];
//    
//    videoInfo.playPath=path;
//    
//    if (videoInfo.resumeData.length>0) {
//        
//        [self downloadTheVideo:videoInfo withUser:usrid];
//    }
//    else
//    {
//        [self downloadWithVideo:videoInfo withUser:usrid];
//    }
//}
//
//- (NSURL*)pathForBlockTargetPath:(NSURL*)targetPath :(NSURLResponse*)response user:(NSString*)usrid
//{
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSError *fileManagerError = nil;
//    NSString *basePath = [cachesPath stringByAppendingPathComponent:usrid];
//    [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:&fileManagerError];
//    NSString *path = [basePath stringByAppendingPathComponent:response.suggestedFilename];
//    if (fileManagerError) {
//        path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
//    }
//    NSLog(@"targetPathtargetPathtargetPath%@   path  \n [NSURL fileURLWithPath:path]   %@  \n  %@",targetPath,path,[NSURL fileURLWithPath:path]);
//    return [NSURL fileURLWithPath:path];
//}
//
//- (BOOL)isHaveFolderInTargetAddress:(VideoEntity*)video withUser:(NSString*)usrid{
//    
//    [self.lock lock];
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *basePath = [[cachesPath stringByAppendingPathComponent:usrid] stringByAppendingPathComponent:video.tempFileName];
//    
//    //    NSLog(@"---------------- cachesName  --------%@",basePath);
//    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:video.tempFileName];
//    //    NSLog(@"---------------- temporaryPath  --------%@",tempPath);
//    NSFileManager *fileManager=[NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:basePath]==NO) {
//        [self.lock unlock];
//        return NO;
//    }
//    NSError *fileManagerError = nil;
//    [fileManager moveItemAtURL:[NSURL fileURLWithPath:basePath] toURL:[NSURL fileURLWithPath:tempPath] error:&fileManagerError];
//    
//    NSLog(@"---------fileManagerError--------%@",fileManagerError);
//    if (fileManagerError.code>0) {
//        [self.lock unlock];
//        return NO;
//    }
//    [self.lock unlock];
//    return YES;
//}
//
//- (void)updateUI:(VideoEntity*)video progress:(NSProgress*)downloadProgress
//{
//    // 给Progress添加监听 KVO
//    double p = 100 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
//    // 回到主队列刷新UI
//    dispatch_async(dispatch_get_main_queue(), ^{
//        video.downloadSize = p;
//        video.totalUnitCount = downloadProgress.totalUnitCount;
//        video.completedUnitCount = downloadProgress.completedUnitCount;
//        video.task_state = NSURLSessionTaskStateRunning;
//        self.runingDic[@(video.video_id)]=video;
//        if ([self.updateDelegate respondsToSelector:@selector(updateCellProgress:)]) {
//            [self.updateDelegate updateCellProgress:video];
//        }
//    });
//}
//
//- (void)exceptionOfdownload:(VideoEntity*)video filePath:(NSURL*)filePath withError:(NSError*)error
//{
//    @synchronized (video) {
//        if (video.totalUnitCount==video.completedUnitCount) {
//            [self.runingDic removeObjectForKey:@(video.video_id)];
//            [self.resumeDataDic removeObjectForKey:@(video.video_id)];
//            [DataUtils writeData:self.resumeDataDic WithName:RESUMEDATA];
//        }
//        [self reviseTaskStateRunning:video.video_id accordingTo:DOWNLOAD_WAIT];
//    }
//    // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
//    NSString *imgFilePath = [filePath path];// 将NSURL转成NSString
//    DLog(@"---------imgFilePath %@  ",imgFilePath);
//    if (error) {
//        DLog(@"---------error %@ \n ",error);
//        DLog(@"\n---------[NSURL URLWithString:video.videoPath] %@  ",video.videoPath);
//        return ;
//    }
//    [self playDownloadSound];
//    for (NSURLSessionDownloadTask* download in self.taskArray) {
//        if (download.taskIdentifier==video.task_id) {
//            @synchronized (video) {
//                video.task_state = NSURLSessionTaskStateCompleted;
//                [self reviseTaskStateRunning:video.video_id accordingTo:DOWNLOAD_ING];
//                [self saveToDisk:video operationStyle:DOWNLOAD_DONE];
//            }
//            break;
//        }
//    }
//    @synchronized (self.taskArray) {
//        [self.taskArray removeObjectAtIndex:0];//**********//
//    }
//    if ([self.updateDelegate respondsToSelector:@selector(updateCellProgress:)]) {
//        video.task_state = NSURLSessionTaskStateCompleted;
//        [self.updateDelegate updateCellProgress:video];
//    }
//    if (self.taskArray.count>0) {
//        [self scheduleMaxNumOfTaskInQueue];
//    }
//    //    else
//    //    {
//    //        NSString* usrid =  [NSString stringWithFormat:@"%ld",[UserinfoEntity sharedUserInfo].userid];
//    //        NSArray* arr = [NSMutableArray arrayWithArray:[DataUtils readDataWithName:DOWNLOAD_WAIT]];
//    //        for (VideoEntity* video in arr) {
//    //            [self reviseTaskStateRunning:video.video_id accordingTo:DOWNLOAD_WAIT];
//    //            [self downloadWithVideo:video withUser:usrid];
//    //        }
//    //    }
//}
//
//- (void)downloadWithVideo:(VideoEntity*)video withUser:(NSString*)usrid
//{
//    [self.manager.requestSerializer setTimeoutInterval:20];
//    __weak typeof(self) weakSelf = self;
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:video.videoPath]];
//    
//    NSURLSessionDownloadTask* downloadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
//        [weakSelf updateUI:video progress:downloadProgress];
//    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//        
//        return [weakSelf pathForBlockTargetPath:targetPath :response user:usrid];
//        
//    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//        if (video.totalUnitCount==video.completedUnitCount) {
//            [weakSelf.runingDic removeObjectForKey:@(video.video_id)];
//            [weakSelf.resumeDataDic removeObjectForKey:@(video.video_id)];
//            [DataUtils writeData:weakSelf.resumeDataDic WithName:RESUMEDATA];
//        }
//        @synchronized (video) {
//            [weakSelf reviseTaskStateRunning:video.video_id accordingTo:DOWNLOAD_WAIT];
//        }
//        // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
//        NSString *imgFilePath = [filePath path];// 将NSURL转成NSString
//        NSLog(@"---------imgFilePath %@  ",imgFilePath);
//        if (error) {
//            NSLog(@"---------error %@ \n ",error);
//            NSLog(@"\n---------[NSURL URLWithString:video.videoPath] %@  ",video.videoPath);
//            if (error.code == -1005) {
//                //[weakSelf operationDown:video.task_id onORoff:NSURLSessionTaskStateSuspended];
//            } else {
//                NSLog(@"Error during connection: %@",error.description);
//                
//            }
//            return ;
//        }
//        [weakSelf playDownloadSound];
//        for (NSURLSessionDownloadTask* download in weakSelf.taskArray) {
//            if (download.taskIdentifier==video.task_id) {
//                @synchronized (video) {
//                    video.task_state = NSURLSessionTaskStateCompleted;
//                    [weakSelf reviseTaskStateRunning:video.video_id accordingTo:DOWNLOAD_ING];
//                    [weakSelf saveToDisk:video operationStyle:DOWNLOAD_DONE];
//                }
//                break;
//            }
//        }
//        @synchronized (weakSelf.taskArray) {
//            [weakSelf.taskArray removeObjectAtIndex:0];//**********//
//        }
//        if ([weakSelf.updateDelegate respondsToSelector:@selector(updateCellProgress:)]) {
//            video.task_state = NSURLSessionTaskStateCompleted;
//            [weakSelf.updateDelegate updateCellProgress:video];
//        }
//        
//        if (weakSelf.taskArray.count>0) {
//            [weakSelf scheduleMaxNumOfTaskInQueue];
//        }
//    }];
//    
//    video.task_id=downloadTask.taskIdentifier;
//    [self.taskArray addObject:downloadTask];
//    
//    if (self.manager.downloadTasks.count<self.maxNumOfTaskInQueue) {
//        if ([weakSelf.updateDelegate respondsToSelector:@selector(startDownload:)]) {
//            video.task_state = NSURLSessionTaskStateRunning;
//            [weakSelf.updateDelegate startDownload:downloadTask];
//        }
//        [weakSelf saveToDisk:video operationStyle:DOWNLOAD_ING];
//        [downloadTask resume];
//    }
//    else
//    {
//        self.suspendDic[@(downloadTask.taskIdentifier)] = video;
//        video.task_state = NSURLSessionTaskStateSuspended;
//        [weakSelf saveToDisk:video operationStyle:DOWNLOAD_WAIT];
//    }
//}
//
//- (void)disposeDownloadTask:(NSURLSessionDownloadTask*)downloadTask forVideo:(VideoEntity*)video
//{
//    video.task_id=downloadTask.taskIdentifier;
//    [self.taskArray addObject:downloadTask];
//    
//    if (self.manager.downloadTasks.count<self.maxNumOfTaskInQueue) {
//        if ([self.updateDelegate respondsToSelector:@selector(startDownload:)]) {
//            video.task_state = NSURLSessionTaskStateRunning;
//            [self.updateDelegate startDownload:downloadTask];
//        }
//        [self saveToDisk:video operationStyle:DOWNLOAD_ING];
//        [downloadTask resume];
//    }
//    //    else
//    //    {
//    //        self.suspendDic[@(downloadTask.taskIdentifier)] = video;
//    //        video.task_state = NSURLSessionTaskStateSuspended;
//    //        [self saveToDisk:video operationStyle:DOWNLOAD_WAIT];
//    //    }
//}
//
//- (void)scheduleMaxNumOfTaskInQueue
//{
//    __weak typeof(self) weakSelf = self;
//    [self.taskArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSURLSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//        if (idx<self.maxNumOfTaskInQueue) {
//            VideoEntity* video = weakSelf.suspendDic[@(obj.taskIdentifier)];
//            [weakSelf saveToDisk:video operationStyle:DOWNLOAD_ING];
//            [weakSelf.suspendDic removeObjectForKey:@(obj.taskIdentifier)];
//            [weakSelf reviseTaskStateRunning:video.video_id accordingTo:DOWNLOAD_WAIT];
//            [obj resume];
//        }
//        else
//        {
//            return ;
//        }
//    }];
//}
//
//-(void)saveToDisk:(VideoEntity*)video operationStyle:(NSString*)taskState
//{
//    NSMutableArray *done=[NSMutableArray arrayWithArray:[DataUtils readDataWithName:taskState]];
//    __block BOOL fg = NO;
//    if (done.count>0) {
//        [done enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (((VideoEntity*)obj).video_id==video.video_id) {
//                fg = YES;
//            }
//        }];
//        if (!fg) {
//            [done addObject:video];
//        }
//    } else {
//        [done addObject:video];
//    }
//    [DataUtils writeData:done WithName:taskState];
//}
//
//- (void)reviseTaskStateRunning:(NSInteger)videoId accordingTo:(NSString*)taskState
//{
//    NSMutableArray *done=[NSMutableArray arrayWithArray:[DataUtils readDataWithName:taskState]];
//    NSInteger i = 0;
//    for (VideoEntity* video in [DataUtils readDataWithName:taskState]) {
//        if (video.video_id==videoId) {
//            [done removeObjectAtIndex:i];
//            [DataUtils writeData:done WithName:taskState];
//            return;
//        }
//        i++;
//    }
//}
//
//- (void)operationDown:(NSUInteger)taskId onORoff:(NSURLSessionTaskState)state
//{
//    [self.taskArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSURLSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (taskId==obj.taskIdentifier) {
//            switch (state) {
//                case NSURLSessionTaskStateRunning:
//                {
//                    [obj resume];
//                }
//                    break;
//                case NSURLSessionTaskStateSuspended:
//                {
//                    [obj suspend];
//                }
//                    break;
//                case NSURLSessionTaskStateCanceling:
//                {
//                    [obj cancel];
//                }
//                    break;
//                default:NSURLSessionTaskStateCompleted:
//                    
//                    break;
//            }
//        }
//    }];
//}
//
//- (void)networkMonitor
//{
//    //网络监控句柄
//    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
//    //__weak typeof(self) weakSelf = self;
//    //要监控网络连接状态，必须要先调用单例的startMonitoring方法
//    [manager startMonitoring];
//    
//    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        //status:
//        //AFNetworkReachabilityStatusUnknown          = -1,  未知
//        //AFNetworkReachabilityStatusNotReachable     = 0,   未连接
//        //AFNetworkReachabilityStatusReachableViaWWAN = 1,   3G
//        //AFNetworkReachabilityStatusReachableViaWiFi = 2,   无线连接
//        NSLog(@"setReachabilityStatusChangeBlock %ld",(long)status);
//        switch (status) {
//            case AFNetworkReachabilityStatusNotReachable:
//            {
//                
//            }
//                break;
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//            {
//                //[weakSelf scheduleMaxNumOfTaskInQueue];
//            }
//                break;
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//            {
//                
//            }
//                break;
//            default:
//                break;
//        }
//    }];
//}
///*
// * 对于IOS9：异常退出APP保存断点的方法有以下5种：均可以实现
// * 1、通过runtime接口找到内部属性，找到临时文件的地址属性，http://blog.csdn.net/yan_daoqiu/article/details/50469601
// * 由于resumeData是由各种下载参数组成理论构造一个NSData可以使用。需要验证一下
// * 2、在progress回调中每次本地保存，但是这样会降低程序性能不合理
// * 3、在实时回调方法中记录已接受的数据，将节点跳到文件的末尾seekToEndOfFile，
// *   在didReceiveData中追加写入数据writeData，但是这样频繁写文件同样会降低程序性能
// * 4、彻底使用原生NSURLSession来自定义，操作Range 优点灵活，缺点代码量大
// * 5、使用原生NSURLSession的NSOutputStream来自定义  优点灵活，缺点代码量大
// * --------------------在IOS9系统中杀死APP时候调用cancelByProducingResumeData的block不会执行-------------
// * 使用cancelByProducingResumeData注意事项：A download can be resumed only if the following conditions are met:
// The resource has not changed since you first requested it
// The task is an HTTP or HTTPS GET request
// The server provides either the ETag or Last-Modified header (or both) in its response
// The server supports byte-range requests
// The temporary file hasn’t been deleted by the system in response to disk space pressure
// */
//- (void)saveLastDataForVideo
//{
//    __weak typeof(self) weakSelf = self;
//    [self.runingDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        VideoEntity* video = (VideoEntity*)obj;
//        NSMutableArray *done=[NSMutableArray arrayWithArray:[DataUtils readDataWithName:DOWNLOAD_ING]];
//        [done enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (((VideoEntity*)obj).video_id==video.video_id) {
//                [done replaceObjectAtIndex:idx withObject:video];
//                [DataUtils writeData:done WithName:DOWNLOAD_ING];
//                return ;
//            }
//        }];
//        
//    }];
//    
//    [self.runingDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        VideoEntity* video = (VideoEntity*)obj;
//        for (NSURLSessionDownloadTask* downloadTask in weakSelf.taskArray) {
//            if (downloadTask.taskIdentifier==video.task_id) {
//                [self fetchPropertyFromRequest:nil downloadTask:downloadTask forVideo:video];
//                break;
//            }
//        }
//    }];
//}
//
////网络异常断点保存
//- (void)networkExceptionBreakpoint:(NSURLSessionDownloadTask*)downloadTask
//{
//    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
//        
//        NSMutableArray *done=[NSMutableArray arrayWithArray:[DataUtils readDataWithName:DOWNLOAD_ING]];
//        [done enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            VideoEntity* vide2 = (VideoEntity*)obj;
//            vide2.resumeData = resumeData;
//            [done replaceObjectAtIndex:idx withObject:vide2];
//            [DataUtils writeData:done WithName:DOWNLOAD_ING];
//            return ;
//        }];
//    }];
//}
//
//- (void)saveBreakPointUrl:(NSString*)url withModel:(VideoEntity*)videoData localUrl:(NSString*)path
//{
//    NSMutableDictionary *resumeDataDict = [NSMutableDictionary dictionary];
//    NSMutableURLRequest *newResumeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:videoData.videoPath]];
//    [newResumeRequest addValue:[NSString stringWithFormat:@"bytes=%ld-",(NSInteger)videoData.completedUnitCount] forHTTPHeaderField:@"Range"];
//    NSData *newResumeRequestData = [NSKeyedArchiver archivedDataWithRootObject:newResumeRequest];
//    [resumeDataDict setObject:[NSNumber numberWithInteger:(NSInteger)videoData.completedUnitCount]forKey:@"NSURLSessionResumeBytesReceived"];
//    [resumeDataDict setObject:newResumeRequestData forKey:@"NSURLSessionResumeCurrentRequest"];
//    [resumeDataDict setObject:[path lastPathComponent]forKey:@"NSURLSessionResumeInfoTempFileName"];
//    NSData *resumeData = [NSPropertyListSerialization dataWithPropertyList:resumeDataDict format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
//    NSMutableArray *done=[NSMutableArray arrayWithArray:[DataUtils readDataWithName:DOWNLOAD_ING]];
//    [done enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        VideoEntity* vide2 = (VideoEntity*)obj;
//        vide2.resumeData = resumeData;
//        vide2.tempFileName = [path lastPathComponent];
//        [done replaceObjectAtIndex:idx withObject:vide2];
//        [DataUtils writeData:done WithName:DOWNLOAD_ING];
//    }];
//    
//}
//- (void)fetchPropertyFromRequest:(NSString*)afnetClientRequest downloadTask:(NSURLSessionDownloadTask*) downloadTask forVideo:(VideoEntity*)video
//{
//    //拉取属性
//    unsigned int outCount, i;
//    objc_property_t *properties = class_copyPropertyList([downloadTask class], &outCount);
//    for (i = 0; i<outCount; i++)
//    {
//        objc_property_t property = properties[i];
//        const char* char_f =property_getName(property);
//        NSString *propertyName = [NSString stringWithUTF8String:char_f];
//        
//        if ([@"downloadFile" isEqualToString:propertyName])
//        {
//            id propertyValue = [downloadTask valueForKey:(NSString *)propertyName];
//            unsigned int downloadFileoutCount, downloadFileIndex;
//            objc_property_t *downloadFileproperties = class_copyPropertyList([propertyValue class], &downloadFileoutCount);
//            for (downloadFileIndex = 0; downloadFileIndex < downloadFileoutCount; downloadFileIndex++)
//            {
//                objc_property_t downloadFileproperty = downloadFileproperties[downloadFileIndex];
//                const char* downloadFilechar_f =property_getName(downloadFileproperty);
//                NSString *downloadFilepropertyName = [NSString stringWithUTF8String:downloadFilechar_f];
//                if([@"path" isEqualToString:downloadFilepropertyName])
//                {
//                    id downloadFilepropertyValue = [propertyValue valueForKey:(NSString *)downloadFilepropertyName];
//                    if(!self.contiueDownload)
//                    {
//                        //保存文件临时下载任务
//                        //SaveTmpFileName(afnetClientRequest, downloadFilepropertyValue);
//                        
//                        [self saveTmpFileNamePath:downloadFilepropertyValue requestURL:afnetClientRequest withModel:video];
//                    }
//                    
//                    break;
//                }
//            }
//            free(downloadFileproperties);
//        }
//        else
//        {
//            continue;
//        }
//    }
//    free(properties);
//}
//
//- (void)saveTmpFileNamePath:(NSString*)path requestURL:(NSString*)url withModel:(VideoEntity *)video
//{
//    NSLog(@" url-------%@    path -------- %@",url,path);
//    NSError *fileManagerError = nil;
//    NSString* tagetDirectorie = [video.playPath stringByDeletingLastPathComponent];
//    [self removeAllTask];
//    NSString* tagetPath = nil;
//    [self.lock lock];
//    [[NSFileManager defaultManager] createDirectoryAtPath:tagetDirectorie withIntermediateDirectories:YES attributes:nil error:&fileManagerError];
//    tagetPath = [tagetDirectorie stringByAppendingPathComponent:[path lastPathComponent]];
//    
//    [[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:path] toURL:[NSURL fileURLWithPath:tagetPath] error:&fileManagerError];
//    NSLog(@" video.playPathtagetPath-------%@  \n [NSURL URLWithString:tagetPath]  %@  \n fileManagerError %@  code  %ld",tagetPath,[NSURL URLWithString:tagetPath],fileManagerError,(long)fileManagerError.code);
//    
//    if (fileManagerError.code>0) {
//        //        UIAlertView* alert  = [[UIAlertView alloc]initWithTitle:@"文件系统❌" message:@"移动文件夹发送了错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        //        [alert show];
//    }
//    [self saveBreakPointUrl:url withModel:video localUrl:path];
//    [self.lock unlock];
//}
//
////实现断点续传
//- (void)downloadTheVideo:(VideoEntity*)video withUser:(NSString*)usrid
//{
//    __weak typeof(self) weakSelf = self;
//    [self.manager.requestSerializer setTimeoutInterval:20];
//    if ([self isHaveFolderInTargetAddress:video withUser:usrid]==NO) {
//        //        UIAlertView* alert  = [[UIAlertView alloc]initWithTitle:@"文件系统❌" message:@"移动文件夹发送了错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        //        [alert show];
//        return;
//    }
//    NSURLSessionDownloadTask* downloadTask = [self.manager downloadTaskWithResumeData:video.resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
//        [weakSelf updateUI:video progress:downloadProgress];
//    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//        return [weakSelf pathForBlockTargetPath:targetPath :response user:usrid];
//    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//        [weakSelf exceptionOfdownload:video filePath:filePath withError:error];
//    }];
//    [weakSelf disposeDownloadTask:downloadTask forVideo:video];
//}
//
//-(void)playDownloadSound{
//    
//    SystemSoundID ID;
//    NSBundle *bundle = [NSBundle mainBundle];
//    NSURL *url = [bundle URLForResource:kSrcName(@"download-complete.wav") withExtension:nil];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &ID);
//    AudioServicesPlaySystemSound(ID);
//}
//
//-(void) removeAllTask{
//    
//    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
//    [self.manager invalidateSessionCancelingTasks:NO];
//}

@end
