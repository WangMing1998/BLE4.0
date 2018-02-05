//
//  WMBLETool.m
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/29.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#import "WMBLETool.h"

@interface WMBLETool()
@property(nonatomic,strong) WMBLECentralManager *bleManager;
@property(nonatomic,copy)   NSString *peripheralName;
@property(nonatomic,strong) NSData   *adverData;
@property(nonatomic,strong) NSNumber *RSSI;
@end
@implementation WMBLETool

+ (instancetype)shareInstance{
    static WMBLETool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [WMBLETool new];
    });
    return instance;
}

-(instancetype)init{
    if(self = [super init]){
        __weak typeof(self) weakSelf = self;
        self.bleManager = [WMBLECentralManager shareInstance];
        [self listeningNotifications];
        [self.bleManager setFilteronDiscocer:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
            if(weakSelf.bleFiliterPeralsRuleBlock){
                if(weakSelf.bleFiliterPeralsRuleBlock(peripheralName, advertisementData, RSSI)){
                    return YES;
                }else{
                    return NO;
                }
            }else{
                return YES;
            }
        }];
    }
    return self;
}

-(void)startScanWithServices:(NSArray<CBUUID *> *)services options:(NSDictionary *)options{
    [self.bleManager startScanWithServices:nil options:nil];
    
    
}


-(void)stopScanPeripherals{
    [self.bleManager stopScanPeripherals];
}

-(void)connectWitpPeripheral:(WMBLEPeripheral *)peripheral options:(NSDictionary *)options{
    [self.bleManager connectWitpPeripheral:peripheral options:options];
}

-(void)disconnectWithPeripheral:(WMBLEPeripheral *)peripheral{
    [self.bleManager  disconnectWithPeripheral:peripheral];
}

-(void)disconnectAllPeripheral{
    [self.bleManager disconnectAllPeripheral];
}

-(void)autoReconnectPeripheralWithUUIDs:(NSArray<NSUUID *>*)uuids{
    [self.bleManager retriveWithUUIDs:uuids];
}


-(void)listeningNotifications{
    
    // 硬件状态发生变化通知
    [kNotificationCenter addObserverForName:BLENotificationCentralManagerDidUpdateState object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if(self.bleDidUpdateStateBlock){
            self.bleDidUpdateStateBlock(note.object);
        }
    }];
    
    // 发现设备通知
    [kNotificationCenter addObserverForName:BLENotificationDidDiscoverPeripheral object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *dic = note.object;
        CBCentralManager *central = dic[CENTRALKEY];
        WMBLEPeripheral *per = dic[PERIPHERALKEY];
        NSNumber *RSSI = dic[RSSIKEY];
        NSDictionary *avdertisementData = dic[@"advertisementData"];
        if(self.bleDiscoverPeripheralsBlock){
            self.bleDiscoverPeripheralsBlock(central,per, avdertisementData,RSSI);
        }
    }];

    // 连接设备成功通知
    [kNotificationCenter addObserverForName:BLENotificationDidConnectPeripheral object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *dic = note.object;
        CBCentralManager *central = dic[CENTRALKEY];
        WMBLEPeripheral *per = dic[PERIPHERALKEY];
        if(self.bleConnectedPeripheralBlock){
            self.bleConnectedPeripheralBlock(central,per);
        }
    }];

 
    // 连接设备失败通知
    [kNotificationCenter addObserverForName:BLENotificationDidFailToConnectPeripheral object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *dic = note.object;
        CBCentralManager *central = dic[CENTRALKEY];
        WMBLEPeripheral *per = dic[PERIPHERALKEY];
        NSError *error = dic[ERRORKEY];
        if(self.bleConnectedFailPeripheralBlock){
            self.bleConnectedFailPeripheralBlock(central,per,error);
        }
    }];

    
    // 断开设备通知
    [kNotificationCenter addObserverForName:BLENotificationDidDisconnectPeripheral object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *dic = note.object;
        CBCentralManager *central = dic[CENTRALKEY];
        WMBLEPeripheral *per = dic[PERIPHERALKEY];
        NSError *error = dic[ERRORKEY];
        if(self.bleDisconnectedPeripheralBlock){
            self.bleDisconnectedPeripheralBlock(central, per, error);
        }
    }];
  

    // 发现服务通知
    [kNotificationCenter addObserverForName:BLENotificationDidDiscoverServices object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *dic = note.object;
        WMBLEPeripheral *per = dic[PERIPHERALKEY];
        NSError *error = dic[ERRORKEY];
        CBService *service = dic[SERVICEKEY];
        if(self.bleDiscoverServicesBlock){
            self.bleDiscoverServicesBlock(per,service,error);
        }
    }];

    // 发现特征
    [kNotificationCenter addObserverForName:BLENotificationDidDiscoverCharacteristicsForService object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *dic = note.object;
        WMBLEPeripheral *per = dic[PERIPHERALKEY];
        NSError *error = dic[ERRORKEY];
        CBService *service = dic[SERVICEKEY];
        if(self.bleDiscoverCharacteristicsBlock){
            self.bleDiscoverCharacteristicsBlock(per,service,error);
        }
    }];
 

    // 接受到特征的数据
    [kNotificationCenter addObserverForName:BLENotificationDidUpdateValueForCharacteristic object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *dic = note.object;
        NSError *error = dic[ERRORKEY];
        WMBLEPeripheral *per = dic[PERIPHERALKEY];
        CBCharacteristic *characteristic = dic[CHARACTERISTICKEY];
        if(self.bleDidupdateValueForCharacteristicsBlock){
            self.bleDidupdateValueForCharacteristicsBlock(per,characteristic,error);
        }
    }];
 
    // 向特征写入数据成功与否通知
    [kNotificationCenter addObserverForName:BLENotificationDidWriteValueForCharacteristic object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *dic = note.object;
        NSError *error = dic[ERRORKEY];
        WMBLEPeripheral *per = dic[PERIPHERALKEY];
        CBCharacteristic *characteristic = dic[CHARACTERISTICKEY];
        if(self.bleDidWriteValueForCharacteristicBlock){
            self.bleDidWriteValueForCharacteristicBlock(per,characteristic,error);
        }
    }];
 


    // 开启通知状态通知
    [kNotificationCenter addObserverForName:BLENotificationDidUpdateNotificationStateForCharacteristic object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *dic = note.object;
        NSError *error = dic[ERRORKEY];
        WMBLEPeripheral *per = dic[PERIPHERALKEY];
        CBCharacteristic *characteristic = dic[CHARACTERISTICKEY];
        if(self.bleDidUpdateNotificationStateForCharacteristicBlock){
            self.bleDidUpdateNotificationStateForCharacteristicBlock(per,characteristic,error);
        }
    }];
    
    // 设备RRSI信号发生变化通知
    [kNotificationCenter addObserverForName:BLENotificationDidReadRSSI object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *dic = note.object;
        NSError *error = dic[ERRORKEY];
        WMBLEPeripheral *per = dic[PERIPHERALKEY];
        NSNumber *bleRssi = dic[RSSIKEY];
        if(self.bleDidReadRSSIBlock){
            self.bleDidReadRSSIBlock(per,bleRssi,error);
        }
    }];
}



@end
