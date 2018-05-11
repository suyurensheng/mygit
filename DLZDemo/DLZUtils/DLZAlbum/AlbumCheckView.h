//
//  AlbumCheckView.h
//  DLZDemo
//
//  Created by 董力祯 on 2017/12/20.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumCheckView;
@protocol AlbumCheckViewDelegate <NSObject>

@optional
-(void)albumCheckView:(AlbumCheckView*)checkView didClickIndex:(NSInteger)index;
-(void)albumCheckView:(AlbumCheckView*)checkView didComplete:(NSArray*)images;
@end

typedef enum {
    AlbumCheckViewStyleScan,
    AlbumCheckViewStyleCheck,
}AlbumCheckViewStyle;
@interface AlbumCheckView : UIView

@property (weak, nonatomic) IBOutlet UIScrollView *mainScroller;

-(void)showWithSource:(NSArray*)source customIndex:(NSInteger)index target:(id)target checkStyle:(AlbumCheckViewStyle)checkStyle selSource:(NSArray*)selSource;

-(id)initWithSuperView:(UIView*)showView;
@property(nonatomic,assign)AlbumCheckViewStyle checkStyle;


@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *selIcon;
@property (weak, nonatomic) IBOutlet UIButton *footView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;
@end
