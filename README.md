
// 连接成功
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
    
    // 断开连接回调
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
    
    // 发现特征回调
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
    
    // 写入数据回调
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
