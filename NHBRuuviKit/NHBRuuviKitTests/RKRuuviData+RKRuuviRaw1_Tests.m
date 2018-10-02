//
//  RKRuuviData+RKRuuviRaw1_Tests.m
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

@import NHBRuuviKit;
#import <XCTest/XCTest.h>
#include "RKTestData.h"
#import "RKRuuviData+Testing.h"

@interface RKRuuviData_RKRuuviRaw1_Tests : XCTestCase
@end

@implementation RKRuuviData_RKRuuviRaw1_Tests

-(void)testCompanyID
{
    NSData* manufacturerData = [NSData dataWithBytes:ruuvi3_data length:sizeof( ruuvi3_data)];

	XCTAssertEqual( manufacturerData.RKManufacturerDataCompanyID, 0x0499);
}

-(void)test_realWorldData
{
    NSData* manufacturerData = [NSData dataWithBytes:ruuvi3_data length:sizeof( ruuvi3_data)];
	RKRuuviData* ruuvi3Data = [RKRuuviData ruuviDataFromManufacturerData:manufacturerData];

	XCTAssertEqual( ruuvi3Data.ruuviFormatID, kRKRuuviFormat_3);

	XCTAssertEqualObjects( @(23.62), ruuvi3Data.ruuviTemperature);
	XCTAssertEqualObjects( @( 49.5), ruuvi3Data.ruuviHumidity);
	XCTAssertEqualObjects( @(98638), ruuvi3Data.ruuviPressure);
	XCTAssertEqualObjects( @( 3025), ruuvi3Data.ruuviBatteryVoltage);
	XCTAssertEqualObjects( @(  -16), [ruuvi3Data ruuviAccelerationForAxis:kRKRuuviAxis_X]);
	XCTAssertEqualObjects( @(   -4), [ruuvi3Data ruuviAccelerationForAxis:kRKRuuviAxis_Y]);
	XCTAssertEqualObjects( @( 1008), [ruuvi3Data ruuviAccelerationForAxis:kRKRuuviAxis_Z]);
	XCTAssertEqualObjects( nil, ruuvi3Data.ruuviRandomID);
	XCTAssertEqualObjects( nil, ruuvi3Data.ruuviRandomIDB64Mapped);
}

-(void)test_noBitsSet
{
	unsigned char ruuvi3_noBitsSet[] = { 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	RKRuuviData* ruuvi3Data =  [[RKRuuviData alloc] initWithBytes:ruuvi3_noBitsSet length:sizeof( ruuvi3_noBitsSet)];

	XCTAssertEqual( ruuvi3Data.ruuviFormatID, kRKRuuviFormat_3);

	XCTAssertEqualObjects( @(0.), ruuvi3Data.ruuviTemperature);
	XCTAssertEqualObjects( @(0), ruuvi3Data.ruuviHumidity);
	XCTAssertEqualObjects( @(50000), ruuvi3Data.ruuviPressure);
	XCTAssertEqualObjects( @(0), ruuvi3Data.ruuviBatteryVoltage);
	XCTAssertEqualObjects( @(0), [ruuvi3Data ruuviAccelerationForAxis:kRKRuuviAxis_X]);
	XCTAssertEqualObjects( @(0), [ruuvi3Data ruuviAccelerationForAxis:kRKRuuviAxis_Y]);
	XCTAssertEqualObjects( @(0), [ruuvi3Data ruuviAccelerationForAxis:kRKRuuviAxis_Z]);
	XCTAssertEqualObjects( nil, ruuvi3Data.ruuviRandomID);
	XCTAssertEqualObjects( nil, ruuvi3Data.ruuviRandomIDB64Mapped);
}


-(void)test_allBitsSet
{
	unsigned char ruuvi3_allBitsSet[]  = { 0x03, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
	RKRuuviData* ruuvi3Data =  [[RKRuuviData alloc] initWithBytes:ruuvi3_allBitsSet length:sizeof( ruuvi3_allBitsSet)];

	XCTAssertEqualObjects( nil, ruuvi3Data.ruuviTemperature); // 0xFF in temperature LSB is > 99, so should be invalid
	XCTAssertEqualObjects( nil, ruuvi3Data.ruuviHumidity); // 0xFF is over 100%, so should be invalid
	XCTAssertEqualObjects( @(115535), ruuvi3Data.ruuviPressure);
	XCTAssertEqualObjects( @(65535), ruuvi3Data.ruuviBatteryVoltage);
	XCTAssertEqualObjects( @(-1), [ruuvi3Data ruuviAccelerationForAxis:kRKRuuviAxis_X]); // 2's complement
	XCTAssertEqualObjects( @(-1), [ruuvi3Data ruuviAccelerationForAxis:kRKRuuviAxis_Y]); // 2's complement
	XCTAssertEqualObjects( @(-1), [ruuvi3Data ruuviAccelerationForAxis:kRKRuuviAxis_Z]); // 2's complement
	XCTAssertEqualObjects( nil, ruuvi3Data.ruuviRandomID);
	XCTAssertEqualObjects( nil, ruuvi3Data.ruuviRandomIDB64Mapped);
}

-(void)test_valuesFromSpec
{
	uint8_t bytes[14] = { 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	RKRuuviData* data;

	// humidity
	*(bytes + 1) = 0;
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(0), data.ruuviHumidity);
	*(bytes + 1) = 128;
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(64), data.ruuviHumidity);
	*(bytes + 1) = 200;
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(100), data.ruuviHumidity);

	// temperature
	*(uint16_t*)(bytes + 2) = 0;
	XCTAssertEqualObjects( @(0), data.ruuviTemperature);
	*(uint16_t*)(bytes + 2) = NSSwapHostShortToBig( 0x8145);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(-1.69), data.ruuviTemperature);
	*(uint16_t*)(bytes + 2) = NSSwapHostShortToBig( 0x0145);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(1.69), data.ruuviTemperature);

	// pressure
	*(uint16_t*)(bytes + 4) = NSSwapHostShortToBig( 0);
	XCTAssertEqualObjects( @(50000), data.ruuviPressure);
	*(uint16_t*)(bytes + 4) = NSSwapHostShortToBig( 51325);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(101325), data.ruuviPressure);
	*(uint16_t*)(bytes + 4) = NSSwapHostShortToBig( 65535);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(115535), data.ruuviPressure);

	// acceleration
	*(bytes + 6) = 0xFC;
	*(bytes + 7) = 0x18;
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(-1000), [data ruuviAccelerationForAxis:kRKRuuviAxis_X]);
	*(bytes + 8) = 0x03;
	*(bytes + 9) = 0xE8;
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(1000), [data ruuviAccelerationForAxis:kRKRuuviAxis_Y]);

	// specs give no battery voltage examples
}

@end
