//
//  DataUtils.h
//  Doctor_Square
//
//  Created by 董力祯 on 16/5/5.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ErrorEntity.h"
typedef enum {
    ImageGetSourceCamera,
    ImageGetSourceAlbum,
}ImageGetSource;

@protocol DataUtilsDelegate <NSObject>

@optional
-(void)imageGetViewDidFinishedWithImage:(UIImage*)image source:(ImageGetSource)source;
-(void)imageGetViewDidCancel;
-(void)imageGetViewDidFail:(ErrorEntity*)error;
@end


@interface DataUtils : NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{

    ImageGetSource _source;
}

+ (id)sharedDataUtils;


/**写入缓存*/
+(void)writeData:(id)data WithName:(NSString*)name;

/**读缓存*/
+(id)readDataWithName:(NSString*)name;

/**获取相册图片*/
+(void)getAlbumImages:(void(^)(NSArray *requestArray,ErrorEntity *error))back;

/**获取相册所有图片*/
+(void)getAlbumDatas:(void(^)(NSArray *images))complete;


-(void)loadImageGetViewWithTarget:(id)target source:(ImageGetSource)source;

@property(nonatomic,assign)id target;
@end