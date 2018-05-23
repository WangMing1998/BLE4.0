 //
//  XDBLECentralManager.m
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/28.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#import "XDBLECentralManager.h"

@interface XDBLECentralManager()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property(nonatomic,strong) CBCentralManager *centeralManager;
@property(nonatomic,strong) NSTimer *timeoutTimer;
@property(nonatomic,assign) NSInteger connectTimeCount;
@property(nonatomic,strong) NSMutableArray *discoverPeripherals;
@end

@implementation XDBLECentralManager

+ (instancetype)shareInstance {
    static XDBLECentralManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [XDBLECentralManager new];
        
    });
    return instance;
}

/*
-->CBCentralManagerOptionShowPowerAlertKey:Alert when bluetooth Power didn't open the prompt dialog box
-->CBCentralManagerOptionRestoreIdentifierKey:Corresponding is a unique identification string,
    used to kill restore connection with bluetooth process.
 */
-(instancetype)init{
    self = [super init];
    if(self){
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_0
        NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey:@(OPEN_BLE_ALERTVIEW)
                                  };
#else
        NSDictionary *options = nil;
#endif
        NSArray *backgroundModes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIBackgroundModes"];
        if([backgroundModes containsObject:@"bluetooth-central"]){
            self.centeralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                        queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                                      options:options];
        }else{
            self.centeralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                        queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        }
    }
    self.connectTimeCount = BLECENTRALTOOLTIMEOUT;
    self.discoverPeripherals = [NSMutableArray array];
    return self;
}

/**
 扫描外设
 
 @param services 需要扫描外设的服务，一般用于过滤
 @param options  扫描参数
 */
-(void)startScanWithServices:(NSArray<CBUUID *>*)services options:(NSDictionary *)options{
    self.scanOptions = options;
    [self.discoverPeripherals removeAllObjects];
    [self.centeralManager scanForPeripheralsWithServices:services options:options];
}

/**
 Stop scanning bluetooth peripherals
 */
-(void)stopScanPeripherals{
    [self.discoverPeripherals removeAllObjects];
    [self.centeralManager stopScan];
}

/**
连接外设

 @param peripheral 需要连接的外设
 @param options    连接参数，可为空
 */
-(void)connectWitpPeripheral:(XDBLEPeripheral *)peripheral options:(NSDictionary *)options{
    NSAssert(peripheral != nil, @"外设不能为空");
    [self.centeralManager connectPeripheral:peripheral.blePeripheral options:options];
    [self startTimer];
}


/**
断开连接

 @param peripheral 需要断开的外设
 */
-(void)disconnectWithPeripheral:(XDBLEPeripheral *)peripheral{
    NSAssert(peripheral != nil, @"外设不能为空");
    [self.centeralManager cancelPeripheralConnection:peripheral.blePeripheral];
}

/**
 外设自动重连

 @param uuids 需要自动重连的设备
 */
-(void)retriveWithUUIDs:(NSArray<NSUUID *> *)uuids{
    NSArray *peripherals = [self.centeralManager retrievePeripheralsWithIdentifiers:uuids];
    if(peripherals.count <= 0 || peripherals == nil){
        NSDictionary *dic = @{CENTRALKEY:self,ERRORKEY:WM_ERROR(WMCentralErrorConnectAutoConnectFail)};
        [kNotificationCenter postNotificationName:BLENotificationDidFailToConnectPeripheral object:dic];
        return;
    }
    
    for(CBPeripheral *per in peripherals){
        [self.centeralManager connectPeripheral:per options:self.connectOptions];
    }
    // 开始计时
    [self startTimer];
}


/**
 发送数据

 @param data 需要发送的二进制数据
 @param peripheral 目标外设
 @param characteristic 需要写入的特征
 @param type 特征类型。填错了会写入失败
 */
-(void)sendBuffer:(NSData *)data
       peripheral:(XDBLEPeripheral *)peripheral
 characteristic:(CBCharacteristic *)characteristic
characteristicType:(CBCharacteristicWriteType)type{
    if(!characteristic){
        NSDictionary *dic = @{PERIPHERALKEY:peripheral,ERRORKEY:WM_ERROR(WMCentralErrorWriteDataCharacteristic)};
        [kNotificationCenter postNotificationName:BLENotificationWriteDataError object:dic];
        return ;
    }
    
    if (peripheral.bleConnected == NO) {
        NSDictionary *dic = @{PERIPHERALKEY:peripheral,ERRORKEY:WM_ERROR(WMCentralErrorWriteDataConnect)};
        [kNotificationCenter postNotificationName:BLENotificationWriteDataError object:dic];
        return;
    }
    
    if(data.length <= 0 || data == nil){
        NSDictionary *dic = @{PERIPHERALKEY:peripheral,ERRORKEY:WM_ERROR(WMCentralErrorWriteDataLength)};
        [kNotificationCenter postNotificationName:BLENotificationWriteDataError object:dic];
        return;
    }
    
    [peripheral.blePeripheral writeValue:data forCharacteristic:characteristic type:type];
    
}


