//
//  DVTDeviceManager+Anglerfish.h
//  Anglerfish
//
//  Created by Toshihiro Morimoto on 5/14/16.
//  Copyright © 2016 Toshihiro Morimoto. All rights reserved.
//

#import "DVTDeviceManager+Anglerfish.h"
#import "DVTDevice.h"
#import "Anglerfish-Swift.h"

@implementation DVTDevice (Anglerfish)

- (void)af_didBecomeActiveDeviceForRunContext:(id)arg1 {
    SimulatorHistoryManager *manager = SimulatorHistoryManager.sharedInstance;
    [manager update:self.identifier];
    
    [self af_didBecomeActiveDeviceForRunContext:arg1];
}

@end

@implementation DVTDeviceManager (Anglerfish)

- (NSSet *)af_availableDevices {
    NSSet *devices = [self af_availableDevices];
   
    SimulatorHistoryManager *manager = SimulatorHistoryManager.sharedInstance;
    for (DVTDevice *device in devices.allObjects) {
        if ([device isKindOfClass:NSClassFromString(@"DVTiPhoneSimulator")]) {
            NSInteger index = [manager indexOf:device.identifier];
            [device setValue:[NSString stringWithFormat:@"Simulator Sort Order: %ld", (long)index]
                      forKey:@"displayOrder"];
        }
    }
    return devices;
}

@end
