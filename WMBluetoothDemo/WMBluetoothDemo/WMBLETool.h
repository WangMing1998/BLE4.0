//
//  WMBLETool.h
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/29.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMBLEDefine.h"
@interface WMBLETool : NSObject
@property(nonatomic,copy) WMBLEFilterPeripheralsRlueBlock            bleFiliterPeralsRuleBlock;
@property(nonatomic,copy) WMBLECentralManagerDidUpdateStateBlock     bleDidUpdateStateBlock;
@property(nonatomic,copy) WMBLEDiscoverPeripheralsBlock              bleDiscoverPeripheralsBlock;
@property(nonatomic,copy) WMBLEConnectedPeripheralBlock              bleConnectedPeripheralBlock;
@property(nonatomic,copy) WMBLEFailToConnectBlock                    bleConnectedFailPeripheralBlock;
@property(nonatomic,copy) WMBLEDisconnectBlock                       bleDisconnectedPeripheralBlock;
@property(nonatomic,copy) WMBLEDiscoverServicesBlock                 bleDiscoverServicesBlock;
@property(nonatomic,copy) WMBLEDiscoverCharacteristicsBlock          bleDiscoverCharacteristicsBlock;
@property(nonatomic,copy) WMBLEDidupdateValueForCharacteristicBlock  bleDidupdateValueForCharacteristicsBlock;
@property(nonatomic,copy) WMBLEDidWriteValueForCharacteristicBlock   bleDidWriteValueForCharacteristicBlock;
@property(nonatomic,copy) WMBLEDidReadRSSIBlock                      bleDidReadRSSIBlock;
@property(nonatomic,copy) WMBLEDidUpdateNotificationStateForCharacteristicBlock bleDidUpdateNotificationStateForCharacteristicBlock;
+ (instancetype)shareInstance;
/**
 Peripherals service id, please fill nil if scanning all of the peripherals
 
 @param services services array
 @param options  Scan Settings
 
 --> options key
 CBCentralManagerScanOptionAllowDuplicatesKey YES/ON:Whether to repeat scanning devices have been found
 */
-(void)startScanWithServices:(NSArray<CBUUID *>*)services options:(NSDictionary *)options;

-(void)stopScanPeripherals;

-(void)connectWitpPeripheral:(WMBLEPeripheral *)peripheral options:(NSDictionary *)options;

-(void)disconnectWithPeripheral:(WMBLEPeripheral *)peripheral;

-(void)disconnectAllPeripheral;

-(void)autoReconnectPeripheralWithUUIDs:(NSArray<NSUUID *>*)uuids;
@end
