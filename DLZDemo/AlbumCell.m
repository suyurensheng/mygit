//
//  AlbumCell.m
//  DLZDemo
//
//  Created by 董力祯 on 2017/12/7.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "AlbumCell.h"

@implementation AlbumCell

-(void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [_icon addGestureRecognizer:tap];
}
-(void)setSelect:(BOOL)select{
    if (select) {
        _selIcon.image=[UIImage imageNamed:@"album_selected"];
    }else{
        _selIcon.image=[UIImage imageNamed:@"album_nor"];
    }
}
-(void)tapClick{
    NSLog(@"点击");
    if (_target&&[_target respondsToSelector:@selector(albumCell:didClick:)]) {
        UICollectionView *collection=(UICollectionView *)[self superview];
        [_target albumCell:self didClick:[collection indexPathForCell:self]];
    }
}
- (IBAction)choose:(id)sender {
    NSLog(@"选中");
    if (_target&&[_target respondsToSelector:@selector(albumCell:didChoose:)]) {
        UICollectionView *collection=(UICollectionView *)[self superview];
        [_target albumCell:self didChoose:[collection indexPathForCell:self]];
    }
}
@end
