//
//  XuanranViewController.h
//  DLZDemo
//
//  Created by 董力祯 on 2017/5/8.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "BaseVC.h"

@interface XuanranViewController : BaseVC

@property (weak, nonatomic) IBOutlet UIView *videoView;
- (IBAction)start:(id)sender;
- (IBAction)play:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView *showImage;
@end
