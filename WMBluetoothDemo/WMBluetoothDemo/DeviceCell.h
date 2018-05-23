//
//  DeviceCell.h
//  WMBluetoothDemo
//
//  Created by Heaton on 2018/2/5.
//  Copyright © 2018年 WangMingDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *seviceNumber;
@property (weak, nonatomic) IBOutlet UILabel *RSSI;

@end
