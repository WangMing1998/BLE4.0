//
//  XDBLECentralManager.h
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/28.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#import "XDBLEDefine.h"
#import <Foundation/Foundation.h>



typedef BOOL (^filterOnDiscoverPeripherals)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI);
@interface XDBLECentralManager : NSObject
@property(nonatomic,copy) filterOnDiscoverPeripherals   filteronDiscocer;
@property(nonatomic,strong) NSDictionary *scanOptions;
@property(nonatomic,strong) NSDictionary *connectOptions;

+ (instancetype)shareInstance;
/**
 Peripherals service id, please fill nil if scanning all of the peripherals

 @param services services array
 @param options  Scan Settings
 
 --> options keyx
    CBCentralManagerScanOptionAllowDuplicatesKey YES/ON:Whether to repeat scanning devices have been found
 */
-(void)startScanWithServices:(NSArray<CBUUID *>*)services options:(NSDictionary *)options;
/**
 Stop scanning bluetooth peripherals
 */
-(void)stopScanPeripherals;

/**
 Links to bluetooth peripherals

 @param peripheral The custom of bluetooth peripherals
 @param options  Connection Settings
 
 -->options Key
 CBConnectPeripheralOptionNotifyOnConnectionKey
 CBConnectPeripheralOptionNotifyOnDisconnectionKey
 CBConnectPeripheralOptionNotifyOnNotificationKey
 */
-(void)connectWitpPeripheral:(XDBLEPeripheral *)peripheral options:(NSDictionary *)options;

/**
 Disconnect the bluetooth device

 @param peripheral The custom of bluetooth peripherals
 */
-(void)disconnectWithPeripheral:(XDBLEPeripheral *)peripheral;

/**
 According to the UUID reconnection peripherals

 @param uuids Peripherals UUID
 */
- (void)retriveWithUUIDs:(NSArray<NSUUID *> *)uuids;

/**
 To send data buffer to the peripherals

 @param data Need to send buffer
 @param peripheral Target peripherals
 @param characteristic To write data peripherals specified characteristics
 */
-(void)sendBuffer:(NSData *)data
       peripheral:(XDBLEPeripheral *)peripheral
   characteristic:(CBCharacteristic *)characteristic
characteristicType:(CBCharacteristicWriteType)type;
@end
