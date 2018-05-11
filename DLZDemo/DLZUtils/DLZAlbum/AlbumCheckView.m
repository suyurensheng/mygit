//
//  AlbumCheckView.m
//  DLZDemo
//
//  Created by 董力祯 on 2017/12/20.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "AlbumCheckView.h"
#import "ImageCheckItem.h"
#import "AlbumUtils.h"

#define Screen_width [UIScreen mainScreen].bounds.size.width

#define Screen_height [UIScreen mainScreen].bounds.size.height

@interface AlbumCheckView()<UIScrollViewDelegate,ImageCheckItemDelegate>{
    
    NSArray *_source;
    NSInteger _selIndex;
    
    UIView *_showView;

    id _target;
    NSMutableArray *_selSource;
}

@end

@implementation AlbumCheckView

-(id)initWithSuperView:(UIView *)showView{
    self=[[AlbumCheckView alloc] init];
    if (self) {
        _showView=showView;
        self.frame=showView.bounds;
    }
    return self;
}
-(id)init{
    self=[[[NSBundle mainBundle] loadNibNamed:@"AlbumCheckView" owner:self options:nil] lastObject];
    if (self) {
        self.frame=[UIScreen mainScreen].bounds;
        
        [_selIcon setImage:[UIImage imageNamed:@"album_nor"] forState:UIControlStateNormal];
        [_selIcon setImage:[UIImage imageNamed:@"album_selected"] forState:UIControlStateSelected];
    }
    return self;
}

-(void)showWithSource:(NSArray *)source customIndex:(NSInteger)index target:(id)target checkStyle:(AlbumCheckViewStyle)checkStyle selSource:(NSArray *)selSource{
    
    _source=source;
    _selIndex=index<0?0:index>source.count-1?source.count-1:index;
    _target=target;
    _checkStyle=checkStyle;
    _selSource=[NSMutableArray arrayWithArray:selSource];
    
    NSInteger num=source.count>3?3:source.count;
    for (NSInteger i=0; i<num; i++) {
        ImageCheckItem *item=[_mainScroller viewWithTag:100+i];
        if (!item) {
            item=[[ImageCheckItem alloc]initWithTarget:self];
            item.frame=CGRectMake(Screen_width*i, 0, Screen_width, Screen_height);
            item.tag=100+i;
            [_mainScroller addSubview:item];
        }
    }
    _mainScroller.contentSize=CGSizeMake(Screen_width*num, 0);
    if (source.count>3) {
        [self showIndex:_selIndex];
    }else{
        for (NSInteger i=0; i<_source.count; i++) {
            ImageCheckItem *item=[_mainScroller viewWithTag:100+i];
            [item showWithData:[_source objectAtIndex:i]];
        }
        [_mainScroller setContentOffset:CGPointMake(Screen_width*_selIndex, 0) animated:NO];
    }
    _selIcon.selected=[_selSource containsObject:@(_selIndex)];

    [UIView  animateWithDuration:0.5 animations:^{
        if (_showView) {
            [_showView addSubview:self];
        }else{
            [[UIApplication sharedApplication].keyWindow addSubview:self];
        }
    }];
}

