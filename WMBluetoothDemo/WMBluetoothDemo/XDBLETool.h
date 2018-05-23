//
//  XDBLETool.h
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/29.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XDBLEDefine.h"

typedef enum:NSInteger{
    bleUnknown,
    bleResetting,
    bleUnsupported,
    bleUnauthorized,
    blePoweredOff,
    blePoweredOn,
}BLEState;

@interface XDBLETool : NSObject
// 过滤外设回调
@property(nonatomic,copy) XDBLEFilterPeripheralsRlueBlock            bleFiliterPeralsRuleBlock;
// ble状态更新回调
@property(nonatomic,copy) XDBLECentralManagerDidUpdateStateBlock     bleDidUpdateStateBlock;
// 发现外设回调
@property(nonatomic,copy) XDBLEDiscoverPeripheralsBlock              bleDiscoverPeripheralsBlock;
// 连接外设成功回调
@property(nonatomic,copy) XDBLEConnectedPeripheralBlock              bleConnectedPeripheralBlock;
// 连接外设失败回调
@property(nonatomic,copy) XDBLEFailToConnectBlock                    bleConnectedFailPeripheralBlock;
// 外设断开连接回调
@property(nonatomic,copy) XDBLEDisconnectBlock                       bleDisconnectedPeripheralBlock;
// 发现外设服务回调
@property(nonatomic,copy) XDBLEDiscoverServicesBlock                 bleDiscoverServicesBlock;
// 发现外设特征回调
@property(nonatomic,copy) XDBLEDiscoverCharacteristicsBlock          bleDiscoverCharacteristicsBlock;
// 接收到特征数据回调
@property(nonatomic,copy) XDBLEDidupdateValueForCharacteristicBlock  bleDidupdateValueForCharacteristicsBlock;
// 写数据到外设回调
@property(nonatomic,copy) XDBLEDidWriteValueForCharacteristicBlock   bleDidWriteValueForCharacteristicBlock;
// 读取RSSI回调---还没测试
@property(nonatomic,copy) XDBLEDidReadRSSIBlock                      bleDidReadRSSIBlock;
// 设置特征通知回调
@property(nonatomic,copy) XDBLEDidUpdateNotificationStateForCharacteristicBlock bleDidUpdateNotificationStateForCharacteristicBlock;
// 蓝牙状态
@property(nonatomic,assign) BLEState bleState;
// 已经发现的设备
@property(nonatomic,strong) NSMutableArray *disCoverPeripherals;
// 已经连接的设备
@property(nonatomic,strong) NSMutableArray *connectedPeripherals;
+ (instancetype)shareInstance;

/**
 扫描包含services的外设

 @param services 服务特征UUID
 @param options  扫描设置
 */
-(void)startScanWithServices:(NSArray<CBUUID *>*)services options:(NSDictionary *)options;

/**
 停止扫描
 */
-(void)stopScanPeripherals;

/**
 连接外设

 @param peripheral 需要连接的外设
 @param options 连接参数
 */
-(void)connectWitpPeripheral:(XDBLEPeripheral *)peripheral options:(NSDictionary *)options;

/**
 断开链接外设

 @param peripheral 需要断开的外设
 */
-(void)disconnectWithPeripheral:(XDBLEPeripheral *)peripheral;


/**
 自动连接

 @param uuids 需要自动连接的外设UUID
 */
-(void)autoReconnectPeripheralWithUUIDs:(NSArray<NSUUID *>*)uuids;


/**
 发送数据

 @param data 需要发送的二进制数据，注意包体大小。
 @param peripheral 需要接收数据的外设
 @param characteristic 需要写入的特征
 @param type 接收数据的特征类型
 */
-(void)sendBuffer:(NSData *)data
       peripheral:(XDBLEPeripheral *)peripheral
   characteristic:(CBCharacteristic *)characteristic
characteristicType:(CBCharacteristicWriteType)type;
@end
