//
//  BlueToothManager.m
//  DLZDemo
//
//  Created by 董力祯 on 2017/5/17.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "BlueToothManager.h"

@interface BlueToothManager()<CBCentralManagerDelegate,CBPeripheralDelegate>{
    
    id _target;
    
    void(^_connectResultComplete)(BOOL success,CBPeripheral*peripheral);
}

@end

@implementation BlueToothManager

+(BlueToothManager*)sharedManager{
    
    static BlueToothManager *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared=[[BlueToothManager alloc]init];
    });
    return _shared;
}
-(void)beganWithTarget:(id)target{

    _target=target;
    if (!_manager) {
        _manager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
}
#pragma mark-CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{

    switch (central.state) {
        case CBManagerStatePoweredOn:{
            NSLog(@"蓝牙可用");
            [_manager scanForPeripheralsWithServices:nil options:nil];
        }
            break;
            
        default:
            break;
    }
}
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{

    NSLog(@"找到新蓝牙设备： name=%@ data=%@",peripheral.name,advertisementData);
    
    BOOL canConnect=[advertisementData[@"kCBAdvDataIsConnectable"] boolValue];
    if (canConnect&&peripheral.name.length) {
        if (_target&&[_target respondsToSelector:@selector(BTManager:didScanNewDevice:)]) {
            DeviceEntity *device=[[DeviceEntity alloc]init];
            device.name=peripheral.name;
            device.uuids=advertisementData[@"kCBAdvDataServiceUUIDs"];
            device.mac=advertisementData[@"kCBAdvDataManufacturerData"];
            device.peripheral=peripheral;
            device.connectAble=canConnect;
            [_target BTManager:self didScanNewDevice:device];
        }
    }
}

-(void)connectDevice:(DeviceEntity *)device complete:(void (^)(BOOL, CBPeripheral *))complete{
    
    _connectResultComplete=complete;
    _connectDevice=device;
    [_manager connectPeripheral:_connectDevice.peripheral options:nil];
    NSLog(@"开始连接设备：%@",device.name);
}
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"蓝牙连接失败");
    [self stop];
    _connectResultComplete(NO,peripheral);
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{

    NSLog(@"蓝牙连接成功");
    [_manager stopScan];
    _connectDevice.peripheral=peripheral;
    _connectResultComplete(YES,peripheral);
    peripheral.delegate=self;
    if (_connectDevice.uuids&&_connectDevice.uuids.count) {
        [peripheral discoverServices:_connectDevice.uuids];
    }else{
        [peripheral discoverServices:nil];
    }
}

-(void)cancelConnectDevice:(DeviceEntity *)device{
    
    [_manager cancelPeripheralConnection:device.peripheral];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"蓝牙已断开连接");
    if (_target&&[_target respondsToSelector:@selector(BTManager:didCancelConnectWithDevice:)]) {
        [_target BTManager:self didScanNewDevice:_connectDevice];
    }
    _connectDevice=nil;
}




#pragma mark-CBPeripheralDelegate

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    if (!error) {
        NSLog(@"获得设备服务成功");
        NSArray *services = peripheral.services;
        if (services.count) {
//            CBService *service = services[0];

            for (CBService *service in services) {
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }else{
            NSLog(@"没有服务");
        }
    }else{
        NSLog(@"获得设备服务失败 : %@", error);
    }
}
//-(void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices{
//    NSLog(@"设备服务更新");
//    NSArray *services = peripheral.services;
//    if (services.count) {
//        CBService *service = services[0];
//        [peripheral discoverCharacteristics:nil forService:service];
//    }
//}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error{//获得服务的特征
    if (!error) {
        NSArray *characteristicArray = service.characteristics;
        for (NSInteger i=0; i<characteristicArray.count; i++) {
            CBCharacteristic *charact=[characteristicArray objectAtIndex:i];
            NSLog(@"type=%lx",charact.properties);
            switch (charact.properties) {
                case CBCharacteristicPropertyNotify:{
                    [peripheral setNotifyValue:YES forCharacteristic:charact];
                }
                    break;
                case CBCharacteristicPropertyWrite:{
                    [peripheral writeValue:[NSData data] forCharacteristic:charact type:CBCharacteristicWriteWithResponse];
                }
                    break;
                case CBCharacteristicPropertyRead:{
                    [peripheral readValueForCharacteristic:charact];
                }
                    break;
                default:
                    break;
            }
        }
    } else {
        NSLog(@"发现特性错误 : %@", error);
    }
}
// 写入成功
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (!error) {
        NSLog(@"Write Success");
    } else {
        NSLog(@"WriteVale Error = %@", error);
    }
}
// 回复
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (!error) {
        __unused NSData *responseData = characteristic.value;
        
        switch (characteristic.properties) {
            case CBCharacteristicPropertyNotify:{
                NSString *str=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//                NSLog(@"收到数据data=%@  result=%@",responseData , str);

                if (str.length) {
                    
                }else{
                    Byte *testByte = (Byte *)[responseData bytes];
                    char type=testByte[3];
                    switch (type) {
                        case 2:{//数值
                            
                            NSLog(@"收到压力值：%d",testByte[4]*16*16+testByte[5]);
                        }
                            break;
                        case 3:{//电量
                           
                            NSLog(@"收到电量值：%d",testByte[6]);
                        }
                            break;
                        case 12:{//结果
                            NSInteger error=testByte[4];
                            if (error==28) {
                                NSLog(@"收到结果：高压：%d 低压：%d   心率：%d",testByte[5]*16*16+testByte[6],testByte[7]*16*16+testByte[8] , testByte[11]*16*16+testByte[12]);
                            }else{
                                NSInteger error=testByte[12];
                                NSString *message;
                                switch (error) {
                                    case 1:message=@"传感器信号异常";
                                        break;
                                    case 2:message=@"测量不出结果";
                                        break;
                                    case 3:message=@"测量结果异常";
                                        break;
                                    case 4:message=@"腕带过松或漏气";
                                        break;
                                    case 5:message=@"腕带过紧或气路堵塞";
                                        break;
                                    case 6:message=@"测量中压力干扰严重";
                                        break;
                                    case 7:message=@"压力超 300";
                                        break;
                                    default:message=@"未知错误";
                                        break;
                                }
                                NSLog(@"收到结果错误code=%ld：, message=%@",error,message);
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }
            }
                break;
            case CBCharacteristicPropertyRead:{
                NSString *str=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSLog(@"读取数据result=%@", str);
            }
                break;
            default:
                break;
        }
    } else {
        NSLog(@"收到数据错误: %@", error);
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

-(void)stop{
    if (_manager.isScanning) {
        [_manager stopScan];
    }
    if (_connectDevice) {
        [_manager cancelPeripheralConnection:_connectDevice.peripheral];
    }
    _manager=nil;
}
@end
