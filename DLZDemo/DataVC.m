//
//  DataVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/1/29.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "DataVC.h"
#import "DLZUtils/SqliteManager/SqliteManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation DataEntity
-(void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key{
}
-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        _uid=[value integerValue];
    }else{
        [super setValue:value forKey:key];
    }
}
@end

@interface DataVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    NSArray *_source;
    NSArray *_secAarray;
    DataEntity *_seldIc;
}

@end

@implementation DataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    LAContext *context=[[LAContext alloc]init];
    BOOL canuse=[context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    context.localizedFallbackTitle=@"fallback";
    context.localizedCancelTitle=@"取消使用";
    if (canuse) {
        NSLog(@"touchid可用");
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"为什么使用呢？" reply:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    NSLog(@"touchid验证成功");
                    [self creat];
                    [self getData];
                }else{
                    switch (error.code) {
                        case LAErrorUserFallback:{
                            NSLog(@"用户选择输入密码");
                            break;
                        }
                        case LAErrorAuthenticationFailed:{
                            NSLog(@"验证失败");
                            break;
                        }
                        case LAErrorUserCancel:{
                            NSLog(@"用户取消");
                            break;
                        }
                        case LAErrorSystemCancel:{
                            NSLog(@"系统取消");
                            break;
                        }
                            //以下三种情况如果提前检测TouchID是否可用就不会出现
                        case LAErrorPasscodeNotSet:{
                            break;
                        }
                        case LAErrorBiometryNotAvailable:{
                            break;
                        }
                        case LAErrorBiometryNotEnrolled:{
                            break;
                        }
                            
                        default:
                            break;
                    }
                }
            });
        }];
    }else{
        NSLog(@"touchid不可用");
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _source.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[_source objectAtIndex:section] count];
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [_secAarray objectAtIndex:section];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cellid"];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellid"];
    }
    DataEntity *info=[[_source objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%ld      %@      %@         %@",info.uid,info.name,info.age,info.cityname];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _seldIc=[[_source objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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
        NSMutableArray *demo=[[NSMutableArray alloc]init];
        for (NSDictionary *dic in list) {
            DataEntity *entity=[[DataEntity alloc]init];
            [entity setValuesForKeysWithDictionary:dic];
            [demo addObject:entity];
        }
        [self careAboutList:demo];
    }];
}

-(void)careAboutList:(NSArray*)list{
    
    NSMutableArray * sections = [[NSMutableArray alloc] init];
    NSMutableArray * sources = [[NSMutableArray alloc] init];
    
    UILocalizedIndexedCollation *location=[UILocalizedIndexedCollation currentCollation];
    NSMutableArray * secArray=[NSMutableArray arrayWithArray:location.sectionTitles];
    
    NSMutableArray *demoArray=[[NSMutableArray alloc]init];
    for (NSInteger i=0; i<secArray.count; i++) {
        NSMutableArray *array=[[NSMutableArray alloc]init];
        [demoArray addObject:array];
    }
    for (DataEntity *info in list) {
        NSInteger index=[location sectionForObject:info collationStringSelector:@selector(name)];
        [demoArray[index] addObject:info];
    }
    for (NSInteger i=0; i<secArray.count; i++) {
        NSMutableArray *array=demoArray[i];
        NSArray *sort=[location sortedArrayFromArray:array collationStringSelector:@selector(name)];
        demoArray[i]=sort;
    }
    for (NSInteger i=0; i<demoArray.count; i++) {
        if ([[demoArray objectAtIndex:i] count]) {
            [sections addObject:[secArray objectAtIndex:i]];
            [sources addObject:[demoArray objectAtIndex:i]];
        }
    }
    _secAarray=sections;
    _source=sources;
    [_list reloadData];
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
        [[SqliteManager sharedSqlite] deleteDb:@"user" option:@{@"id":@(_seldIc.uid)} complete:^(BOOL result) {
            NSLog(result?@"删除成功":@"删除失败");
            if (result) {
                _seldIc=nil;
            }
            [self getData];
        }];
    }
}
@end
