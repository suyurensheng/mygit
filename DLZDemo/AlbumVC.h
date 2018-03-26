//
//  AlbumVC.h
//  DLZDemo
//
//  Created by 董力祯 on 2017/12/19.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "BaseVC.h"

@class AlbumVC;
@protocol AlbumVCDelegate <NSObject>

@optional
-(void)albumVC:(AlbumVC*)album didComplete:(NSArray*)images;
@end

@interface AlbumVC : BaseVC

@property (weak, nonatomic) IBOutlet UICollectionView *collection;

@property(nonatomic,assign)NSInteger max_num;

-(id)initWithTarget:(id)target;
@end
