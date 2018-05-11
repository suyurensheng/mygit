//
//  DownloadManager.m
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/28.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "DownloadManager.h"

#define DOWN_LIST_KEY_ALL  @"downalllistkey"
#define DOWN_LIST_KEY_WAIT  @"downwaitlistkey"
#define DOWN_LIST_KEY_ING  @"downinglistkey"

@implementation VideoEntity

-(void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key{
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if (self) {
        self.name=[aDecoder decodeObjectForKey:@"name"];
        self.identifyid=[aDecoder decodeObjectForKey:@"identifyid"];
        self.orginUrl=[aDecoder decodeObjectForKey:@"orginUrl"];
        self.cacheData=[aDecoder decodeObjectForKey:@"cacheData"];
        self.status=[aDecoder decodeIntegerForKey:@"status"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.identifyid forKey:@"identifyid"];
    [aCoder encodeObject:self.orginUrl forKey:@"orginUrl"];
    [aCoder encodeObject:self.cacheData forKey:@"cacheData"];
    [aCoder encodeInteger:self.status forKey:@"status"];
}

-(CGFloat)progress{
    if (_task) {
        NSInteger recive=_task.countOfBytesReceived;
        NSInteger all=_task.countOfBytesExpectedToReceive;
        if (all<=0) {
            return 0;
        }else{
            return 100*recive/all;
        }
    }
    return 0.0f;
}
-(NSString*)filePath{
    
    NSString *path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"videos"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    path=[path stringByAppendingPathComponent:_name];
    return path;
}

@end

@interface DownloadManager (){
        
    NSMutableArray *_allList;
    NSMutableArray *_ingList;
    
    NSMutableArray *_completeList;
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
        
        _allList=[NSMutableArray arrayWithArray:[DataUtils readDataWithName:DOWN_LIST_KEY_ALL]];
        _ingList=[[NSMutableArray alloc]init];
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

    if (_ingList.count>=MAX_DOWN_NUM) {
        return;
    }
    for (VideoEntity *video in _allList) {
        if (_ingList.count<2) {
            if (video.status==1) {
                [_ingList addObject:video];
            }
        }else{
            break;
        }
    }
    for (VideoEntity *video in _allList) {
        if (_ingList.count<2) {
            if (video.status==0) {
                video.status=1;
                [_ingList addObject:video];
            }
        }else{
            break;
        }
    }
    for (VideoEntity *video in _ingList) {
        video.task=[self addTask:video];
    }
}
-(NSData*)getResumeData:(NSData*)data{

    NSString *str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *oldsize=[[[[str componentsSeparatedByString:@"<key>NSURLSessionResumeBytesReceived</key>\n\t<integer>"] lastObject] componentsSeparatedByString:@"</integer>"] firstObject];
    
    NSString *tempPath=[[[[str componentsSeparatedByString:@"<key>NSURLSessionResumeInfoTempFileName</key>\n\t<string>"] lastObject] componentsSeparatedByString:@"</string>"] firstObject];
    tempPath=[NSTemporaryDirectory() stringByAppendingPathComponent:tempPath];
    NSString *newsize=[NSString stringWithFormat:@"%llu",[[[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:nil] fileSize]];
    str=[str stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<key>NSURLSessionResumeBytesReceived</key>\n\t<integer>%@</integer>",oldsize] withString:[NSString stringWithFormat:@"<key>NSURLSessionResumeBytesReceived</key>\n\t<integer>%@</integer>",newsize]];
    
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}
-(NSURLSessionDownloadTask*)addTask:(VideoEntity *)info{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:info.orginUrl]];
    NSURLSessionDownloadTask *_downloadTask;
    if (info.cacheData) {

        NSData *data=[self getResumeData:info.cacheData];
        _downloadTask=[_manager downloadTaskWithResumeData:data progress:^(NSProgress * _Nonnull downloadProgress) {
            [self downLoadProgressChange];
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            return [NSURL fileURLWithPath:info.filePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (!error) {
                [self downLoadComplete:filePath];
            }
        }];
    }else{
        _downloadTask =[_manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            [self downLoadProgressChange];
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            NSString *path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"videos"];
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            path=[path stringByAppendingPathComponent:info.name];
            return [NSURL fileURLWithPath:path];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (!error) {
                [self downLoadComplete:filePath];
            }
        }];
    }
    [_downloadTask resume];
    return _downloadTask;
}
-(void)addTaskWithInfo:(VideoEntity *)info complete:(void (^)(ErrorEntity *))complete{
    
    for (VideoEntity *entity in _allList) {
        if ([entity.identifyid isEqualToString:info.identifyid]) {
            complete([ErrorEntity errorInfoWithCode:100 message:@"任务已存在"]);
            return;
        }
    }
    if (_ingList.count<MAX_DOWN_NUM) {
        info.status=1;
        info.task=[self addTask:info];
        [_ingList insertObject:info atIndex:0];
    }else{
        info.status=0;
    }
    [_allList insertObject:info atIndex:0];
    complete([ErrorEntity errorInfoWithCode:0 message:@"添加成功"]);
}
-(void)downLoadProgressChange{
    
    for (VideoEntity *video in _allList) {
        if (video.status==1&&!video.cacheData&&video.progress>0) {
            [video.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                if (resumeData) {
                    video.cacheData=resumeData;
                    video.task=[self addTask:video];
                }
                [DataUtils writeData:_allList WithName:DOWN_LIST_KEY_ALL];
            }];
        }
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (void(^changeblock)(NSArray<VideoEntity *> *list) in _completeList) {
            changeblock(_allList);
        }
    });
}
-(void)downLoadComplete:(NSURL*)responsePath{
    
    NSString *url=[[responsePath.absoluteString componentsSeparatedByString:@"file://"] lastObject];
    
    for (VideoEntity *video in _ingList) {
        if ([video.name isEqualToString:[[url componentsSeparatedByString:@"/"]lastObject]]) {
            video.status=2;
            [_ingList removeObject:video];
            break;
        }
    }
    for (VideoEntity *video in _allList) {
        if (_ingList.count<2) {
            if (video.status==0) {
                video.status=1;
                video.task=[self addTask:video];
                [_ingList addObject:video];
            }
        }else{
            break;
        }
    }
    for (void(^changeblock)(NSArray<VideoEntity *> *list) in _completeList) {
        changeblock(_allList);
    }
    [self playDownloadSound];
    
    [DataUtils writeData:_allList WithName:DOWN_LIST_KEY_ALL];
}

-(void)addDownloadStatusChange:(void (^)(NSArray<VideoEntity *> *))change{
    
    void(^changeblock)(NSArray<VideoEntity *> *list)=change;
    if (!_completeList) {
        _completeList=[[NSMutableArray alloc]init];
    }
    [_completeList addObject:changeblock];
    changeblock(_allList);
}

-(void)playDownloadSound{
    
    SystemSoundID ID;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"ding" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &ID);
    AudioServicesPlaySystemSound(ID);
}

@end
