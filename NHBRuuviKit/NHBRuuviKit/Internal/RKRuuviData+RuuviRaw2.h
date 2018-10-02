//
//  RKRuuviData+RuuviRaw2.h
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

Low-level access to values in ruuvi format 5.

DO NOT use these methods; use the higher level methods from the RKRuuvi category on NSData. See 'NSData+RKRuuvi.h'.
These methods do not check bounds or the format of the data; when used without proper external checks, this may pose a security risk.

*/

@interface RKRuuviData (RuuviRaw2)

-(nullable NSNumber*)ruuviRaw2Temperature;
-(nullable NSNumber*)ruuviRaw2Humidity;
-(nullable NSNumber*)ruuviRaw2Pressure;
-(nullable NSNumber*)ruuviRaw2BatteryVoltage;
-(nullable NSNumber*)ruuviRaw2AccelerationForAxis:(RKRuuviAxis_t)axis;
-(nullable NSNumber*)ruuviRaw2TxPower;
-(nullable NSNumber*)ruuviRaw2MovementCounter;
-(nullable NSNumber*)ruuviRaw2MeasurementSequenceNumber;
-(nullable NSData*)ruuviRaw2MACAddress;

@end
