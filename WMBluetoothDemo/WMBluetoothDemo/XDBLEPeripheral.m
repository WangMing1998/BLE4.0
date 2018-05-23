//
//  XDBLEPeripheral.m
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/28.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#import "XDBLEPeripheral.h"
@implementation XDBLEPeripheral
+(instancetype)peripheralWithCBPeripheral:(CBPeripheral *)peripheral{
    XDBLEPeripheral *per = [XDBLEPeripheral  new];
    per.blePeripheral = peripheral;
    per.bleIdentifier = peripheral.identifier;
    per.bleLocalName = [[NSUserDefaults standardUserDefaults] objectForKey:[peripheral.identifier.UUIDString stringByAppendingString:@"localName"]];
    return per;
    
}

- (BOOL)isEqual:(id)object {
    XDBLEPeripheral *peripheral = object;
    return [self.bleIdentifier.UUIDString caseInsensitiveCompare:peripheral.bleIdentifier.UUIDString] == NSOrderedSame;
}

#pragma mark - Getter / Setter

- (BOOL)bleConnected{
    _bleConnected = self.blePeripheral.state == CBPeripheralStateConnected;
    return _bleConnected;
}

@end
