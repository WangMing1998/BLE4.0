//
//  BLEDetailVC.m
//  WMBluetoothDemo
//
//  Created by Heaton on 2018/2/5.
//  Copyright © 2018年 WangMingDeveloper. All rights reserved.
//

#import "BLEDetailVC.h"
#import "WMBLETool.h"
@interface BLEDetailVC ()

@end

@implementation BLEDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [WMBLETool shareInstance].bleConnectedPeripheralBlock = ^(CBCentralManager *central, WMBLEPeripheral *peripheral) {
        NSLog(@"连接成功");
        _currenPeripheral = peripheral;
    };
    
    [WMBLETool shareInstance].bleConnectedFailPeripheralBlock = ^(CBCentralManager *central, WMBLEPeripheral *peripheral, NSError *error) {
        NSLog(@"连接失败");
    };
    
    [WMBLETool shareInstance].bleDiscoverServicesBlock = ^(WMBLEPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"services:%@",peripheral.blePeripheral.services);
    };
    
    
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
    [[WMBLETool shareInstance] disconnectWithPeripheral:self.currenPeripheral];
}


-(void)setCurrenPeripheral:(WMBLEPeripheral *)currenPeripheral{
    _currenPeripheral = currenPeripheral;
    [[WMBLETool shareInstance] connectWitpPeripheral:_currenPeripheral options:nil];
}
@end
