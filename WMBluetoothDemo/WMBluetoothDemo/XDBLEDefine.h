//
//  XDBLEDefine.h
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/28.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#ifndef XDBLEDefine_h
#define XDBLEDefine_h
#import <CoreBluetooth/CoreBluetooth.h>
#import "XDBLEPeripheral.h"
#import "XDBLECentralManager.h"
#define kNotificationCenter [NSNotificationCenter defaultCenter]
#define OPEN_BLE_ALERTVIEW 1
#define SHOW_LOG 1
#define BLECENTRALTOOLTIMEOUT 60
#define WM_ERROR(description) [NSError errorWithDomain:@"com.wangming.XDBLElabiary" code:0 userInfo:@{NSLocalizedDescriptionKey:description}]

#define CENTRALKEY        @"CentralKey"
#define PERIPHERALKEY     @"PeripheralKey"
#define ERRORKEY          @"ErrorKey"
#define SERVICEKEY        @"ServiceKey"
#define CHARACTERISTICKEY @"CharacteristicKey"
#define RSSIKEY           @"RSSIKey"

static NSString * const WMCentralErrorConnectTimeOut         = @"Connect time out";
static NSString * const WMCentralErrorConnectOthers          = @"Other error";
static NSString * const WMCentralErrorConnectPowerOff        = @"Power off";
static NSString * const WMCentralErrorConnectAutoConnectFail = @"Auto connect fail";
static NSString * const WMCentralErrorWriteDataLength        = @"Data length error";
static NSString * const WMCentralErrorWriteDataCharacteristic  = @"Characteristic error";
static NSString * const WMCentralErrorWriteDataConnect       = @"Not connected peripherals";
static NSString * const WMCentralErrorWriteDataError        = @"Write Data to peripheral error";

// Set any parameters as the filter rules of peripherals
typedef BOOL (^XDBLEFilterPeripheralsRlueBlock)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI);
typedef void (^XDBLECentralManagerDidUpdateStateBlock)(CBCentralManager *central);
typedef void (^XDBLEDiscoverPeripheralsBlock)(CBCentralManager *central,XDBLEPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI);
typedef void (^XDBLEConnectedPeripheralBlock)(CBCentralManager *central,XDBLEPeripheral *peripheral);
typedef void (^XDBLEFailToConnectBlock)(CBCentralManager *central,XDBLEPeripheral *peripheral,NSError *error);
typedef void (^XDBLEDisconnectBlock)(CBCentralManager *central,XDBLEPeripheral *peripheral,NSError *error);
typedef void (^XDBLEDiscoverServicesBlock)(XDBLEPeripheral *peripheral,CBService *service,NSError *error);
typedef void (^XDBLEDiscoverCharacteristicsBlock)(XDBLEPeripheral *peripheral,CBService *service,NSError *error);
typedef void (^XDBLEDidupdateValueForCharacteristicBlock)(XDBLEPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error);
typedef void (^XDBLEDidWriteValueForCharacteristicBlock)(XDBLEPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error);
typedef void (^XDBLEDidUpdateNotificationStateForCharacteristicBlock)(XDBLEPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error);
typedef void (^XDBLEDidReadRSSIBlock)(XDBLEPeripheral *peripheral,NSNumber *RSSI,NSError *error);
typedef void (^XDBLEDiscoverDescriptorsForCharacteristicBlock)(XDBLEPeripheral *peripheral,CBCharacteristic *service,NSError *error);
typedef void (^XDBLEReadValueForDescriptorsBlock)(XDBLEPeripheral *peripheral,CBDescriptor *descriptor,NSError *error);




//蓝牙系统通知
#define BLENotificationCentralManagerDidUpdateState @"BLENotificationCentralManagerDidUpdateState" // 蓝牙状态更新
#define BLENotificationDidDiscoverPeripheral @"BLENotificationDidDiscoverPeripheral"// 发现外设
#define BLENotificationDidConnectPeripheral @"BLENotificationDidConnectPeripheral"// 链接成功
#define BLENotificationDidFailToConnectPeripheral @"BLENotificationDidFailToConnectPeripheral"
#define BLENotificationDidDisconnectPeripheral @"BLENotificationDidDisconnectPeripheral"// 断开链接
#define BLENotificationDidDiscoverServices @"BLENotificationDidDiscoverServices"// 发现服务
#define BLENotificationDidDiscoverCharacteristicsForService @"BLENotificationDidDiscoverCharacteristicsForService"// 发现特征
#define BLENotificationDiscoverDescriptorsForCharacteristic @"BLENotificationDiscoverDescriptorsForCharacteristic"// 发现特征描述
#define BLENotificationDidUpdateValueForCharacteristic @"BLENotificationDidUpdateValueForCharacteristic"// 接收到特征值
#define BLENotificationDidWriteValueForCharacteristic @"BLENotificationDidWriteValueForCharacteristic"// 数据写入通知
#define BLENotificationDidUpdateNotificationStateForCharacteristic @"BLENotificationDidUpdateNotificationStateForCharacteristic"
#define BLENotificationDidReadRSSI @"BLENotificationDidReadRSSI"
#define BLENotificationWriteDataError @"BLENotificationWriteDataError"
#define BLENotificationWriteDataFinish @"BLENotificationWriteDataFinish"
#define WMLog(fmt, ...) if(SHOW_LOG) { NSLog(fmt,##__VA_ARGS__); }
#endif /* XDBLEDefine_h */
