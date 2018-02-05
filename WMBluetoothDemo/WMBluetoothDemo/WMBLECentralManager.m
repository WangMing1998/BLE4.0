//
//  WMBLECentralManager.m
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/28.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#import "WMBLECentralManager.h"

@interface WMBLECentralManager()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property(nonatomic,strong) CBCentralManager *centeralManager;
// peripherals is connected
@property(nonatomic,strong) NSMutableArray<WMBLEPeripheral *> *connectedPeripherals;
// peripherals has been found
@property(nonatomic,strong) NSMutableArray<WMBLEPeripheral *> *discoverPeripherals;
// Need automatic reconnection peripherals
@property(nonatomic,strong) NSMutableArray<WMBLEPeripheral *> *reConnectPeripherals;
// timer for bleTool
@property (strong, nonatomic) NSTimer *timeoutTimer;
@end

@implementation WMBLECentralManager

+ (instancetype)shareInstance {
    static WMBLECentralManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [WMBLECentralManager new];
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
        NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey:@(1),
                                  CBCentralManagerOptionRestoreIdentifierKey:@"WMBluetoothRestore"
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
        
        self.connectedPeripherals    = [NSMutableArray array];
        self.reConnectPeripherals    = [NSMutableArray array];
        self.discoverPeripherals     = [NSMutableArray array];
        self.characteristicsForRead  = [NSMutableArray array];
        self.characteristicsForWrite = [NSMutableArray array];
   
    }
    return self;
}

/**
 Scanning peripherals

 @param services Peripheral services UUID
 @param options  Scan the peripherals set parameters
 */
-(void)startScanWithServices:(NSArray<CBUUID *>*)services options:(NSDictionary *)options{
    self.servicesUUID = services ;
    self.scanOptions = options;
    [self.centeralManager scanForPeripheralsWithServices:services options:options];
}

/**
 Stop scanning bluetooth peripherals
 */
-(void)stopScanPeripherals{
    [self.centeralManager stopScan];
    [self.discoverPeripherals removeAllObjects];
}

/**
 Connecting peripherals

 @param peripheral Need to connect the peripherals
 @param options    Connecting peripherals parameter Settings
 */
-(void)connectWitpPeripheral:(WMBLEPeripheral *)peripheral options:(NSDictionary *)options{
    [self.centeralManager connectPeripheral:peripheral.blePeripheral options:options];
    [self startTimer];
}


/**
 Disconnect peripherals

 @param peripheral Need to disconnect peripherals
 */
-(void)disconnectWithPeripheral:(WMBLEPeripheral *)peripheral{
    [self.centeralManager cancelPeripheralConnection:peripheral.blePeripheral];
}

-(void)disconnectAllPeripheral{
    for (WMBLEPeripheral *per in self.connectedPeripherals) {
        [self.centeralManager cancelPeripheralConnection:per.blePeripheral];
    }
}


/**
 Add need heavy equipment
 
 @param peripheral The custom of bluetooth peripherals
 */
-(void)addNeedReconnectPeripheral:(WMBLEPeripheral *)peripheral{
    if(![self.reConnectPeripherals containsObject:peripheral]){
        [self.reConnectPeripherals addObject:peripheral];
    }
}

/**
 remove need heavy equipment
 
 @param peripheral The custom of bluetooth peripherals
 */
-(void)removeReconnectPeripheral:(WMBLEPeripheral *)peripheral{
    [self.reConnectPeripherals removeObject:peripheral];
}


-(void)retriveWithUUIDs:(NSArray<NSUUID *> *)uuids{
    NSArray *peripherals = [self.centeralManager retrievePeripheralsWithIdentifiers:uuids];
    if(peripherals.count <= 0 || peripherals == nil){
        NSDictionary *dic = @{CENTRALKEY:self,ERRORKEY:WM_ERROR(WMCentralErrorConnectAutoConnectFail)};
        [kNotificationCenter postNotificationName:BLENotificationDidFailToConnectPeripheral object:dic];
        return;
    }
    
    [self.reConnectPeripherals removeAllObjects];
    for(CBPeripheral *per in peripherals){
        WMBLEPeripheral *peripheral = [WMBLEPeripheral peripheralWithCBPeripheral:per];
        [self.reConnectPeripherals addObject:peripheral];
        [self.centeralManager connectPeripheral:per options:self.connectOptions];
    }
    // 开始计时
    [self startTimer];
}

