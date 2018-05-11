//
//  AlbumUtils.m
//  DLZDemo
//
//  Created by 董力祯 on 2017/11/16.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "AlbumUtils.h"

@implementation AlbumEntity
-(void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key{
}
@end

@implementation AlbumUtils{
    
    void (^_albumBlock)(NSArray *albums,ErrorEntity *error);
    NSMutableArray *_albums;
}

+(id)sharedAlbumUtils{
    
    static AlbumUtils *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared=[[AlbumUtils alloc]init];
    });
    return _shared;
}
-(void)getAlbumDatas:(void (^)(NSArray *,ErrorEntity *))complete{
    // 1.判断相册是否可以打开
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status==PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self getAlbumDatas:^(NSArray *albums, ErrorEntity *error) {
                    complete(albums,error);
                }];
            });
        }];
        return;
    }else if (status == PHAuthorizationStatusRestricted ||status == PHAuthorizationStatusDenied) {
        // 这里便是无访问权限
        complete(nil,[ErrorEntity errorInfoWithCode:999 message:@"没有权限"]);
        return;
    }
    
    _albumBlock=complete;
    if (!_albums) {
        _albums=[[NSMutableArray alloc]init];
    }else{
        [_albums removeAllObjects];
    }
    
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    // 遍历相机胶卷
    [self enumerateAssetsInAssetCollection:cameraRoll];
    
//    // 获得所有智能胶卷
//    PHFetchResult<PHAssetCollection *> *assetCollections1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
//    // 遍历所有的智能胶卷
//    for (PHAssetCollection *assetCollection in assetCollections1) {
//        [self enumerateAssetsInAssetCollection:assetCollection];
//    }
    
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 遍历所有的自定义相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self enumerateAssetsInAssetCollection:assetCollection];
    }
    complete(_albums,[ErrorEntity errorInfoWithCode:0 message:@"获取成功"]);
}
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection{
    
    AlbumEntity *album=[[AlbumEntity alloc]init];
    album.title=[self transformAblumTitle:assetCollection.localizedTitle];
    
    // 获得相簿中的所有PHAsset对象
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    NSMutableArray *assetlist=[[NSMutableArray alloc]init];
    for (NSInteger i=0; i<assets.count; i++) {
        [assetlist addObject:[assets objectAtIndex:i]];
    }
    album.assets=assetlist;
    album.count=assets.count;
    [_albums addObject:album];
    
    NSLog(@"相簿名:%@ 中文：%@  count=%ld", assetCollection.localizedTitle,album.title,album.count);
}
- (NSString *)transformAblumTitle:(NSString *)title{
    
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }else if ([title isEqualToString:@"Panoramas"]) {
        return @"全景照片";
    }else if ([title isEqualToString:@"Time-lapse"]) {
        return @"延时摄影";
    }else if ([title isEqualToString:@"Portrait"]) {
        return @"人物";
    }else if ([title isEqualToString:@"Animated"]) {
        return @"动画";
    }else if ([title isEqualToString:@"Hidden"]) {
        return @"隐藏";
    }
    return title;
}
-(void)getImagesData:(NSArray *)source progress:(void (^)(double))speed complete:(void (^)(NSArray *, ErrorEntity *))complete{
    
    NSMutableArray *backArray=[[NSMutableArray alloc]init];
    NSMutableDictionary *progressList=[[NSMutableDictionary alloc]init];
    for (NSInteger i=0; i<source.count; i++) {
        PHAsset *asset=[source objectAtIndex:i];
        [AlbumUtils getImageWithSource:asset size:CGSizeMake(asset.pixelWidth, asset.pixelHeight) progress:^(double progress,NSString*progressid) {
            if (progressid.length) {
                [progressList setValue:@(progress) forKey:progressid];
                CGFloat f=0.0f;
                NSArray *keys=progressList.allKeys;
                for (NSInteger i=0; i<keys.count; i++) {
                    f+=[[progressList objectForKey:[keys objectAtIndex:i]] doubleValue];
                }
                f/=keys.count;
                speed(f);
            }
        } complete:^(BOOL isOk, PHAsset *asset, UIImage *image) {
            if (isOk) {
                [backArray addObject:image];
                if (backArray.count==source.count) {
                    complete(backArray,[ErrorEntity errorInfoWithCode:0 message:@""]);
                }
            }else{
                complete(nil,[ErrorEntity errorInfoWithCode:9999 message:@"处理失败"]);
            }
        }];
    }
}
+(void)getImageWithSource:(PHAsset *)source size:(CGSize)size progress:(void (^)(double,NSString*))speed complete:(void (^)(BOOL, PHAsset *, UIImage *))complete{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        options.networkAccessAllowed=YES;
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            speed(progress,[NSString stringWithFormat:@"%ld",[info[@"PHImageResultRequestIDKey"] integerValue]]);
        };
        [[PHImageManager defaultManager] requestImageForAsset:source targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            speed(1.0f,nil);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    complete(YES,source,result);
                }else{
                    complete(NO,source,nil);
                }
            });
        }];
    });
}
@end
