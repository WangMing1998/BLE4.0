//
//  BLEDetailVC.m
//  WMBluetoothDemo
//
//  Created by Heaton on 2018/2/5.
//  Copyright © 2018年 WangMingDeveloper. All rights reserved.
//

#import "BLEDetailVC.h"
#import "XDBLETool.h"
@interface BLEDetailVC ()
@property(weak, nonatomic) IBOutlet UILabel *connectStatus;
@property(weak, nonatomic) IBOutlet UILabel *deviceName;
@property(weak, nonatomic) IBOutlet UILabel *deviceID;
@property(weak, nonatomic) IBOutlet UILabel *dataLength;// 数据包大小
@property(weak, nonatomic) IBOutlet UITextField *dataSize;// 分包大小
@property(weak, nonatomic) IBOutlet UILabel *currentProgress;// 当前进度
@property(weak, nonatomic) IBOutlet UILabel *currentRate;// 速率
@property(weak, nonatomic) IBOutlet UILabel *sendBegingTime;
@property(weak, nonatomic) IBOutlet UILabel *sendFishTime;
@property(weak, nonatomic) IBOutlet UIButton *sendButton;\
@property(weak, nonatomic) IBOutlet UILabel *sendTimeCount;
@property(nonatomic,strong) NSData *sendData;//需要发送的数据
@property(nonatomic,assign) NSInteger subDataOffset;
@property(nonatomic,assign) NSInteger SendDataSubLength;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,assign) NSInteger timeCount;
@property(nonatomic,assign) BOOL isStopSend;
@property(nonatomic,strong) NSTimer *sendTimer;
@property (weak, nonatomic) IBOutlet UISwitch *isTimer;


@end

@implementation BLEDetailVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.sendButton.enabled = NO;
    self.SendDataSubLength = [self.dataSize.text integerValue];
    
    // 读入数据包
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BLE4_2speed.BIN" ofType:nil];
    self.sendData = [NSData dataWithContentsOfFile:filePath];

    
    [XDBLETool shareInstance].bleConnectedPeripheralBlock = ^(CBCentralManager *central, XDBLEPeripheral *peripheral) {
        NSLog(@"连接成功");
        _currenPeripheral = peripheral;
        NSUInteger maxWirteLength = [_currenPeripheral.blePeripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithResponse];
        NSLog(@"最大写数据%ld",maxWirteLength);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.deviceID.text = peripheral.blePeripheral.identifier.UUIDString;
            self.deviceName.text = peripheral.bleLocalName;
            self.connectStatus.text = @"connect success";
        });
        
    };
    
    [XDBLETool shareInstance].bleConnectedFailPeripheralBlock = ^(CBCentralManager *central, XDBLEPeripheral *peripheral, NSError *error) {
        NSLog(@"连接失败");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.connectStatus.text = @"connect fail";
        });
        
    };
    
    
    [XDBLETool shareInstance].bleDisconnectedPeripheralBlock = ^(CBCentralManager *central, XDBLEPeripheral *peripheral, NSError *error) {
        NSLog(@"断开链接");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.connectStatus.text = @"disConnected";
            CGFloat rate =  ((self.subDataOffset*1.0)/1000)/self.timeCount;
            self.currentProgress.text = [NSString stringWithFormat:@"%.2f%%",(self.subDataOffset * 1.0/self.sendData.length) * 100];
            self.currentRate.text = [NSString stringWithFormat:@"%.2fKb/s",rate];
            self.sendFishTime.text = [self getCurrentTIme];
            self.subDataOffset = 0;
            [self stopTimer];
            [self stopSendTimer];
        });
        
    };
    
    [XDBLETool shareInstance].bleDiscoverCharacteristicsBlock = ^(XDBLEPeripheral *peripheral, CBService *service, NSError *error) {
        
        for (CBCharacteristic *characteristic in service.characteristics) {
            // characteristic for write Data
            if(characteristic.properties & CBCharacteristicPropertyWrite ||
               characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse){
                self.currenPeripheral.writeCharacteristic = characteristic;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.sendButton.enabled = YES;
                });
                break;
            }
        }
    };
    
    [XDBLETool shareInstance].bleDiscoverServicesBlock = ^(XDBLEPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"services:%@",peripheral.blePeripheral.services);
    };
    
    
    [XDBLETool shareInstance].bleDidWriteValueForCharacteristicBlock = ^(XDBLEPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        
        if(self.isTimer.isOn == NO){
            NSData *data = [self subData];
            self.subDataOffset += data.length;
            if(self.isStopSend){
               CGFloat rate =  ((self.subDataOffset*1.0)/1000)/self.timeCount;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.currentProgress.text = [NSString stringWithFormat:@"%.2f%%",(self.subDataOffset * 1.0/self.sendData.length) * 100];
                    self.currentRate.text = [NSString stringWithFormat:@"%.2fKb/s",rate];
                    self.sendFishTime.text = [self getCurrentTIme];
                    self.subDataOffset = 0;
                    [self stopTimer];
                });

                return ;
            }
            
            if(self.subDataOffset >= self.sendData.length){
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGFloat rate =  ((self.sendData.length*1.0)/1000)/self.timeCount;
                    self.currentProgress.text = @"100%";
                    self.currentRate.text = [NSString stringWithFormat:@"%.2fKb/s",rate];
                    self.sendFishTime.text = [self getCurrentTIme];
                    self.subDataOffset = 0;
                    [self stopTimer];
                });
                return;
            }
            [[XDBLETool shareInstance] sendBuffer:data
                                       peripheral:self.currenPeripheral
                                   characteristic:self.currenPeripheral.writeCharacteristic
                               characteristicType:CBCharacteristicWriteWithResponse];
            }
    };
}
- (IBAction)changeValue:(UITextField *)sender {
    self.SendDataSubLength = [sender.text integerValue];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.dataLength.text = [NSString stringWithFormat:@"%zdbyte",self.sendData.length];
}

