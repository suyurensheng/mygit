//
//  NetManager.m
//  AllStar
//
//  Created by 董力祯 on 16/1/11.
//  Copyright © 2016年 youmingxing. All rights reserved.
//

#import "HttpManager.h"

#import "AppDelegate.h"
#import "Commdefine.h"
#import "ApplicationUtils.h"


#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

@interface HttpManager(){

    void (^_complete) (CGFloat speedin , CGFloat speedout);
    
    uint32_t _lastiBytes;
    uint32_t _lastoBytes;
}

@end

@implementation HttpManager
-(id)init{
    
    self=[super init];
    if (self) {
        _manager=[AFHTTPSessionManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        _manager.securityPolicy = securityPolicy;
        //设置超时时间
        [_manager.requestSerializer setTimeoutInterval:10];
    }
    return self;
}

+(instancetype)sharedHttpManager{
    
    static HttpManager *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared=[[HttpManager alloc]init];
    });
    return _shared;
}

-(void)postWithURLString:(NSString *)urlString param:(NSDictionary *)param completion:(void (^)(id, ErrorEntity *))completion{
    
    NSString *url=[@"baseurl" stringByAppendingString:urlString];
    DLog(@"request=%@",url);
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithDictionary:[HttpManager getBaseParams]];
    if (param) {
        [dic addEntriesFromDictionary:param];
    }
    DLog(@"param=%@",dic);
    
    [_manager.requestSerializer setTimeoutInterval:10];
    [_manager POST:url parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        id result=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        DLog(@"data=%@",result);

        ErrorEntity *error;
        NSInteger code=[result[@"result"] integerValue];
        if (code==0) {
            error=[ErrorEntity errorInfoWithCode:0 message:@""];
        }else if (code==107){
            error=[ErrorEntity errorInfoWithCode:code message:@"已经收藏"];
        }else if (code==108){
            error=[ErrorEntity errorInfoWithCode:code message:@"没有收藏"];
        }else{
            error=[ErrorEntity errorInfoWithCode:code message:result[@"error"]];
        }
        if (error.code==0) {
            completion(result[@"data"],error);
        }else{
            completion(nil,[ErrorEntity errorInfoWithCode:error.code message:error.message]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil,[ErrorEntity errorInfoWithCode:error.code message:@"网络连接失败，请重试"]);
    }];
}
+(NSDictionary*)getBaseParams{

    return @{@"userid":@"123"};
}
+(void)uploadImage:(UIImage *)image progress:(void (^)(CGFloat))progress complete:(void (^)(ErrorEntity *, NSString *,NSString *))complete{
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 20;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSString * path =@"";
    
    [manager POST:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData * data =UIImageJPEGRepresentation(image, 1);
        
        if (data.length>IMAGE_SIZE_MAX) {
            CGSize imageSize=image.size;
            
            if (imageSize.height>IMAGE_SIZE_MAX_H_W||imageSize.width>IMAGE_SIZE_MAX_H_W) {
                if (imageSize.height>imageSize.width) {//竖图
                    imageSize.width=imageSize.width*IMAGE_SIZE_MAX_H_W/imageSize.height;
                    imageSize.height=IMAGE_SIZE_MAX_H_W;
                }else{//横图或方图
                    imageSize.height=imageSize.height*IMAGE_SIZE_MAX_H_W/imageSize.width;
                    imageSize.width=IMAGE_SIZE_MAX_H_W;
                }
            }
            UIImage *upimage=[ApplicationUtils scaleFromImage:image toSize:imageSize];
            data = UIImageJPEGRepresentation(upimage, 1);
            CGFloat bei=1;
            while (data.length>IMAGE_SIZE_MAX&&bei>=0) {
                data=UIImageJPEGRepresentation(upimage, bei);
                DLog(@"bei=====%f",bei);
                DLog(@"test=====%ld",data.length);
                bei-=0.01;
            }
        }
        NSString * fileName = [NSString stringWithFormat:@"%@.png",[ApplicationUtils getCurrentTime]];
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"result"] integerValue]==0) {
            complete([ErrorEntity errorInfoWithCode: [result[@"result"] integerValue]message:@""],result[@"imageurl"],[NSString stringWithFormat:@"%ld",[result[@"imageid"] integerValue]]);
        }else{
            complete([ErrorEntity errorInfoWithCode:[result[@"result"] integerValue] message:result[@"error"]],@"",@"");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        complete([ErrorEntity errorInfoWithCode:error.code message:error.localizedDescription],nil,nil);
    }];
}

/**单位：k/s*/
-(void)getNetSpeedComplete:(void (^)(CGFloat ,CGFloat))complete{

    _complete=complete;
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
}
-(void)timeChange{

    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        _complete(0,0);
    }
    
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        
        if (ifa->ifa_data == 0)
            continue;
        
        /* Not a loopback device. */
        if (strncmp(ifa->ifa_name, "lo", 2))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
        }
    }
    freeifaddrs(ifa_list);
    if (_lastiBytes!=0) {
        _complete((iBytes-_lastiBytes)/1024.0f, (oBytes-_lastoBytes)/1024.0f);
    }
    _lastiBytes=iBytes;
    _lastoBytes=oBytes;
}
@end