-(void)sendBuffer:(NSData *)data
       peripheral:(WMBLEPeripheral *)peripheral
 characteristic:(CBCharacteristic *)characteristic{
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
    
    CBCharacteristicWriteType type = CBCharacteristicWriteWithResponse;
    if(characteristic.properties == 0x04){
        type = CBCharacteristicWriteWithoutResponse;
    }else{
        type = CBCharacteristicWriteWithResponse;
    }
    [peripheral.blePeripheral writeValue:data forCharacteristic:characteristic type:type];
    
}

#pragma mark - CBCentralManagerDelegate委托方法
-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict{
    
}

/**
 The callback equipment state change

 @param central CBCentralManager
 */
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    [kNotificationCenter postNotificationName:BLENotificationCentralManagerDidUpdateState object:central];
    switch (central.state) {
        case CBManagerStateUnknown:
            WMLog(@"CBManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            WMLog(@"CBManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            WMLog(@"CBManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            WMLog(@"CBManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
            WMLog(@"CBManagerStatePoweredOff");
        case CBManagerStatePoweredOn:
            WMLog(@"CBManagerStatePoweredOn");
            break;
        default:
            break;
    }
}

/**
 Found peripherals, through broadcast packet filter peripherals

 @param central BLE center management mode
 @param peripheral Have found the peripherals
 @param advertisementData Data broadcast packets
 @param RSSI Signal strength
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI{
    // 设置过滤规则
    NSString *localName=[advertisementData valueForKeyPath:CBAdvertisementDataLocalNameKey];
    WMLog(@"localName:%@\r\nperipheral.name:%@",localName,peripheral.name);//  local的正确获取方法
    if(self.filteronDiscocer){
        if(self.filteronDiscocer(localName,advertisementData,RSSI)){
            NSString *localName=[advertisementData valueForKeyPath:CBAdvertisementDataLocalNameKey];
            WMLog(@"localName:%@\r\nperipheral.name:%@",localName,peripheral.name);//  local的正确获取方法
            WMBLEPeripheral *per = [WMBLEPeripheral peripheralWithCBPeripheral:peripheral deviceLocalName:localName];
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
 Successfully connected peripherals

 @param central  BLE center management mode
 @param peripheral Have Connected the peripherals
 */
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    peripheral.delegate = self;
    [self stopTimer];
    NSDictionary *dic = @{CENTRALKEY:central,PERIPHERALKEY:peripheral};
    [kNotificationCenter postNotificationName:BLENotificationDidConnectPeripheral object:dic];
    WMLog(@"-->成功连接到名称为:%@的设备",peripheral.name);
    // 停止连接计时
    WMBLEPeripheral *per = [WMBLEPeripheral peripheralWithCBPeripheral:peripheral];
    if(![self.connectedPeripherals containsObject:per]){
        [self.connectedPeripherals addObject:per];
    }
    [peripheral discoverServices:nil];
}

/**
Fail connected peripherals

@param central  BLE center management mode
@param peripheral Have failed the peripherals
*/
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if(error){
        WMLog(@"-->didFailToConnectPeripheral error:%@",error);
        
    }
    NSDictionary *dic = @{CENTRALKEY:central,PERIPHERALKEY:peripheral,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDidFailToConnectPeripheral object:dic];
    WMLog(@"-->连接失败名称为:%@的设备",peripheral.name);
}
/**
 Disconnected peripherals
 
 @param central  BLE center management mode
 @param peripheral Have disconnected the peripherals
 */
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if(error){
        WMLog(@"-->didDisconnectPeripheral error:%@",error)
    }
    NSDictionary *dic = @{CENTRALKEY:central,PERIPHERALKEY:peripheral,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDidDisconnectPeripheral object:dic];
    WMLog(@"-->断开连接名称为:%@的设备",peripheral.name);
    WMBLEPeripheral *per = [WMBLEPeripheral peripheralWithCBPeripheral:peripheral];
    if([self.connectedPeripherals containsObject:per]){
        [self.connectedPeripherals removeObject:per];
    }
   
    // Check and reconnect the need rewiring peripherals
    if([self.reConnectPeripherals containsObject:per]){
        [self connectWitpPeripheral:per options:self.connectOptions];
    }
}


