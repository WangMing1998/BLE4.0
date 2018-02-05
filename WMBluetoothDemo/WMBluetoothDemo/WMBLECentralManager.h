//
//  WMBLECentralManager.h
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/28.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#import "WMBLEDefine.h"
#import <Foundation/Foundation.h>

static NSString * const WMCentralErrorConnectTimeOut         = @"Connect time out";
static NSString * const WMCentralErrorConnectOthers          = @"Other error";
static NSString * const WMCentralErrorConnectPowerOff        = @"Power off";
static NSString * const WMCentralErrorConnectAutoConnectFail = @"Auto connect fail";
static NSString * const WMCentralErrorWriteDataLength        = @"Data length error";
static NSString * const WMCentralErrorWriteDataCharacteristic  = @"Characteristic error";
static NSString * const WMCentralErrorWriteDataConnect       = @"Not connected peripherals";
static NSString * const WMCentralErrorWriteDataError        = @"Write Data to peripheral error";

typedef BOOL (^filterOnDiscoverPeripherals)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI);
@interface WMBLECentralManager : NSObject
@property(nonatomic,copy) filterOnDiscoverPeripherals   filteronDiscocer;
@property(nonatomic,strong) NSArray<CBUUID *> *servicesUUID;
@property(nonatomic,strong) NSArray<CBUUID *> *characteristicsUUID;
@property(nonatomic,strong) NSMutableArray *characteristicsForRead;
@property(nonatomic,strong) NSMutableArray *characteristicsForWrite;
@property(nonatomic,assign) BOOL enableCharacteristicsNotify;
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
-(void)connectWitpPeripheral:(WMBLEPeripheral *)peripheral options:(NSDictionary *)options;

/**
 Disconnect the bluetooth device

 @param peripheral The custom of bluetooth peripherals
 */
-(void)disconnectWithPeripheral:(WMBLEPeripheral *)peripheral;

/**
 Disconnect all of the peripherals
 */
-(void)disconnectAllPeripheral;

/**
 Add need heavy equipment

 @param peripheral The custom of bluetooth peripherals
 */
-(void)addNeedReconnectPeripheral:(WMBLEPeripheral *)peripheral;

/**
 remove need heavy equipment

 @param peripheral The custom of bluetooth peripherals
 */
-(void)removeReconnectPeripheral:(WMBLEPeripheral *)peripheral;


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
       peripheral:(WMBLEPeripheral *)peripheral
   characteristic:(CBCharacteristic *)characteristic;
@end
