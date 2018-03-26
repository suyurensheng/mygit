//
//  BlueVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2017/5/27.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "BlueVC.h"
#import "BlueToothManager.h"

@interface BlueVC()<UITableViewDelegate,UITableViewDataSource,BlueToothManagerDelegate>{

    NSMutableArray *_source;
    
}
@property (nonatomic, strong) BlueToothManager *manager;

@end
@implementation BlueVC

-(id)init{

    self=[[[NSBundle mainBundle] loadNibNamed:@"BlueVC" owner:self options:nil] lastObject];
    return self;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    _manager=[BlueToothManager sharedManager];
    [_manager beganWithTarget:self];
}
-(void)BTManager:(BlueToothManager *)manager didScanNewDevice:(DeviceEntity *)device{
    if (!_source) {
        _source=[[NSMutableArray alloc]init];
    }
    for (DeviceEntity *dev in _source) {
        if ([device.name isEqualToString:dev.name]) {
            return;
        }
    }
    [_source addObject:device];
    [_table reloadData];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _source.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"tsetid"];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tsetid"];
    }
    DeviceEntity *dev= [_source objectAtIndex:indexPath.row];
    cell.textLabel.text=dev.name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    DeviceEntity *dev=[_source objectAtIndex:indexPath.row];
    [_manager connectDevice:dev complete:^(BOOL success, CBPeripheral *peripheral) {
    }];
}

-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    [_manager stop];
}
@end