-(void)showIndex:(NSInteger)index{
    
    if (index==0) {
        for (NSInteger i=0; i<3; i++) {
            ImageCheckItem *item=[_mainScroller viewWithTag:100+i];
            [item showWithData:[_source objectAtIndex:i]];
        }
    }else if (index==_source.count-1){
        for (NSInteger i=0; i<3; i++) {
            ImageCheckItem *item=[_mainScroller viewWithTag:100+i];
            [item showWithData:[_source objectAtIndex:_source.count-3+i]];
        }
        [_mainScroller setContentOffset:CGPointMake(Screen_width*2, 0) animated:NO];
    }else{
        for (NSInteger i=0; i<3; i++) {
            ImageCheckItem *item=[_mainScroller viewWithTag:100+i];
            [item showWithData:[_source objectAtIndex:index-1+i]];
        }
        [_mainScroller setContentOffset:CGPointMake(Screen_width, 0) animated:NO];
    }
}
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//
//    if (!decelerate) {
//        NSLog(@"1");
//        NSInteger index=scrollView.contentOffset.x/Screen_width;
//        if (index==0) {//左滑
//            if (_selIndex>0) {
//                _selIndex--;
//                if (_selIndex>0) {
//                    [self toLeft];
//                }
//            }
//        }else if(index==2){//右滑
//            if (_selIndex<_source.count-1) {
//                _selIndex++;
//                if (_selIndex<_source.count+1) {
//                    [self toRight];
//                }
//            }
//        }else{
//            if (_selIndex==0) {
//                _selIndex++;
//            }else if(_selIndex==_source.count-1){
//                _selIndex--;
//            }
//        }
//    }
//}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSInteger index=scrollView.contentOffset.x/Screen_width;
    if (index==0) {//左滑
        if (_selIndex>0) {
            _selIndex--;
            if (_selIndex>0) {
                [self toLeft];
            }
        }
    }else if(index==2){//右滑
        if (_selIndex<_source.count-1) {
            _selIndex++;
            if (_selIndex<_source.count-1) {
                [self toRight];
            }
        }
    }else{
        if (_selIndex==0) {
            _selIndex++;
        }else if(_selIndex==_source.count-1){
            _selIndex--;
        }
    }
    _selIcon.selected=[_selSource containsObject:@(_selIndex)];
}
-(void)toLeft{
    
    ImageCheckItem *item0=[_mainScroller viewWithTag:102];
    for (NSInteger i=1; i>=0; i--) {
        ImageCheckItem *item=[_mainScroller viewWithTag:100+i];
        CGRect frame=item.frame;
        frame.origin.x=Screen_width*(i+1);
        item.frame=frame;
        item.tag+=1;
    }
    CGRect frame=item0.frame;
    frame.origin.x=0;
    item0.frame=frame;
    item0.tag=100;
    [item0 showWithData:[_source objectAtIndex:_selIndex-1]];
    [_mainScroller setContentOffset:CGPointMake(Screen_width, 0) animated:NO];
}
-(void)toRight{
    
    ImageCheckItem *item2=[_mainScroller viewWithTag:100];
    for (NSInteger i=1; i<3; i++) {
        ImageCheckItem *item=[_mainScroller viewWithTag:100+i];
        CGRect frame=item.frame;
        frame.origin.x=Screen_width*(i-1);
        item.frame=frame;
        item.tag-=1;
    }
    CGRect frame=item2.frame;
    frame.origin.x=Screen_width*2;
    item2.frame=frame;
    item2.tag=102;
    [item2 showWithData:[_source objectAtIndex:_selIndex+1]];
    [_mainScroller setContentOffset:CGPointMake(Screen_width, 0) animated:NO];
}
-(void)imageCheckItemDidClick:(ImageCheckItem *)item{
    [UIView animateWithDuration:0.5 animations:^{
        if (_top.constant==0) {
            _top.constant=-_topView.frame.size.height;
            _bottom.constant=-_footView.frame.size.height;
        }else{
            _top.constant=0;
            _bottom.constant=0;
        }
    }];
}
- (IBAction)backAction:(id)sender {
    [UIView  animateWithDuration:0.25 animations:^{
        [self removeFromSuperview];
    }];
}
- (IBAction)selAction:(id)sender {
    
    _selIcon.selected=!_selIcon.selected;
    
    NSNumber *index=@(_selIndex);
    if ([_selSource containsObject:index]) {
        [_selSource removeObject:index];
    }else{
        [_selSource addObject:index];
    }
    if (_target&&[_target respondsToSelector:@selector(albumCheckView:didClickIndex:)]) {
        [_target albumCheckView:self didClickIndex:_selIndex];
    }
}
- (IBAction)complete:(id)sender {
    
    if (_target&&[_target respondsToSelector:@selector(albumCheckView:didComplete:)]) {
        NSMutableArray *photos=[[NSMutableArray alloc]init];
        for (NSInteger i=0; i<_selSource.count; i++) {
            [photos addObject:[_source objectAtIndex:[[_selSource objectAtIndex:i] integerValue]]];
        }
        [[AlbumUtils sharedAlbumUtils] getImagesData:photos progress:^(double progress) {
            NSLog(@"f=%f",progress);
        } complete:^(NSArray *images, ErrorEntity *error) {
            if (error.code==0) {
                [_target albumCheckView:self didComplete:images];
                NSLog(@"处理完成");
            }else{
                NSLog(@"处理失败");
            }
            [self backAction:nil];
        }];
    }else{
        [self backAction:nil];
    }
}

@end