/**
 蓝牙状态更新回调

 @param central BLE中心管理者模式
 */
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (@available(iOS 10.0, *)) {
        if(central.state == CBManagerStatePoweredOff){
            [self stopTimer];
        }
    } else {
        if(central.state == CBCentralManagerStatePoweredOff){
            [self stopTimer];
        }
    }
    [kNotificationCenter postNotificationName:BLENotificationCentralManagerDidUpdateState object:central];
}

/**
 发现外设

 @param central BLE中心管理者模式
 @param peripheral 发现的外设
 @param advertisementData 外设广播包数据
 @param RSSI 外设的信号强度
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI{
    // 设置过滤规则
    NSString *localName=[advertisementData valueForKeyPath:CBAdvertisementDataLocalNameKey];
    WMLog(@"localName:%@\r\nperipheral.name:%@",localName,peripheral.name);//  local的正确获取方法
    if(self.filteronDiscocer){
        if(self.filteronDiscocer(localName,advertisementData,RSSI)){
            [[NSUserDefaults standardUserDefaults] setObject:localName forKey:[peripheral.identifier.UUIDString stringByAppendingString:@"localName"]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            XDBLEPeripheral *per = [XDBLEPeripheral peripheralWithCBPeripheral:peripheral];
            if(![self.discoverPeripherals containsObject:per]){
                [self.discoverPeripherals addObject:per];
                WMLog(@"discoverPeripherals:%@",self.discoverPeripherals);
                NSDictionary *dic = @{CENTRALKEY:central,PERIPHERALKEY:per,@"advertisementData":advertisementData,RSSIKEY:RSSI};
                [kNotificationCenter postNotificationName:BLENotificationDidDiscoverPeripheral object:dic];
            }
        }
    }
}

/**
外设连接成功通知

 @param central BLE中心模式管理者
 @param peripheral Have Connected the peripherals
 */
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    peripheral.delegate = self;
    [self stopTimer];
    XDBLEPeripheral *per = [XDBLEPeripheral peripheralWithCBPeripheral:peripheral];
    NSDictionary *dic = @{CENTRALKEY:central,PERIPHERALKEY:per};
    
    [kNotificationCenter postNotificationName:BLENotificationDidConnectPeripheral object:dic];
    WMLog(@"-->成功连接到名称为:%@的设备",peripheral.name);

    [peripheral discoverServices:nil];
}

/**
外设连接失败回调

@param central  BLE中心模式管理者
@param peripheral 连接失败的外设
*/
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if(error){
        WMLog(@"-->didFailToConnectPeripheral error:%@",error);
    }
    [self stopTimer];
    XDBLEPeripheral *per = [XDBLEPeripheral peripheralWithCBPeripheral:peripheral];
    NSDictionary *dic = @{CENTRALKEY:central,PERIPHERALKEY:per,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDidFailToConnectPeripheral object:dic];
    WMLog(@"-->连接失败名称为:%@的设备",peripheral.name);
}
/**
 外设断开链接回调
 @param central  BLE中心模式管理者
 @param peripheral 断开链接的外设
 */
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if(error){
        WMLog(@"-->didDisconnectPeripheral error:%@",error)
    }
    XDBLEPeripheral *per = [XDBLEPeripheral peripheralWithCBPeripheral:peripheral];
    NSDictionary *dic = @{CENTRALKEY:central,PERIPHERALKEY:per,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDidDisconnectPeripheral object:dic];
    WMLog(@"-->断开连接名称为:%@的设备",peripheral.name);
}


