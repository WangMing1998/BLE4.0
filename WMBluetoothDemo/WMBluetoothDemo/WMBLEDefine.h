//
//  WMBLEDefine.h
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/28.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#ifndef WMBLEDefine_h
#define WMBLEDefine_h
#import <CoreBluetooth/CoreBluetooth.h>
#import "WMBLEPeripheral.h"
#import "WMBLECentralManager.h"
#define kNotificationCenter [NSNotificationCenter defaultCenter]
#define OPEN_BLE_ALERTVIEW 1
#define SHOW_LOG 1
#define BLECENTRALTOOLTIMEOUT 60.0
#define WM_ERROR(description) [NSError errorWithDomain:@"com.wangming.wmblelabiary" code:0 userInfo:@{NSLocalizedDescriptionKey:description}]

#define CENTRALKEY        @"CentralKey"
#define PERIPHERALKEY     @"PeripheralKey"
#define ERRORKEY          @"ErrorKey"
#define SERVICEKEY        @"ServiceKey"
#define CHARACTERISTICKEY @"CharacteristicKey"
#define RSSIKEY           @"RSSIKey"
// Set any parameters as the filter rules of peripherals
typedef BOOL (^WMBLEFilterPeripheralsRlueBlock)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI);
typedef void (^WMBLECentralManagerDidUpdateStateBlock)(CBCentralManager *central);
typedef void (^WMBLEDiscoverPeripheralsBlock)(CBCentralManager *central,WMBLEPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI);
typedef void (^WMBLEConnectedPeripheralBlock)(CBCentralManager *central,WMBLEPeripheral *peripheral);
typedef void (^WMBLEFailToConnectBlock)(CBCentralManager *central,WMBLEPeripheral *peripheral,NSError *error);
typedef void (^WMBLEDisconnectBlock)(CBCentralManager *central,WMBLEPeripheral *peripheral,NSError *error);
typedef void (^WMBLEDiscoverServicesBlock)(WMBLEPeripheral *peripheral,CBService *service,NSError *error);
typedef void (^WMBLEDiscoverCharacteristicsBlock)(WMBLEPeripheral *peripheral,CBService *service,NSError *error);
typedef void (^WMBLEDidupdateValueForCharacteristicBlock)(WMBLEPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error);
typedef void (^WMBLEDidWriteValueForCharacteristicBlock)(WMBLEPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error);
typedef void (^WMBLEDidUpdateNotificationStateForCharacteristicBlock)(WMBLEPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error);
typedef void (^WMBLEDidReadRSSIBlock)(WMBLEPeripheral *peripheral,NSNumber *RSSI,NSError *error);
typedef void (^WMBLEDiscoverDescriptorsForCharacteristicBlock)(WMBLEPeripheral *peripheral,CBCharacteristic *service,NSError *error);
typedef void (^WMBLEReadValueForDescriptorsBlock)(WMBLEPeripheral *peripheral,CBDescriptor *descriptor,NSError *error);




//蓝牙系统通知
#define BLENotificationCentralManagerDidUpdateState @"BLENotificationCentralManagerDidUpdateState"
#define BLENotificationDidDiscoverPeripheral @"BLENotificationDidDiscoverPeripheral"
#define BLENotificationDidConnectPeripheral @"BLENotificationDidConnectPeripheral"
#define BLENotificationDidFailToConnectPeripheral @"BLENotificationDidFailToConnectPeripheral"
#define BLENotificationDidDisconnectPeripheral @"BLENotificationDidDisconnectPeripheral"
#define BLENotificationDidDiscoverServices @"BLENotificationDidDiscoverServices"
#define BLENotificationDidDiscoverCharacteristicsForService @"BLENotificationDidDiscoverCharacteristicsForService"
#define BLENotificationDidUpdateValueForCharacteristic @"BLENotificationDidUpdateValueForCharacteristic"
#define BLENotificationDidWriteValueForCharacteristic @"BLENotificationDidWriteValueForCharacteristic"
#define BLENotificationDidUpdateNotificationStateForCharacteristic @"BLENotificationDidUpdateNotificationStateForCharacteristic"
#define BLENotificationDidReadRSSI @"BLENotificationDidReadRSSI"
#define BLENotificationWriteDataError @"BLENotificationWriteDataError"
#define BLENotificationWriteDataFinish @"BLENotificationWriteDataFinish"

#define WMLog(fmt, ...) if(SHOW_LOG) { NSLog(fmt,##__VA_ARGS__); }
#endif /* WMBLEDefine_h */
