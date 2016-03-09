//
//  DemoViewController.m
//  Medicine_doctor
//
//  Created by 董力祯 on 16/3/8.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "DemoViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"demo";

    _list=@[@"即时通讯",@"二维码"];
    _viewControllers=@[@"",@""];
    
    _mainTable=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREAM_WIDTH, MAIN_SCREAM_HEIGHT) style:UITableViewStylePlain];
    _mainTable.dataSource=self;
    _mainTable.delegate=self;
    _mainTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_mainTable];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _list.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@""];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text=[_list objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UIViewController *vc=[[NSClassFromString([_viewControllers objectAtIndex:indexPath.row]) alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