/**
发现外设服务回调

 @param peripheral 目标外设
 @param error 错误信息
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
  
    if(error){
        WMLog(@"-->peripheral.name:%@\n-->didDiscoverServices error:%@",peripheral.name,error)
    }

    // 发现服务
    XDBLEPeripheral *per = [XDBLEPeripheral peripheralWithCBPeripheral:peripheral];
    NSDictionary *dic = @{PERIPHERALKEY:per,SERVICEKEY:peripheral.services,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDidDiscoverServices object:dic];
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/**
 发现特征回调

 @param peripheral 目标外设
 @param service 当前服务
 @param error 错误信息
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error{
    if(error){
        WMLog(@"-->discoverCharacteristicsForService error:%@",error);
    }
    XDBLEPeripheral *per = [XDBLEPeripheral peripheralWithCBPeripheral:peripheral];
    NSDictionary *dic = @{PERIPHERALKEY:per,SERVICEKEY:service,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDidDiscoverCharacteristicsForService object:dic];
    for (CBCharacteristic *characteristic in service.characteristics) {
        if (characteristic.properties & CBCharacteristicPropertyNotify) {// 开启通知
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            WMLog(@"通知的特征是:%@\n",characteristic);
        }
    }
}


/**
 发现特征描述回调

 @param peripheral 目标外设
 @param characteristic 当前特征
 @param error 错误信息
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
        WMLog(@"-->didDiscoverDescriptorsForCharacteristic error:%@",error);
    }
    XDBLEPeripheral *per = [XDBLEPeripheral peripheralWithCBPeripheral:peripheral];
    NSDictionary *dic = @{PERIPHERALKEY:per,CHARACTERISTICKEY:characteristic,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDiscoverDescriptorsForCharacteristic object:dic];
    WMLog(@"-->characteristic.description:%@",characteristic.description);
}


/**
 Notify 特征开启通知结果回调

 @param peripheral 目标外设
 @param characteristic 设置通知的特征
 @param error 错误信息
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
        XDBLEPeripheral *per = [XDBLEPeripheral peripheralWithCBPeripheral:peripheral];
        NSDictionary *dic = @{PERIPHERALKEY:per,CHARACTERISTICKEY:characteristic,ERRORKEY:error?error:@""};
        [kNotificationCenter postNotificationName:BLENotificationDidUpdateNotificationStateForCharacteristic object:dic];
        WMLog(@"-->setting characteristic Notify fail:%@",error)
    }
}

/**
 接收到硬件发过来的数据

 @param peripheral 目标外设发过来的外设
 @param characteristic 接收到数据的特征
 @param error 接收结果
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if(error){
        WMLog(@"-->didUpdateValueForCharacteristic error:%@",error);
    }
    XDBLEPeripheral *per = [XDBLEPeripheral peripheralWithCBPeripheral:peripheral];
    NSDictionary *dic = @{PERIPHERALKEY:per,CHARACTERISTICKEY:characteristic,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDidUpdateValueForCharacteristic object:dic];
}



/**
 写数据到外设回掉。需要硬件写入特征类型为:CBCharacteristicWriteWithoutResponse

 @param peripheral 写入数据的目标外设
 @param characteristic  接收数据的特征
 @param error 如果error为nil,表示写入成功
 */
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSDictionary *dic = nil;
    XDBLEPeripheral *per = [XDBLEPeripheral peripheralWithCBPeripheral:peripheral];
    if(error != nil){
        WMLog(@"-->didWriteValueForCharacteristic error:%@",error);
        dic = @{PERIPHERALKEY:per,CHARACTERISTICKEY:characteristic,ERRORKEY:WM_ERROR(WMCentralErrorWriteDataError)};
    }else{
        dic = @{PERIPHERALKEY:per,CHARACTERISTICKEY:characteristic,ERRORKEY:error?error:@""};
    }
    [kNotificationCenter postNotificationName:BLENotificationDidWriteValueForCharacteristic object:dic];
}

# if  __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    if(error){
        WMLog(@"-->peripheralDidUpdateRSSI error%@",error);
    }
    XDBLEPeripheral *per = [XDBLEPeripheral peripheralWithCBPeripheral:peripheral];
    NSDictionary *dic = @{PERIPHERALKEY:per,RSSIKEY:RSSI?RSSI:@0,ERRORKEY:error?error:@""}
    [kNotificationCenter postNotificationName:BLENotificationDidReadRSSI object:dic];
}
#else
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if(error){
        WMLog(@"-->peripheralDidUpdateRSSI error%@",error);
    }
    XDBLEPeripheral *per = [XDBLEPeripheral peripheralWithCBPeripheral:peripheral];
    NSDictionary *dic = @{PERIPHERALKEY:per,RSSIKEY:RSSI?RSSI:@0,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDidReadRSSI object:dic];
}
#endif


/**
 设备名称发生变化

 @param peripheral 外设
 */
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0) {
    WMLog(@"设备名称变化");
}


/**
 设备服务发生变化

 @param peripheral 发生变化的外设
 @param invalidatedServices 可用的外设
 */
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices NS_AVAILABLE(NA, 7_0) {
    WMLog(@"设备服务变化");
}



#pragma mark -timer
-(void)startTimer{
    if(self.connectTimeCount <= 0){
        return ;
    }
    [self stopTimer];
    self.connectTimeCount = BLECENTRALTOOLTIMEOUT;
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:BLECENTRALTOOLTIMEOUT target:self selector:@selector(timeOut) userInfo:nil repeats:YES];
}

-(void)stopTimer{
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

-(void)timeOut{
    self.connectTimeCount--;
    WMLog(@"连接中------>%lds",self.connectTimeCount);
    if(self.connectTimeCount <= 0){
        [self stopTimer];
        NSDictionary *dic = @{CENTRALKEY:self,ERRORKEY:WM_ERROR(WMCentralErrorConnectTimeOut)};
        [kNotificationCenter postNotificationName:BLENotificationDidFailToConnectPeripheral object:dic];
        WMLog(@"-->连接超时");
    }
}
@end
