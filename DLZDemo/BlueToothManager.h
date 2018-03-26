//
//  BlueToothManager.h
//  DLZDemo
//
//  Created by 董力祯 on 2017/5/17.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeviceEntity.h"

@class BlueToothManager;
@protocol BlueToothManagerDelegate <NSObject>
@optional
-(void)BTManager:(BlueToothManager*)manager didScanNewDevice:(DeviceEntity*)device;
-(void)BTManager:(BlueToothManager*)manager didCancelConnectWithDevice:(DeviceEntity*)device;
@end

@interface BlueToothManager : NSObject

/*中心管理者*/
@property(nonatomic,strong)CBCentralManager *manager;

/*连接到的外设*/
@property(nonatomic,strong)DeviceEntity *connectDevice;

+(BlueToothManager*)sharedManager;

-(void)beganWithTarget:(id)target;

-(void)connectDevice:(DeviceEntity*)device complete:(void(^)(BOOL success,CBPeripheral*peripheral))complete;

-(void)cancelConnectDevice:(DeviceEntity*)device;

-(void)stop;
@end
