//
//  DeviceEntity.h
//  DLZDemo
//
//  Created by 董力祯 on 2018/3/12.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DeviceEntity : NSObject

@property(nonatomic,assign)NSString *name;
@property(nonatomic,strong)NSArray *uuids;
@property(nonatomic,assign)BOOL connectAble;
@property(nonatomic,strong)NSString *mac;
@property(nonatomic,strong)CBPeripheral *peripheral;
@end
