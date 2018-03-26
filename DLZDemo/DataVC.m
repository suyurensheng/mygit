//
//  DataVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/1/29.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "DataVC.h"
#import "SqliteManager.h"
#import "ApplicationUtils.h"
@interface DataVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    NSArray *_source;
    NSDictionary *_seldIc;
}

@end

@implementation DataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creat];
    [self getData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _source.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cellid"];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellid"];
    }
    NSDictionary *dic=[_source objectAtIndex:indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%@      %@      %@         %@",dic[@"id"],dic[@"name"],dic[@"age"],dic[@"cityname"]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _seldIc=[_source objectAtIndex:indexPath.row];
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
-(void)getData{
    
    [[SqliteManager sharedSqlite] getInfoDb:@"user" dbkey:@"address" relateDb:@"city" relatedbkey:@"cityid" complete:^(NSArray *list) {
        NSLog(@"data=%@",list);
        _source=list;
        [_list reloadData];
    }];
}
-(void)creat{
    [[SqliteManager sharedSqlite] creatTableWithName:@"user" primaryKey:@"id" otherKeys:@{@"name":@"text",@"age":@"integer",@"head":@"text",@"address":@"integer"} complete:^(BOOL isOk) {
    }];
    [[SqliteManager sharedSqlite] creatTableWithName:@"city" primaryKey:@"cityid" otherKeys:@{@"cityname":@"text"} complete:^(BOOL isOk) {
        NSArray *citys=@[@"北京",@"山东",@"四川",@"山西",@"黑龙江"];
        for (NSInteger i=1; i<=citys.count; i++) {
            [[SqliteManager sharedSqlite] writeInfo:@{@"cityid":[NSString stringWithFormat:@"%ld",i],@"cityname":[citys objectAtIndex:i-1]} toDbName:@"city" complete:^(BOOL result) {
            }];
        }
    }];
}
-(void)update{
    [[SqliteManager sharedSqlite] updateDb:@"user" option:@{@"id":@"4"} withNewInfo:@{@"age":@"17",@"head":@"http://csdnimg.cn/pubfooter/images/csdn_cs_qr.png",@"name":@"json"} complete:^(BOOL result) {
        NSLog(result?@"修改成功":@"修改失败");
    }];
}
- (IBAction)newData:(id)sender {
    
    NSString *name=[ApplicationUtils getRandomString:6];
    NSString *age=[NSString stringWithFormat:@"%u",arc4random()%100];
    NSString *address=[NSString stringWithFormat:@"%u",arc4random()%5+1];
    
    [[SqliteManager sharedSqlite] writeInfo:@{@"name":name,@"age":age,@"head":@"http://csdnimg.cn/pubfooter/images/csdn_cs_qr.png",@"address":address} toDbName:@"user" complete:^(BOOL result) {
        NSLog(result?@"插入数据成功":@"插入数据失败");
        [self getData];
    }];
}

- (IBAction)deleteData:(id)sender {
    if (_seldIc) {
        [[SqliteManager sharedSqlite] deleteDb:@"user" option:@{@"id":_seldIc[@"id"]} complete:^(BOOL result) {
            NSLog(result?@"删除成功":@"删除失败");
            if (result) {
                _seldIc=nil;
            }
            [self getData];
        }];
    }
}
@end
