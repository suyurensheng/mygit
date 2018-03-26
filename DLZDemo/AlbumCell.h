//
//  AlbumCell.h
//  DLZDemo
//
//  Created by 董力祯 on 2017/12/7.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumCell;
@protocol AlbumCellDelegate <NSObject>

@optional
/**选中*/
-(void)albumCell:(AlbumCell*)cell didChoose:(NSIndexPath*)indexPath;
/**点击*/
-(void)albumCell:(AlbumCell*)cell didClick:(NSIndexPath*)indexPath;
@end

@interface AlbumCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *selIcon;

@property (weak, nonatomic) IBOutlet UIImageView *icon;

-(void)setSelect:(BOOL)select;
@property(nonatomic,assign)id target;
@end