/**
 Scanning to the peripheral services

 @param peripheral services of peripheral
 @param error error messeage
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
  
    if(error){
        WMLog(@"-->peripheral.name:%@\n-->didDiscoverServices error:%@",peripheral.name,error)
    }
    NSDictionary *dic = @{PERIPHERALKEY:peripheral,SERVICEKEY:peripheral.services,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDidDiscoverServices object:dic];
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:self.characteristicsUUID forService:service];
    }
}


/**
 Found characteristics, need access to features here before sending data

 @param peripheral current peripheral
 @param service current service
 @param error error messeage
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error{
    if(error){
        WMLog(@"-->discoverCharacteristicsForService error:%@",error);
    }
     WMBLEPeripheral *per = [WMBLEPeripheral peripheralWithCBPeripheral:peripheral];
    NSDictionary *dic = @{PERIPHERALKEY:per,SERVICEKEY:service,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDidDiscoverCharacteristicsForService object:dic];
  
   
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        // characteristic for write Data
        if(characteristic.properties & CBCharacteristicPropertyWrite ||
           characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse){
            [self.characteristicsForWrite addObject:characteristic];
        }
        
        // characteristic for receive Data
        if(characteristic.properties & CBCharacteristicPropertyNotify){
            [self.characteristicsForRead addObject:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
    
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
        WMLog(@"-->didDiscoverDescriptorsForCharacteristic error:%@",error);
    }
    WMLog(@"-->characteristic.description:%@",characteristic.description);
}


/**
 Notify the state set haracteristic
 if failure is unacceptable peripherals characteristics of the data
 @param peripheral current peripheral
 @param characteristic current characteristic
 @param error messeage
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
     
        NSDictionary *dic = @{PERIPHERALKEY:peripheral,CHARACTERISTICKEY:characteristic,ERRORKEY:error?error:@""};
        [kNotificationCenter postNotificationName:BLENotificationDidUpdateNotificationStateForCharacteristic object:dic];
        WMLog(@"-->setting characteristic Notify fail:%@",error)
    }
}

/**
Receive Data form hardwava

 @param peripheral data of peripheral
 @param characteristic data of characteristic
 @param error error meeseage
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if(error){
        WMLog(@"-->didUpdateValueForCharacteristic error:%@",error);
    }
    NSDictionary *dic = @{PERIPHERALKEY:peripheral,CHARACTERISTICKEY:characteristic,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDidUpdateValueForCharacteristic object:dic];
}

/**
 Write data to characteristic of peripheral

 @param peripheral Target peripherals
 @param characteristic  characteristic of peripherals
 @param error write result
 */
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSDictionary *dic = nil;
    if(error){
        WMLog(@"-->didWriteValueForCharacteristic error:%@",error);
        dic = @{PERIPHERALKEY:peripheral,CHARACTERISTICKEY:characteristic,ERRORKEY:WM_ERROR(WMCentralErrorWriteDataError)};
    }else{
        dic = @{PERIPHERALKEY:peripheral,CHARACTERISTICKEY:characteristic,ERRORKEY:error?error:@""};
    }
    [kNotificationCenter postNotificationName:BLENotificationDidWriteValueForCharacteristic object:dic];
}

# if  __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    if(error){
        WMLog(@"-->peripheralDidUpdateRSSI error%@",error);
    }
    NSDictionary *dic = @{PERIPHERALKEY:peripheral,RSSIKEY:RSSI?RSSI:@0,ERRORKEY:error?error:@""}
    [kNotificationCenter postNotificationName:BLENotificationDidReadRSSI object:dic];
}
#else
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if(error){
        WMLog(@"-->peripheralDidUpdateRSSI error%@",error);
    }
    NSDictionary *dic = @{PERIPHERALKEY:peripheral,RSSIKEY:RSSI?RSSI:@0,ERRORKEY:error?error:@""};
    [kNotificationCenter postNotificationName:BLENotificationDidReadRSSI object:dic];
}
#endif


- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0) {
    WMLog(@"设备名称变化");
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices NS_AVAILABLE(NA, 7_0) {
    WMLog(@"设备服务变化");
}


#pragma mark -timer
-(void)startTimer{
    if(BLECENTRALTOOLTIMEOUT <= 0){
        return ;
    }
    [self stopTimer];
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:BLECENTRALTOOLTIMEOUT target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
}

-(void)stopTimer{
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

-(void)timeOut{
    NSDictionary *dic = @{CENTRALKEY:self,ERRORKEY:WM_ERROR(WMCentralErrorConnectTimeOut)};
    [kNotificationCenter postNotificationName:BLENotificationDidFailToConnectPeripheral object:dic];
    WMLog(@"-->连接超时");
}
@end
