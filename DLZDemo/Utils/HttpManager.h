//
//  NetManager.h
//  AllStar
//
//  Created by 董力祯 on 16/1/11.
//  Copyright © 2016年 youmingxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ErrorEntity.h"
#import <AFNetworking.h>


@interface HttpManager : NSObject

@property (nonatomic,strong)AFHTTPSessionManager *manager;

@property(nonatomic,strong)NSURLSessionDataTask *task;

+ (instancetype)sharedHttpManager;

/**通用接口*/
-(void)postWithURLString:(NSString*)urlString param:(NSDictionary*)param completion:(void(^)(id responseObject,ErrorEntity *error))completion;

/**上传图片到服务器*/
+(void)uploadImage:(UIImage*)image progress:(void(^)(CGFloat precent))progress complete:(void(^)(ErrorEntity *error,NSString *imageURL ,NSString *imageid))complete;

/**获取基础参数*/
+(NSDictionary*)getBaseParams;

/**实时监控手机网络速度 (kb/s)*/
-(void)getNetSpeedComplete:(void(^)(CGFloat speedin , CGFloat speedout))complete;
@end
