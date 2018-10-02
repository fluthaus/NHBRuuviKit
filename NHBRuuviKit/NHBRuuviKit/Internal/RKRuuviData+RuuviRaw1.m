//
//  RKRuuviData+RuuviRaw1.m
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import "RKRuuviData+RuuviRaw1.h"
#import "RKRuuviData+Private.h"
#import "RK_DATA_GET.h"

@implementation RKRuuviData (RKRuuviRaw1)

// offsets according to documentation
NS_ENUM( size_t)
{
	kRKRuuviRaw1_Offset_Humidity = 1,
	kRKRuuviRaw1_Offset_Temperature = 2,
	kRKRuuviRaw1_Offset_Pressure = 4,
	kRKRuuviRaw1_Offset_Acceleration = 6,
	kRKRuuviRaw1_Offset_RandomID = 6,
	kRKRuuviRaw1_Offset_BatteryVoltage = 12,
};

-(NSNumber*)ruuviRaw1Humidity
{
	uint8_t h = RK_DATA_GET( uint8_t, kRKRuuviRaw1_Offset_Humidity);
	if (h <= 200)
	 	return @(h *.5);
	else
		return nil;
}

-(NSNumber*)ruuviRaw1Temperature
{
	// temperature: 'MSB is sign, next 7 bits are decimal value, + LSB (fraction, 1/100.)'
	uint8_t temperatureMSB = RK_DATA_GET( uint8_t, kRKRuuviRaw1_Offset_Temperature);
	uint8_t temperatureLSB = RK_DATA_GET( uint8_t, kRKRuuviRaw1_Offset_Temperature + 1);
	if (temperatureLSB < 100)
		return @(((temperatureMSB & 0x7F) + (temperatureLSB / 100.)) * ((temperatureMSB & 0x80) == 0x80 ? -1. : 1.));
	else
	 	return nil;
}

-(NSNumber*)ruuviRaw1Pressure
{
	return @(((RK_DATA_GET( uint8_t, kRKRuuviRaw1_Offset_Pressure) << 8) + RK_DATA_GET( uint8_t, kRKRuuviRaw1_Offset_Pressure + 1)) + 50000);
}

-(NSNumber*)ruuviRaw1AccelerationForAxis:(RKRuuviAxis_t)axis
{
	size_t offset = kRKRuuviRaw1_Offset_Acceleration + axis;
	return @((int16_t)((RK_DATA_GET( int8_t, offset) << 8) + RK_DATA_GET( uint8_t, offset + 1)));
}

-(NSNumber*)ruuviRaw1BatteryVoltage
{
	return @((uint16_t)(RK_DATA_GET( uint8_t, kRKRuuviRaw1_Offset_BatteryVoltage) << 8) + RK_DATA_GET( uint8_t, kRKRuuviRaw1_Offset_BatteryVoltage + 1));
}

-(NSNumber*)ruuviRaw1RandomID
{
	return @(RK_DATA_GET( uint8_t, kRKRuuviRaw1_Offset_RandomID) >> 2);
}

-(NSNumber*)ruuviRaw1RandomIDB64mapped
{
	static uint8_t b64Mapping[64] = { 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 45, 95};
	return @(b64Mapping[RK_DATA_GET( uint8_t, kRKRuuviRaw1_Offset_RandomID) >> 2]);
}

@end
