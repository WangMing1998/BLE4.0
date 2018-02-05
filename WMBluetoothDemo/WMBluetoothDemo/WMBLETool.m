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
    [kNotificationCenter addObserver:self selector:@selector(bleCentralManagerDidUpdateState:)
                                name:BLENotificationCentralManagerDidUpdateState object:nil];

    [kNotificationCenter addObserver:self selector:@selector(bleDidDiscoverPeripheral:)
                                name:BLENotificationDidDiscoverPeripheral object:nil];

    [kNotificationCenter addObserver:self selector:@selector(bleDidConnectPeripheral:)
                                name:BLENotificationDidConnectPeripheral object:nil];

    [kNotificationCenter addObserver:self selector:@selector(bleDidFailToConnectPeripheral:)
                                name:BLENotificationDidFailToConnectPeripheral object:nil];

    [kNotificationCenter addObserver:self selector:@selector(bleDidDisconnectPeripheral:)
                                name:BLENotificationDidDisconnectPeripheral object:nil];

    [kNotificationCenter addObserver:self selector:@selector(bleDidDiscoverServices:)
                                name:BLENotificationDidDiscoverServices object:nil];

    [kNotificationCenter addObserver:self selector:@selector(bleDidDiscoverCharacteristicsForService:)
                                name:BLENotificationDidDiscoverCharacteristicsForService  object:nil];

    [kNotificationCenter addObserver:self selector:@selector(bleDidUpdateValueForCharacteristic:)
                                name:BLENotificationDidUpdateValueForCharacteristic object:nil];

    [kNotificationCenter addObserver:self selector:@selector(bleDidWriteValueForCharacteristic:)
                                name:BLENotificationDidWriteValueForCharacteristic object:nil];

    [kNotificationCenter addObserver:self selector:@selector(bleDidUpdateNotificationStateForCharacteristic:)
                                name:BLENotificationDidUpdateNotificationStateForCharacteristic object:nil];



    [kNotificationCenter addObserver:self selector:@selector(bleDidReadRSSI:) name:BLENotificationDidReadRSSI object:nil];

}

// 设备状态发生变化通知
-(void)bleCentralManagerDidUpdateState:(NSNotification *)notic{
    if(self.bleDidUpdateStateBlock){
        self.bleDidUpdateStateBlock(notic.object);
    }
}

// 发现设备通知
-(void)bleDidDiscoverPeripheral:(NSNotification *)notic{
    NSDictionary *dic = notic.object;
    CBCentralManager *central = dic[CENTRALKEY];
    WMBLEPeripheral *per = dic[PERIPHERALKEY];
    NSNumber *RSSI = dic[RSSIKEY];
    NSDictionary *avdertisementData = dic[@"advertisementData"];
    if(self.bleDiscoverPeripheralsBlock){
        self.bleDiscoverPeripheralsBlock(central,per, avdertisementData,RSSI);
    }
}


// 连接设备成功通知
-(void)bleDidConnectPeripheral:(NSNotification *)notic{
    NSDictionary *dic = notic.object;
    CBCentralManager *central = dic[CENTRALKEY];
    WMBLEPeripheral *per = dic[PERIPHERALKEY];
    if(self.bleConnectedPeripheralBlock){
        self.bleConnectedPeripheralBlock(central,per);
    }
}
// 连接设备失败通知
-(void)bleDidFailToConnectPeripheral:(NSNotification *)notic{
    NSDictionary *dic = notic.object;
    CBCentralManager *central = dic[CENTRALKEY];
    WMBLEPeripheral *per = dic[PERIPHERALKEY];
    NSError *error = dic[ERRORKEY];
    if(self.bleConnectedFailPeripheralBlock){
        self.bleConnectedFailPeripheralBlock(central,per,error);
    }
}

// 断开设备通知
-(void)bleDidDisconnectPeripheral:(NSNotification *)notic{
    NSDictionary *dic = notic.object;
    CBCentralManager *central = dic[CENTRALKEY];
    WMBLEPeripheral *per = dic[PERIPHERALKEY];
    NSError *error = dic[ERRORKEY];
    if(self.bleDisconnectedPeripheralBlock){
        self.bleDisconnectedPeripheralBlock(central, per, error);
    }
}

// 发现服务通知
-(void)bleDidDiscoverServices:(NSNotification *)notic{
    NSDictionary *dic = notic.object;
    WMBLEPeripheral *per = dic[PERIPHERALKEY];
    NSError *error = dic[ERRORKEY];
    CBService *service = dic[SERVICEKEY];
    if(self.bleDiscoverServicesBlock){
        self.bleDiscoverServicesBlock(per,service,error);
    }
}

// 发现服务的特征
-(void)bleDidDiscoverCharacteristicsForService:(NSNotification *)notic{
    NSDictionary *dic = notic.object;
    WMBLEPeripheral *per = dic[PERIPHERALKEY];
    NSError *error = dic[ERRORKEY];
    CBService *service = dic[SERVICEKEY];
    if(self.bleDiscoverCharacteristicsBlock){
        self.bleDiscoverCharacteristicsBlock(per,service,error);
    }
}

// 接受到特征的数据
-(void)bleDidUpdateValueForCharacteristic:(NSNotification *)notic{
    NSDictionary *dic = notic.object;
    NSError *error = dic[ERRORKEY];
    WMBLEPeripheral *per = dic[PERIPHERALKEY];
    CBCharacteristic *characteristic = dic[CHARACTERISTICKEY];
    if(self.bleDidupdateValueForCharacteristicsBlock){
        self.bleDidupdateValueForCharacteristicsBlock(per,characteristic,error);
    }
}

// 向特征写入数据成功与否通知
-(void)bleDidWriteValueForCharacteristic:(NSNotification *)notic{
    NSDictionary *dic = notic.object;
    NSError *error = dic[ERRORKEY];
    WMBLEPeripheral *per = dic[PERIPHERALKEY];
    CBCharacteristic *characteristic = dic[CHARACTERISTICKEY];
    if(self.bleDidWriteValueForCharacteristicBlock){
        self.bleDidWriteValueForCharacteristicBlock(per,characteristic,error);
    }
}

// 开启通知状态通知
-(void)bleDidUpdateNotificationStateForCharacteristic:(NSNotification *)notic{
    NSDictionary *dic = notic.object;
    NSError *error = dic[ERRORKEY];
    WMBLEPeripheral *per = dic[PERIPHERALKEY];
    CBCharacteristic *characteristic = dic[CHARACTERISTICKEY];
    if(self.bleDidUpdateNotificationStateForCharacteristicBlock){
        self.bleDidUpdateNotificationStateForCharacteristicBlock(per,characteristic,error);
    }
}

// 设备RRSI信号发生变化通知
-(void)bleDidReadRSSI:(NSNotification *)notic{
    NSDictionary *dic = notic.object;
    NSError *error = dic[ERRORKEY];
    WMBLEPeripheral *per = dic[PERIPHERALKEY];
    NSNumber *bleRssi = dic[RSSIKEY];
    if(self.bleDidReadRSSIBlock){
        self.bleDidReadRSSIBlock(per,bleRssi,error);
    }
}
 

@end
