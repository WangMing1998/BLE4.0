//
//  WMBLEPeripheral.h
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/28.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//
//[advertisementData valueForKeyPath:CBAdvertisementDataLocalNameKey];
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class CBPeripheral;
@class CBCharacteristic;
@interface WMBLEPeripheral : NSObject
// 蓝牙外设
@property(nonatomic,strong) CBPeripheral *blePeripheral;
// 设备UUID
@property(nonatomic,strong) NSUUID *bleIdentifier;
// 设备名称
@property(nonatomic,strong) NSString *blePeripheralName;
// 广播名称
@property(nonatomic,strong) NSString *bleLocalName;
// 是否自动连接
@property(nonatomic,assign) BOOL    bleAutoConnection;
// 是否连接
@property(nonatomic,assign) BOOL    bleConnected;
// 写数据特征
@property(nonatomic,strong) CBCharacteristic *writeCharacteristic;
+ (instancetype)peripheralWithCBPeripheral:(CBPeripheral *)cbPeripheral;
+ (instancetype)peripheralWithCBPeripheral:(CBPeripheral *)cbPeripheral deviceLocalName:(NSString *)localName;
@end
