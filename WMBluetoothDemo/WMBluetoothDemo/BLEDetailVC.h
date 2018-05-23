//
//  BLEDetailVC.h
//  WMBluetoothDemo
//
//  Created by Heaton on 2018/2/5.
//  Copyright © 2018年 WangMingDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDBLEPeripheral.h"
@interface BLEDetailVC : UIViewController
@property(nonatomic,strong) XDBLEPeripheral *currenPeripheral;
@end
