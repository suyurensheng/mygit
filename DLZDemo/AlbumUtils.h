//
//  AlbumUtils.h
//  DLZDemo
//
//  Created by 董力祯 on 2017/11/16.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface AlbumEntity :NSObject
@property(nonatomic,strong)NSString *title;
@property(nonatomic,assign)NSInteger count;
// 相簿中的所有PHAsset对象
@property(nonatomic,strong)NSArray *assets;
@end

@interface AlbumUtils : NSObject

+(id)sharedAlbumUtils;
-(void)getAlbumDatas:(void(^)(NSArray *albums,ErrorEntity *error))complete;

-(void)getImagesData:(NSArray*)source progress:(void(^)(double progress))speed  complete:(void(^)(NSArray *images,ErrorEntity *error))complete;

+(void)getImageWithSource:(PHAsset*)source size:(CGSize)size progress:(void(^)(double progress,NSString*progressid))speed complete:(void(^)(BOOL isOk,PHAsset *asset,UIImage *image))complete;

@end
