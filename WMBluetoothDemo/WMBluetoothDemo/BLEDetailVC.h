//
//  BLEDetailVC.h
//  WMBluetoothDemo
//
//  Created by Heaton on 2018/2/5.
//  Copyright © 2018年 WangMingDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMBLEPeripheral.h"
@interface BLEDetailVC : UIViewController
@property(nonatomic,strong) WMBLEPeripheral *currenPeripheral;
@end
