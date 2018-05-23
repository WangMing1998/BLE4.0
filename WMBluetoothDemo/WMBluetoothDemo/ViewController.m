//
//  ViewController.m
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/28.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#import "ViewController.h"
#import "XDBLECentralManager.h"
#import "XDBLETool.h"
#import "DeviceCell.h"
#import "BLEDetailVC.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property(nonatomic,strong) XDBLETool *bleManager;
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) NSMutableArray<XDBLEPeripheral *> *deviceList;
@property (weak, nonatomic) IBOutlet UISwitch *switchScan;
@property(nonatomic,strong) BLEDetailVC *bleDetailVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bleManager  = [XDBLETool shareInstance];
    
    // 设置过滤规则，此处以设备名称过滤
    [self.bleManager setBleFiliterPeralsRuleBlock:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //以设备名称过滤
//        if([peripheralName isEqualToString:@"Aiture-23B47C"]){
//            return YES;
//        }else{
//            return NO;
//        }
        // 如不需要设置，return YES；
        return YES;
    }];

    [self addObserver];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.bleDetailVC  = [storyboard instantiateViewControllerWithIdentifier:@"BLEDetailVC"];
}

-(void)addObserver{
    __weak typeof(self) weakself=self;
    // 发现外设
    self.bleManager.bleDiscoverPeripheralsBlock = ^(CBCentralManager *central, XDBLEPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        if(![weakself.deviceList containsObject:peripheral]){
            [weakself.deviceList addObject:peripheral];
            dispatch_async(dispatch_get_main_queue(), ^{
                 [weakself.tableView reloadData];
            });
           
        }
    };
    
    self.bleManager.bleDidReadRSSIBlock = ^(XDBLEPeripheral *peripheral, NSNumber *RSSI, NSError *error) {
        NSInteger index = [weakself.deviceList indexOfObject:peripheral];
        if(index != NSNotFound){
            DeviceCell *cell = [weakself.tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndex:index]];
            cell.RSSI.text = [RSSI stringValue];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
            [weakself.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    };
}



- (IBAction)switchScanTapped:(UISwitch *)sender {
    if(sender.isOn){
        [self.deviceList removeAllObjects];
        [self.bleManager stopScanPeripherals];
        [self.tableView reloadData];
        [self.bleManager startScanWithServices:@[[CBUUID UUIDWithString:@"C0E0"],
                                                 [CBUUID UUIDWithString:@"0000FEE9-0000-1000-8000-00805F9B34FB"]
                                                ] options:nil];
    }else{
        [self.deviceList removeAllObjects];
        [self.tableView reloadData];
        [self.bleManager stopScanPeripherals];
    }
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.deviceList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[DeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    XDBLEPeripheral *per = self.deviceList[indexPath.row];
    cell.deviceName.text = per.bleLocalName;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XDBLEPeripheral *per = self.deviceList[indexPath.row];
    self.bleDetailVC.currenPeripheral = per;
}


-(NSMutableArray<XDBLEPeripheral *> *)deviceList{
    if(_deviceList == nil){
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
}



@end
