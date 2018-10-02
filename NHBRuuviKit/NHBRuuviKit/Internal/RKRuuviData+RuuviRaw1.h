//
//  RKRuuviData+RuuviRaw1.h
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import <Foundation/Foundation.h>
#import "RKRuuviData.h"

/*

Low-level access to values in ruuvi formats 2, 3 and 4.

DO NOT use these methods; use the higher level methods from the RKRuuvi category on NSData. See 'NSData+RKRuuvi.h'.
These methods do not check bounds or the format of the data; when used without proper external checks, this may pose a security risk.

*/

@interface RKRuuviData (RKRuuviRaw1)

-(nullable NSNumber*)ruuviRaw1Humidity;
-(nullable NSNumber*)ruuviRaw1Temperature;
-(nonnull NSNumber*)ruuviRaw1Pressure;
-(nonnull NSNumber*)ruuviRaw1BatteryVoltage;
-(nonnull NSNumber*)ruuviRaw1AccelerationForAxis:(RKRuuviAxis_t)axis;
-(nonnull NSNumber*)ruuviRaw1RandomID;
-(nonnull NSNumber*)ruuviRaw1RandomIDB64mapped;

@end