- (NSData *)subData {
    NSInteger totalLength = self.sendData.length;
    NSInteger remainLength = totalLength - self.subDataOffset;
    NSInteger rangLength = remainLength > self.SendDataSubLength ? self.SendDataSubLength : remainLength;
    NSData *data = [self.sendData subdataWithRange:NSMakeRange(self.subDataOffset, rangLength)];
//    NSLog(@"%@---%.2f",data,(self.subDataOffset * 1.0/self.sendData.length) * 100);
    dispatch_async(dispatch_get_main_queue(), ^{
         self.currentProgress.text = [NSString stringWithFormat:@"%.2f%%",(self.subDataOffset * 1.0/self.sendData.length) * 100];
    });
    NSLog(@"截取了%ld,偏移量:%ld\n",data.length,self.subDataOffset);
    
    return data;
}


- (IBAction)starSendTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected){
        self.isStopSend = NO;
        self.sendBegingTime.text = [self getCurrentTIme];
        if(self.isTimer.isOn == NO){
            NSData *data = [self subData];
            self.subDataOffset += data.length;
            [[XDBLETool shareInstance] sendBuffer:data
                                       peripheral:self.currenPeripheral
                                   characteristic:self.currenPeripheral.writeCharacteristic
                               characteristicType:CBCharacteristicWriteWithResponse];
        }else{
            [self startSendTimer];
        }
        [self startTimer];
        
    }else{
        [self stopSendTimer];
        [self stopTimer];
        self.isStopSend = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[XDBLETool shareInstance] disconnectWithPeripheral:self.currenPeripheral];
}


-(void)setCurrenPeripheral:(XDBLEPeripheral *)currenPeripheral{
    _currenPeripheral = currenPeripheral;
    [[XDBLETool shareInstance] connectWitpPeripheral:_currenPeripheral options:nil];
}

