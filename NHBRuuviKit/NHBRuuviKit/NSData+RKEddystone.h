//
//  NSData+RKEddystone.h
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import <Foundation/Foundation.h>

typedef NS_ENUM( NSInteger, RKEddystoneFrameType_t)
{
	kRKEddystoneFrameType_UID = 0x00,
	kRKEddystoneFrameType_URL = 0x10,
	kRKEddystoneFrameType_TLM = 0x20,
	kRKEddystoneFrameType_EID = 0x30,
	kRKEddystoneFrameType_RESERVED = 0x40,

	kRKEddystoneFrameType_Invalid = -1, // id not specified, or data to short to hold frame type
};

typedef NS_ENUM( NSInteger, RKEddystoneTLMVersion_t)
{
	kRKEddystoneTLMVersion_Default = 0x00,
	kRKEddystoneTLMVersion_Encrypted = 0x01,

	kRKEddystoneTLMVersion_Invalid = -1, // version not specified, or data to short to hold TLM frame
};

/**

A NSData category giving access to fields defined by the Eddystone beacon protocol (see https://github.com/google/eddystone/blob/master/protocol-specification.md)

Use with NSData instances stored in the services dictionary of Corebluetooth advertisements under the Eddystone service type, e.g.:

@code
CBUUID* eddystoneServiceUUID = [CBUUID UUIDWithString:@"FEAA"];
NSData* eddystonePayload = advertisementData[CBAdvertisementDataServiceDataKey][eddystoneServiceUUID];
@endcode

*/

@interface NSData (RKEddystone)

/// @return Frame type read from the data, if defined by the specs and data.length is sufficient for this frame type; otherwise kRKEddystoneFrameType_Invalid is returned
-(RKEddystoneFrameType_t)RKEddystoneFrameType;

/// @return TxPower of beacon, or nil if data length insufficient
-(nullable NSNumber*)RKEddystoneTxPower;

#pragma mark - Eddystone-UID, 0x00
/// @return UID namespace, or nil if not an UID frame or data length insufficient
-(nullable NSData*)RKEddystoneUIDNamespace;

/// @return UID instance, or nil if not an UID frame or data length insufficient
-(nullable NSData*)RKEddystoneUIDInstance;

#pragma mark - Eddystone-URL, 0x10
/// @return URL, or nil if not an URL frame or data length insufficient
-(nullable NSURL*)RKEddystoneURL;

#pragma mark - Eddystone-TLM 0x20
/// @return TLM version, or kRKEddystoneTLMVersion_Invalid if not a TLM frame
-(RKEddystoneTLMVersion_t)RKEddystoneTLMVersion;

/// @return Battery voltage (mV), or nil if not a TLM frame or data length insufficient
-(nullable NSNumber*)RKEddystoneTLMBatteryVoltage;

/// @return Temperature (°C), or nil if not a TLM frame or data length insufficient
-(nullable NSNumber*)RKEddystoneTLMTemperature;

/// @return Advertiseds PDU Count, or nil if not a TLM frame or data length insufficient
-(nullable NSNumber*)RKEddystoneTLMAdvPDUCount;

/// @return Time since boot (1/10s), or nil if not a TLM frame or data length insufficient
-(nullable NSNumber*)RKEddystoneTLMUptime;

/// @return 16 bytes of encrypted payload, consisting of 12 bytes ETLM data, 16 bit salt and 16 bit message integrity check; nil if not an encrypted TLM frame or data length insufficient
-(nullable NSData*)RKEddystoneTLMEncryptedPayload;

#pragma mark - Eddystone-EID 0x30
/// @return Ephemeral identifier, or nil if not an EID frame or size insufficient
-(nullable NSData*)RKEddystoneEIDEphemeralIdentifier;

@end
