//
//  RKRuuviData+RuuviRaw2.m
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

// https://github.com/ruuvi/ruuvi-sensor-protocols/tree/feature-add-v5

#import "RKRuuviData+RuuviRaw2.h"
#import "RKRuuviData+Private.h"
#import "RK_DATA_GET.h"

@implementation RKRuuviData (RuuviRaw2)

// offsets according to documentation
NS_ENUM( size_t)
{
	kRKRuuviRaw2_Offset_Temperature = 1,
	kRKRuuviRaw2_Offset_Humidity = 3,
	kRKRuuviRaw2_Offset_Pressure = 5,
	kRKRuuviRaw2_Offset_Acceleration = 7,
	kRKRuuviRaw2_Offset_PowerInfo = 13,
	kRKRuuviRaw2_Offset_MovementCounter = 15,
	kRKRuuviRaw2_Offset_MeasurementSequenceNumber = 16,
	kRKRuuviRaw2_Offset_MACAddress = 18,
};

const uint8_t kRKRuuviRaw2_InvalidMAC[6] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};

-(nullable NSNumber*)ruuviRaw2Temperature
{
	int16_t const temperature = NSSwapBigShortToHost( RK_DATA_GET( uint16_t, kRKRuuviRaw2_Offset_Temperature));
	if (temperature != (int16_t)0x8000)
	 	return @(temperature * .005);
	return nil;
}

-(nullable NSNumber*)ruuviRaw2Humidity
{
	uint16_t const humidity = NSSwapBigShortToHost( RK_DATA_GET( uint16_t, kRKRuuviRaw2_Offset_Humidity));
	if (humidity != 65535)
	 	return @(humidity * .0025);
 	return nil;
}

-(nullable NSNumber*)ruuviRaw2Pressure
{
	uint16_t const pressure = NSSwapBigShortToHost( RK_DATA_GET( uint16_t, kRKRuuviRaw2_Offset_Pressure));
	if (pressure != 65535)
	 	return @((uint32_t)pressure + 50000);
 	return nil;
}

-(nullable NSNumber*)ruuviRaw2AccelerationForAxis:(RKRuuviAxis_t)axis
{
	int16_t const acceleration = NSSwapBigShortToHost( RK_DATA_GET( int16_t, kRKRuuviRaw2_Offset_Acceleration + axis));
	if (acceleration != (int16_t)0x8000)
		return @(acceleration);
	return nil;
}

-(nullable NSNumber*)ruuviRaw2BatteryVoltage
{
	uint16_t const batteryVoltage = ((NSSwapBigShortToHost( RK_DATA_GET( uint16_t, kRKRuuviRaw2_Offset_PowerInfo)) >> 5) & 0b11111111111);
	if (batteryVoltage != 2047)
	 	return @(batteryVoltage + 1600);
	return nil;
}

-(nullable NSNumber*)ruuviRaw2TxPower
{
	uint16_t const txPower = NSSwapBigShortToHost( RK_DATA_GET( uint16_t, kRKRuuviRaw2_Offset_PowerInfo)) & 0b11111;
	if (txPower != 31)
	 	return @(txPower * 2 - 40);
	return nil;
}

-(nullable NSNumber*)ruuviRaw2MovementCounter
{
	uint8_t const movementCounter = RK_DATA_GET( uint8_t, kRKRuuviRaw2_Offset_MovementCounter);
	if (movementCounter != 255)
	 	return @(movementCounter);
 	return nil;
}

-(nullable NSNumber*)ruuviRaw2MeasurementSequenceNumber
{
	uint16_t const measuremenSequenceNumber = NSSwapBigShortToHost( RK_DATA_GET( uint16_t, kRKRuuviRaw2_Offset_MeasurementSequenceNumber));
	if (measuremenSequenceNumber != 65535)
	 	return @(measuremenSequenceNumber);
	return nil;
}

-(nullable NSData*)ruuviRaw2MACAddress
{
	NSData* const MACData = [NSData dataWithBytes:(self.bytes + kRKRuuviRaw2_Offset_MACAddress) length:6];
	if (memcmp( MACData.bytes, kRKRuuviRaw2_InvalidMAC, MIN( MACData.length, sizeof( kRKRuuviRaw2_InvalidMAC))) != 0)
	 	return MACData;
 	return nil;
}

@end