-(NSString*)getCurrentTIme{
    long long time = [self getDateTimeTOMilliSeconds:[NSDate date]];
    
    NSLog(@"%llu",time);
    
    NSDate *dat = [self getDateTimeFromMilliSeconds:time];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss.SSS"];
    
    NSString *date =[formatter stringFromDate:dat];
    
    NSString *timeLocal = [[NSString alloc] initWithFormat:@"%@", date];
    
    NSLog(@"\n%@", timeLocal);
    return timeLocal;
}


-(NSDate *)getDateTimeFromMilliSeconds:(long long) miliSeconds

{
    
    NSTimeInterval tempMilli = miliSeconds;
    
    NSTimeInterval seconds = tempMilli/1000.0;//这里的.0一定要加上，不然除下来的数据会被截断导致时间不一致
    
    NSLog(@"传入的时间戳=%f",seconds);
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
    
}

//将NSDate类型的时间转换为时间戳,从1970/1/1开始

-(long long)getDateTimeTOMilliSeconds:(NSDate *)datetime

{
    
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    
    NSLog(@"转换的时间戳=%f",interval);
    
    long long totalMilliseconds = interval*1000 ;
    
    NSLog(@"totalMilliseconds=%llu",totalMilliseconds);
    
    return totalMilliseconds;
    
}


-(void)startSendTimer{
    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:0.02                                                               target:self selector:@selector(sendTimerCount) userInfo:nil repeats:YES];
}

-(void)sendTimerCount{
    NSData *data = [self subData];
    self.subDataOffset += data.length;
    if(self.isStopSend){
        CGFloat rate =  ((self.subDataOffset*1.0)/1000)/self.timeCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentProgress.text = [NSString stringWithFormat:@"%.2f%%",(self.subDataOffset * 1.0/self.sendData.length) * 100];
            self.currentRate.text = [NSString stringWithFormat:@"%.2fKb/s",rate];
            self.sendFishTime.text = [self getCurrentTIme];
            self.subDataOffset = 0;
            [self stopTimer];
            [self stopSendTimer];
            self.sendButton.selected = NO;
        });
        
        return ;
    }
    if(self.subDataOffset >= self.sendData.length){
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat rate =  ((self.sendData.length*1.0)/1000)/self.timeCount;
            self.currentProgress.text = @"100%";
            self.currentRate.text = [NSString stringWithFormat:@"%.2fKb/s",rate];
            self.sendFishTime.text = [self getCurrentTIme];
            self.subDataOffset = 0;
            [self stopTimer];
            [self stopSendTimer];
            self.sendButton.selected = NO;
        });
        return;
    }
    
    [[XDBLETool shareInstance] sendBuffer:data
                               peripheral:self.currenPeripheral
                           characteristic:self.currenPeripheral.writeCharacteristic
                       characteristicType:CBCharacteristicWriteWithoutResponse];
}

-(void)stopSendTimer{
    [self.sendTimer invalidate];
    self.sendTimer = nil;
}

- (void)startTimer {
    [self stopTimer];
    self.timeCount = 0;
    self.sendTimeCount.text = [NSString stringWithFormat:@"%ld s",self.timeCount];
    if (self.subDataOffset >= self.sendData.length ||  self.sendButton.selected == NO) {
        return;
    }
    self.timer= [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
}

- (void)stopTimer {

    [self.timer invalidate];
    self.timer = nil;
}

-(void)timerCount {
    if (self.sendButton.selected == NO || self.subDataOffset >= self.sendData.length) {
        [self stopTimer];
        return;
    }
    self.timeCount++;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat rate = (self.subDataOffset/1000.0)/self.timeCount;
        self.currentRate.text = [NSString stringWithFormat:@"%.2fKb/s",rate];
        self.sendTimeCount.text = [NSString stringWithFormat:@"%ld s",self.timeCount];
    });
   
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.dataSize resignFirstResponder];
}
@end
