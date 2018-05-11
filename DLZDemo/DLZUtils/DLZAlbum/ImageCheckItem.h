//
//  ImageCheckItem.h
//  ycmanager
//
//  Created by 董力祯 on 2017/8/3.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageCheckItem;
@protocol ImageCheckItemDelegate <NSObject>

-(void)imageCheckItemDidClick:(ImageCheckItem*)item;

@end

@interface ImageCheckItem : UIView

-(id)initWithTarget:(id)target;

-(void)showWithData:(id)data;
@property (weak, nonatomic) IBOutlet UIImageView *showImage;

@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property(nonatomic,assign)id target;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *right;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weight;
@end
