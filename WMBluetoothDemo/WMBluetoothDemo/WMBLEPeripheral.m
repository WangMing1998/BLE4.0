//
//  WMBLEPeripheral.m
//  WMBluetoothDemo
//
//  Created by Heaton on 2017/12/28.
//  Copyright © 2017年 WangMingDeveloper. All rights reserved.
//

#import "WMBLEPeripheral.h"
@implementation WMBLEPeripheral
+(instancetype)peripheralWithCBPeripheral:(CBPeripheral *)peripheral{
    WMBLEPeripheral *per = [WMBLEPeripheral  new];
    per.blePeripheral = peripheral;
    per.bleIdentifier = peripheral.identifier;
    if(peripheral.name == nil || peripheral.name.length == 0){
        per.blePeripheralName = @"BLEDevice";
    }else{
        per.blePeripheralName = peripheral.name;
    }
    return per;
    
}
+(instancetype)peripheralWithCBPeripheral:(CBPeripheral *)peripheral deviceLocalName:(NSString *)localName
{
    WMBLEPeripheral *per = [WMBLEPeripheral  new];
    per.blePeripheral = peripheral;
    per.bleIdentifier = peripheral.identifier;
    if(localName == nil || localName.length == 0){
        per.blePeripheralName = @"BLEDevice";
        per.bleLocalName = @"BLEDevice";
    }else{
        per.blePeripheralName = peripheral.name;
        per.bleLocalName = localName;
    }
    return per;
}


- (BOOL)isEqual:(id)object {
    WMBLEPeripheral *peripheral = object;
    return [self.bleIdentifier.UUIDString caseInsensitiveCompare:peripheral.bleIdentifier.UUIDString] == NSOrderedSame;
}

#pragma mark - Getter / Setter

- (BOOL)bleConnected{
    _bleConnected = self.blePeripheral.state == CBPeripheralStateConnected;
    return _bleConnected;
}

@end
