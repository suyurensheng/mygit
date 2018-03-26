//
//  ImageCheckItem.m
//  ycmanager
//
//  Created by 董力祯 on 2017/8/3.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "ImageCheckItem.h"
#import "AlbumUtils.h"
@interface ImageCheckItem(){

    NSString *_imageUrl;
    PHAsset *_asset;
    
    CGSize _orignSize;
    
    CGSize _lastSize;
    CGFloat _lastLeft;
    CGFloat _lastTop;
    CGPoint _lastPoint;
}

@end
@implementation ImageCheckItem

-(id)initWithTarget:(id)target{
    self=[[[NSBundle mainBundle] loadNibNamed:@"ImageCheckItem" owner:self options:nil] lastObject];
    if (self) {
        _target=target;
        
        /**双击*/
        UITapGestureRecognizer *tap_two=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap)];
        tap_two.numberOfTapsRequired=2;
        [_showImage addGestureRecognizer:tap_two];
        
        /**单击*/
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        tap.numberOfTapsRequired=1;
        [_showImage addGestureRecognizer:tap];
        [tap requireGestureRecognizerToFail:tap_two];

        /**捏合*/
        UIPinchGestureRecognizer *pinch=[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
        [_showImage addGestureRecognizer:pinch];
    }
    return self;
}
-(void)tap{

    if (_target&&[_target respondsToSelector:@selector(imageCheckItemDidClick:)]) {
        [_target imageCheckItemDidClick:self];
    }
}
-(void)doubleTap{

    CGSize screensize=[UIScreen mainScreen].bounds.size;

    if (_orignSize.width==_weight.constant) {
        
        _weight.constant=_orignSize.width*2;
        _height.constant=_orignSize.height*2;
        CGFloat x=(screensize.width-_weight.constant)/2;
        if (x<0) {
            _left.constant=_right.constant=0;
            x=-x;
        }else{
            _left.constant=_right.constant=x;
            x=0;
        }
        CGFloat y=(screensize.height-_height.constant)/2;
        if (y<0) {
            _top.constant=_bottom.constant=0;
            y=-y;
        }else{
            _top.constant=_bottom.constant=y;
            y=0;
        }
        [_scroller setContentOffset:CGPointMake(x,y) animated:NO];
    }else{
        _height.constant=_orignSize.height;
        _weight.constant=_orignSize.width;
        
        _left.constant=_right.constant=(screensize.width-_orignSize.width)/2;
        _top.constant=_bottom.constant=(screensize.height-_orignSize.height)/2;
    }
}
-(void)pinch:(UIPinchGestureRecognizer*)pinch{

    CGSize screensize=[UIScreen mainScreen].bounds.size;
    switch (pinch.state) {
        case UIGestureRecognizerStateBegan:{
            _lastSize=CGSizeMake(_weight.constant, _height.constant);
            
            _lastLeft=_left.constant;
            _lastTop=_top.constant;
            
            _lastPoint=_scroller.contentOffset;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            
            _weight.constant=_lastSize.width*pinch.scale;
            _height.constant=_lastSize.height*pinch.scale;
            
            CGFloat x=(screensize.width-_weight.constant)/2;
            if (x<0) {
                _left.constant=_right.constant=0;
            }else{
                _left.constant=_right.constant=x;
            }
            CGFloat y=(screensize.height-_height.constant)/2;
            if (y<0) {
                _top.constant=_bottom.constant=0;
            }else{
                _top.constant=_bottom.constant=y;
            }
            if (_left.constant==0) {
                x=(_lastPoint.x+screensize.width/2)*pinch.scale-screensize.width/2;
                if (x<0) {
                    x=0;
                }else{
                    if (x+screensize.width>_weight.constant) {
                        x=_weight.constant-screensize.width;
                    }
                }
            }else{
                x=0;
            }
            if (_top.constant==0) {
                y=(_lastPoint.y+screensize.height/2)*pinch.scale-screensize.height/2;
                if (y<0) {
                    y=0;
                }else{
                    if (y+screensize.height>_height.constant) {
                        y=_height.constant-screensize.height;
                    }
                }
            }else{
                y=0;
            }
            [_scroller setContentOffset:CGPointMake(x,y) animated:NO];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            if (_weight.constant<_orignSize.width) {
                [UIView animateWithDuration:0.3 animations:^{
                    _height.constant=_orignSize.height;
                    _weight.constant=_orignSize.width;
                    
                    _left.constant=_right.constant=(screensize.width-_orignSize.width)/2;
                    _top.constant=_bottom.constant=(screensize.height-_orignSize.height)/2;
                }];
            }
        }
            break;
        default:
            break;
    }
}
-(void)showWithData:(id)data{

    if ([data isKindOfClass:[UIImage class]]) {
        [self dealWithImage:data];
    }else if([data isKindOfClass:[NSString class]]){
        _imageUrl=data;
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:_imageUrl] options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (finished&&[imageURL.absoluteString isEqualToString:_imageUrl]&&image) {
                [self dealWithImage:image];
            }
        }];
    }else if ([data isKindOfClass:[PHAsset class]]){
        _asset=data;
        [AlbumUtils getImageWithSource:_asset size:CGSizeMake(_asset.pixelWidth, _asset.pixelHeight) progress:^(double progress, NSString *progressid) {
        } complete:^(BOOL isOk, PHAsset *asset, UIImage *image) {
            if (isOk&&[_asset.localIdentifier isEqualToString:asset.localIdentifier]) {
                [self dealWithImage:image];
            }
        }];
    }
}
-(void)dealWithImage:(UIImage*)image{

    CGSize size=image.size;
    CGSize screensize=[UIScreen mainScreen].bounds.size;
    
    if (size.height/size.width>screensize.height/screensize.width) {
        size.width=size.width*screensize.height/size.height;
        size.height=screensize.height;
    }else{
        size.height=size.height*screensize.width/size.width;
        size.width=screensize.width;
    }
    _orignSize=size;

    _height.constant=size.height;
    _weight.constant=size.width;
    
    _left.constant=_right.constant=(screensize.width-size.width)/2;
    _top.constant=_bottom.constant=(screensize.height-size.height)/2;
    
    _showImage.image=image;
}

@end









