//
//  DataVC.h
//  DLZDemo
//
//  Created by 董力祯 on 2018/1/29.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "BaseVC.h"

@interface DataVC : BaseVC

@property (weak, nonatomic) IBOutlet UITableView *list;
- (IBAction)newData:(id)sender;
- (IBAction)deleteData:(id)sender;
@end
