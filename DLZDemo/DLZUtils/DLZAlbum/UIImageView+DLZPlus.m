//
//  UIImageView+DLZPlus.m
//  mtll
//
//  Created by 董力祯 on 15/7/22.
//  Copyright (c) 2015年 董力祯. All rights reserved.
//

#import "UIImageView+DLZPlus.h"
#import<objc/runtime.h>
#import "AlbumUtils.h"

@implementation UIImageView (DLZPlus)


/**调用第三方的sdwebimage加载图片*/
-(void)setImageWithImage_URL:(NSString*)url{

//    self.backgroundColor=XRGB(ea, f4, fa);
    [self sd_setImageWithURL:[NSURL URLWithString:url]];
}

/**调用第三方的sdwebimage加载图片，可选默认图*/
-(void)setImageWithImage_URL:(NSString*)url andPlcaeHoldImage:(UIImage*)holdImage{

    [self setImageWithImage_URL:url andPlcaeHoldImage:holdImage withOptional:SDWebImageRefreshCached];
}

/**调用第三方的sdwebimage加载图片，可选默认图和加载选项*/
-(void)setImageWithImage_URL:(NSString *)url andPlcaeHoldImage:(UIImage *)holdImage withOptional:(SDWebImageOptions)option{

    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:holdImage options:option];
}
static const char *kFriendsPropertyKey = "kFriendsPropertyKey";
- (PHAsset *)source{
    return objc_getAssociatedObject(self, kFriendsPropertyKey);
}

-(void)setSource:(PHAsset *)source{
    objc_setAssociatedObject(self,
                             kFriendsPropertyKey,
                             source,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setImageWithSource:(PHAsset *)source{
    
    [self setImageWithSource:source size:CGSizeMake(source.pixelWidth, source.pixelHeight)];
}
-(void)setImageWithSource:(PHAsset*)source size:(CGSize)size{
    
    self.source=source;
//    NSLog(@"source_size=%@  id=%@",NSStringFromCGSize(CGSizeMake(source.pixelWidth, source.pixelHeight)),source.localIdentifier);
    
    [AlbumUtils getImageWithSource:source size:size progress:^(double progress,NSString*progressid) {
//        NSLog(@"progress=%f",progress);
    } complete:^(BOOL isOk, PHAsset *asset, UIImage *image) {
        if (isOk) {
            if ([self.source.localIdentifier isEqualToString:source.localIdentifier]) {
                self.image=image;
//                NSLog(@"image_size=%@",NSStringFromCGSize(image.size));
            }
        }else{
            NSLog(@"获取失败");
        }
    }];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//        // 同步获得图片, 只会返回1张图片
//        options.synchronous = YES;
//        options.networkAccessAllowed=YES;
//        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
//            NSLog(@"progress=%f",progress);
//        };
//        [[PHImageManager defaultManager] requestImageForAsset:source targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (result) {
//                    if ([self.source.localIdentifier isEqualToString:source.localIdentifier]) {
//                        self.image=result;
//                        NSLog(@"image_size=%@",NSStringFromCGSize(result.size));
//                    }
//                }
//            });
//        }];
//    });
}
@end
