//
//  RKRuuviData.h
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import <Foundation/Foundation.h>

#ifndef RKRUUVIDATA_H
#define RKRUUVIDATA_H

// error domain and code for NSError instances returned by ruuviDataFromAdvertisement:error: / sent to the scanner delegate

extern NSErrorDomain _Nonnull const kRKErrorDomain;

typedef NS_ENUM( NSInteger, RKErrorCode_t)
{
	kRKErrorCode_InvalidRuuviData = -1,
};

// typedefs and constants used by accessor method

typedef NS_ENUM( uint8_t, RKRuuviFormat_t)
{
	kRKRuuviFormat_Invalid = 0, // unknown format, or data block to small
	kRKRuuviFormat_2 = 2,  // EddystoneURL-encoded, reduced precision
	kRKRuuviFormat_3 = 3,  // manufacturer data, raw v1
	kRKRuuviFormat_4 = 4,  // EddystoneURL-encoded, reduced precision + random id
	kRKRuuviFormat_5 = 5,  // manufacturer data, raw v2
};

typedef NS_ENUM( uint8_t, RKRuuviAxis_t)
{
	kRKRuuviAxis_X = 0,
	kRKRuuviAxis_Y = 2,
	kRKRuuviAxis_Z = 4,
};

/*!
@class RKRuuviData
@discussion Wrapper for the payload (sensor readings etc.) of a ruuvi advertisement. Used by RKRuuviScanner to pass ruuvi advertisements to its delegate.
*/

@interface RKRuuviData : NSObject

/// @param advertisementDictionary Advertisement data dictionary as received from CoreBluetooth
/// @param outError If the advertisement contains ruuvi data, but the ruuvi data is invalid, on return this will point to a NSError with a kRKErrorDomain domain, a code defined in RKErrorCode_t and no userInfo. Is nil if not a ruuvi advertisement at all, or ruuvi data is valid. Pass nil if you're not interested in this error
/// @return RKRuuviData instance with ruuvi raw1 or raw2 encoded data, or nil if invalid or no ruuvi data at all was found in advertisement

+(nullable RKRuuviData*)ruuviDataFromCBAdvertisementDictionary:(nonnull NSDictionary<NSString*,id>*)advertisementDictionary error:(NSError* _Nullable *_Nullable)outError;

#pragma mark - Accessors

/// @return Format (2..5) id or kRKRuuviFormat_Invalid if format is unknown, or data is to small for format
-(RKRuuviFormat_t)ruuviFormatID;

/// @return Temperature (°C), nil if invalid or n/a in format
-(nullable NSNumber*)ruuviTemperature;

/// @return Relative humidity (%), nil if invalid or n/a in format
-(nullable NSNumber*)ruuviHumidity;

/// @return Pressure (Pa), nil if invalid or n/a in format
-(nullable NSNumber*)ruuviPressure;

/// @return Battery voltage (mV), nil if invalid or n/a in format
-(nullable NSNumber*)ruuviBatteryVoltage;

/// @param axis Axis to query
/// @return Acceleration (mG), nil if invalid or n/a in format
-(nullable NSNumber*)ruuviAccelerationForAxis:(RKRuuviAxis_t)axis;

/// @return random id (0 - 63, raw value from data), nil if not format 4
-(nullable NSNumber*)ruuviRandomID;

/// Instead of the raw value from the data, commonly a 'mapped' value derived from the last character of the base64URL encoded data is used for the random id.
/// @return random id (numerical value of char from base64URL encoding), nil if not format 4
-(nullable NSNumber*)ruuviRandomIDB64Mapped;

/// @return Tx Power (dBm), nil if invalid or not format 5
-(nullable NSNumber*)ruuviTxPower;

/// @return movement counter, nil if invalid or not format 5
-(nullable NSNumber*)ruuviMovementCounter;

/// @return measurement sequence number, nil if invalid or not format 5
-(nullable NSNumber*)ruuviMeasurementSequenceNumber;

/// @return 48bit MAC address, nil if invalid or not format 5
-(nullable NSData*)ruuviMACAddress;

@end

#endif

