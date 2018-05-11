//
//  AlbumVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2017/12/19.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "AlbumVC.h"
#import "DLZUtils/DLZAlbum/AlbumUtils.h"
#import <DLZWaterFallLayout.h>
#import "DLZUtils/DLZAlbum/AlbumCell.h"
#import "DLZUtils/DLZAlbum/AlbumCheckView.h"

@interface AlbumVC ()<UICollectionViewDelegate,UICollectionViewDataSource,DLZWaterFallLayoutDelegate,AlbumCellDelegate,AlbumCheckViewDelegate>{
    
    AlbumEntity *_album;
    
    NSMutableArray *_selectArray;
    NSArray *_oriSelectArray;
    
    id _target;
}

@end

@implementation AlbumVC
-(id)initWithTarget:(id)target{
    self=[[[NSBundle mainBundle] loadNibNamed:@"AlbumVC" owner:self options:nil] lastObject];
    if (self) {
        _target=target;
        _max_num=9;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectArray=[[NSMutableArray alloc]init];
    
    DLZWaterFallLayout *layout=[[DLZWaterFallLayout alloc]init];
    layout.columnCount=4;
    layout.rowSpacing=2;
    layout.columnSpacing=2;
    layout.sectionInset=UIEdgeInsetsMake(-2, 0, 0, 0);
    layout.delegate=self;
    
    _collection.collectionViewLayout=layout;
    
    [_collection registerNib:[UINib nibWithNibName:@"AlbumCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"AlbumCell"];
    
    [[AlbumUtils sharedAlbumUtils] getAlbumDatas:^(NSArray *albums,ErrorEntity *error) {
        if (error.code==0) {
            _album=[albums firstObject];
            [_collection reloadData];
        }
    }];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _album.assets.count;
}
-(__kindof UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AlbumCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    cell.target=self;
    
    PHAsset *asset=[_album.assets objectAtIndex:indexPath.row];
    CGFloat weight=(MAIN_SCREAM_WIDTH-6)/4;
    CGFloat height=weight*asset.pixelHeight/asset.pixelWidth;
    if (MAIN_SCREAM_HEIGHT>700) {
        [cell.icon setImageWithSource:asset size:CGSizeMake(weight*3, height*3)];
    }else{
        [cell.icon setImageWithSource:asset size:CGSizeMake(weight*2, height*2)];
    }
    [cell setSelect:[_selectArray containsObject:@(indexPath.row)]];
    return cell;
}
-(CGSize)dlzCollectionViewLayout:(DLZWaterFallLayout *)dlzLayout atIndexPath:(NSIndexPath *)indexPath{
    
    //    PHAsset *asset=[_album.assets objectAtIndex:indexPath.row];
    //    return CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    return CGSizeMake(1, 1);
}
-(void)albumCell:(AlbumCell *)cell didChoose:(NSIndexPath *)indexPath{
    
    NSNumber *index=@(indexPath.row);
    if ([_selectArray containsObject:index]) {
        [_selectArray removeObject:index];
        [cell setSelect:NO];
    }else{
        if (_selectArray.count<_max_num) {
            [_selectArray addObject:index];
            [cell setSelect:YES];
        }
    }
}
-(void)albumCell:(AlbumCell *)cell didClick:(NSIndexPath *)indexPath{
    
    AlbumCheckView *view=[[AlbumCheckView alloc]initWithSuperView:self.navigationController.view];
    [view showWithSource:_album.assets customIndex:indexPath.row target:self checkStyle:AlbumCheckViewStyleScan selSource:_selectArray];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)complete:(id)sender {
    
    NSMutableArray *photos=[[NSMutableArray alloc]init];
    for (NSInteger i=0; i<_selectArray.count; i++) {
        [photos addObject:[_album.assets objectAtIndex:[[_selectArray objectAtIndex:i] integerValue]]];
    }
    [[AlbumUtils sharedAlbumUtils] getImagesData:photos progress:^(double progress) {
        NSLog(@"f=%f",progress);
    } complete:^(NSArray *images, ErrorEntity *error) {
        if (error.code==0) {
            if (_target&&[_target respondsToSelector:@selector(albumVC:didComplete:)]) {
                [_target albumVC:self didComplete:images];
            }
            NSLog(@"处理完成");
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NSLog(@"处理失败");
        }
    }];
}
- (IBAction)check:(id)sender {
    if (_selectArray.count) {
        NSMutableArray *photos=[[NSMutableArray alloc]init];
        NSMutableArray *selArray=[[NSMutableArray alloc]init];
        for (NSInteger i=0; i<_selectArray.count; i++) {
            [photos addObject:[_album.assets objectAtIndex:[[_selectArray objectAtIndex:i] integerValue]]];
            [selArray addObject:@(i)];
        }
        _oriSelectArray=[NSArray arrayWithArray:_selectArray];
        
        AlbumCheckView *view=[[AlbumCheckView alloc]initWithSuperView:self.navigationController.view];
        [view showWithSource:photos customIndex:0  target:self checkStyle:AlbumCheckViewStyleCheck selSource:selArray];
    }
}
-(void)albumCheckView:(AlbumCheckView *)checkView didClickIndex:(NSInteger)index{
    
    NSNumber *indexNum;
    switch (checkView.checkStyle) {
        case AlbumCheckViewStyleScan:{
                
            indexNum=@(index);
        }
            break;
        case AlbumCheckViewStyleCheck:{
            
            indexNum=[_oriSelectArray objectAtIndex:index];
        }
            break;
        default:
            break;
    }
    AlbumCell *cell=(AlbumCell*)[_collection cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[indexNum integerValue] inSection:0]];
    if ([_selectArray containsObject:indexNum]) {
        [_selectArray removeObject:indexNum];
        [cell setSelect:NO];
    }else{
        if (_selectArray.count<_max_num) {
            [_selectArray addObject:indexNum];
            [cell setSelect:YES];
        }
    }
}
-(void)albumCheckView:(AlbumCheckView *)checkView didComplete:(NSArray *)images{
    
    if (_target&&[_target respondsToSelector:@selector(albumVC:didComplete:)]) {
        [_target albumVC:self didComplete:images];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
