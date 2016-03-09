//
//  DemoViewController.h
//  Medicine_doctor
//
//  Created by 董力祯 on 16/3/8.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "BaseViewController.h"

@interface DemoViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>{

    UITableView *_mainTable;
    NSArray *_list;
    NSArray *_viewControllers;
}

@end
