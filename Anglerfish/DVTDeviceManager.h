//
//  DVTDeviceManager.h
//  Anglerfish
//
//  Created by Toshihiro Morimoto on 5/14/16.
//  Copyright © 2016 Toshihiro Morimoto. All rights reserved.
//

@import Foundation;
@class DVTDevice;

@interface DVTDeviceManager : NSObject

@property(copy) NSSet *availableDevices; // @dynamic availableDevices;

@end
