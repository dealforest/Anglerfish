//
//  DVTDevice.h
//  Anglerfish
//
//  Created by Toshihiro Morimoto on 5/15/16.
//  Copyright © 2016 Toshihiro Morimoto. All rights reserved.
//

@import Foundation;

@interface DVTDevice : NSObject

@property(copy) NSString *identifier; // @synthesize identifier=_identifier;

- (void)didBecomeActiveDeviceForRunContext:(id)arg1;

@end