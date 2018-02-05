//
//  ViewController.m
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/28.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#import "ViewController.h"
#import "WMBLECentralManager.h"
#import "WMBLETool.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property(nonatomic,strong) WMBLETool *bleManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bleManager  = [WMBLETool shareInstance];
    char verify[4] = {'T', 'R', 0, 0x20};
    NSData *verifyData = [NSData dataWithBytes:verify length:4];
    [self.bleManager setBleFiliterPeralsRuleBlock:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        if([peripheralName isEqualToString:@"Aiture-23B47C"]){
            return YES;
        }else{
            return NO;
        }
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)scanButtonTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.bleManager startScanWithServices:nil options:nil];
    self.bleManager.bleDiscoverPeripheralsBlock = ^(CBCentralManager *central, WMBLEPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"\n\rPeripheralName:%@\n\rRSSI:%.2f",peripheral,[RSSI floatValue]);
    };
}
- (IBAction)connectButton:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
