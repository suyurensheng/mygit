//
//  UIImageView+DLZPlus.h
//  mtll
//
//  Created by 董力祯 on 15/7/22.
//  Copyright (c) 2015年 董力祯. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

typedef enum {
    albumGetStyleFull,//原图
    albumGetStylethum,//缩略图
}albumGetStyle;

@interface UIImageView (DLZPlus)

/**调用第三方的sdwebimage加载图片*/
-(void)setImageWithImage_URL:(NSString*)url;

/**调用第三方的sdwebimage加载图片，可选默认图*/
-(void)setImageWithImage_URL:(NSString*)url andPlcaeHoldImage:(UIImage*)holdImage;


/**加载本地图片*/
-(void)setImageWithSource:(PHAsset*)source;
-(void)setImageWithSource:(PHAsset*)source size:(CGSize)size;

@property(nonatomic,strong)PHAsset *source;
@end
