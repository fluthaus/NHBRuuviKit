//
//  RKRuuviData_FormatTests.m
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

@import NHBRuuviKit;
#import <XCTest/XCTest.h>
#import "RKRuuviData+Testing.h"

@interface RKRuuviData_FormatTests : XCTestCase
@end

@implementation RKRuuviData_FormatTests

-(void)test_formatUnknown
{
	uint8_t bytes[1] = { 6};
	RKRuuviData* data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqual( kRKRuuviFormat_Invalid, data.ruuviFormatID);
}

-(void)test_formatSizes
{
	uint8_t small[1], large[32];
	RKRuuviData *smallData, *largeData;

	small[0] = 0x02;
	large[0] = 0x02;
	smallData = [[RKRuuviData alloc] initWithBytes:small length:sizeof(small)];
	largeData = [[RKRuuviData alloc] initWithBytes:large length:sizeof(large)];
	XCTAssertEqual( kRKRuuviFormat_Invalid, smallData.ruuviFormatID);
	XCTAssertEqual( kRKRuuviFormat_2, largeData.ruuviFormatID);

	small[0] = 0x03;
	large[0] = 0x03;
	smallData = [[RKRuuviData alloc] initWithBytes:small length:sizeof(small)];
	largeData = [[RKRuuviData alloc] initWithBytes:large length:sizeof(large)];
	XCTAssertEqual( kRKRuuviFormat_Invalid, smallData.ruuviFormatID);
	XCTAssertEqual( kRKRuuviFormat_3, largeData.ruuviFormatID);

	small[0] = 0x04;
	large[0] = 0x04;
	smallData = [[RKRuuviData alloc] initWithBytes:small length:sizeof(small)];
	largeData = [[RKRuuviData alloc] initWithBytes:large length:sizeof(large)];
	XCTAssertEqual( kRKRuuviFormat_Invalid, smallData.ruuviFormatID);
	XCTAssertEqual( kRKRuuviFormat_4, largeData.ruuviFormatID);

	small[0] = 0x05;
	large[0] = 0x05;
	smallData = [[RKRuuviData alloc] initWithBytes:small length:sizeof(small)];
	largeData = [[RKRuuviData alloc] initWithBytes:large length:sizeof(large)];
	XCTAssertEqual( kRKRuuviFormat_Invalid, smallData.ruuviFormatID);
	XCTAssertEqual( kRKRuuviFormat_5, largeData.ruuviFormatID);
}

-(void)test_formatInvalid
{
	RKRuuviData* data = [[RKRuuviData alloc] init];

	XCTAssertEqual( kRKRuuviFormat_Invalid, data.ruuviFormatID);

	// invalid format n/a:
	XCTAssertEqualObjects( nil, data.ruuviTemperature);
	XCTAssertEqualObjects( nil, data.ruuviHumidity);
	XCTAssertEqualObjects( nil, data.ruuviPressure);
	XCTAssertEqualObjects( nil, [data ruuviAccelerationForAxis:kRKRuuviAxis_X]);
	XCTAssertEqualObjects( nil, [data ruuviAccelerationForAxis:kRKRuuviAxis_Y]);
	XCTAssertEqualObjects( nil, [data ruuviAccelerationForAxis:kRKRuuviAxis_Z]);
	XCTAssertEqualObjects( nil, data.ruuviBatteryVoltage);
	XCTAssertEqualObjects( nil, data.ruuviRandomID);
	XCTAssertEqualObjects( nil, data.ruuviRandomIDB64Mapped);
	XCTAssertEqualObjects( nil, data.ruuviTxPower);
	XCTAssertEqualObjects( nil, data.ruuviMovementCounter);
	XCTAssertEqualObjects( nil, data.ruuviMeasurementSequenceNumber);
	XCTAssertEqualObjects( nil, data.ruuviMACAddress);
}

-(void)test_format2
{
	uint8_t bytes[6] = { 0x02, 0x00, 0x00, 0x00, 0x00, 0x00};
	RKRuuviData* data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];

	XCTAssertEqual( kRKRuuviFormat_2, data.ruuviFormatID);

	XCTAssertEqualObjects( @(0), data.ruuviTemperature);
	XCTAssertEqualObjects( @(0), data.ruuviHumidity);
	XCTAssertEqualObjects( @(50000), data.ruuviPressure);

	// format 2 n/a:
	XCTAssertEqualObjects( nil, [data ruuviAccelerationForAxis:kRKRuuviAxis_X]);
	XCTAssertEqualObjects( nil, [data ruuviAccelerationForAxis:kRKRuuviAxis_Y]);
	XCTAssertEqualObjects( nil, [data ruuviAccelerationForAxis:kRKRuuviAxis_Z]);
	XCTAssertEqualObjects( nil, data.ruuviBatteryVoltage);
	XCTAssertEqualObjects( nil, data.ruuviRandomID);
	XCTAssertEqualObjects( nil, data.ruuviRandomIDB64Mapped);
	XCTAssertEqualObjects( nil, data.ruuviTxPower);
	XCTAssertEqualObjects( nil, data.ruuviMovementCounter);
	XCTAssertEqualObjects( nil, data.ruuviMeasurementSequenceNumber);
	XCTAssertEqualObjects( nil, data.ruuviMACAddress);
}

-(void)test_format3
{
	uint8_t bytes[14] = { 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	RKRuuviData* data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];

	XCTAssertEqual( kRKRuuviFormat_3, data.ruuviFormatID);

	XCTAssertEqualObjects( @(0), data.ruuviTemperature);
	XCTAssertEqualObjects( @(0), data.ruuviHumidity);
	XCTAssertEqualObjects( @(50000), data.ruuviPressure);
	XCTAssertEqualObjects( @(0), [data ruuviAccelerationForAxis:kRKRuuviAxis_X]);
	XCTAssertEqualObjects( @(0), [data ruuviAccelerationForAxis:kRKRuuviAxis_Y]);
	XCTAssertEqualObjects( @(0), [data ruuviAccelerationForAxis:kRKRuuviAxis_Z]);
	XCTAssertEqualObjects( @(0), data.ruuviBatteryVoltage);

	// format 3 n/a:
	XCTAssertEqualObjects( nil, data.ruuviTxPower);
	XCTAssertEqualObjects( nil, data.ruuviMovementCounter);
	XCTAssertEqualObjects( nil, data.ruuviMeasurementSequenceNumber);
	XCTAssertEqualObjects( nil, data.ruuviMACAddress);
	XCTAssertEqualObjects( nil, data.ruuviRandomID);
	XCTAssertEqualObjects( nil, data.ruuviRandomIDB64Mapped);
}

-(void)test_format4
{
	uint8_t bytes[7] = { 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	RKRuuviData* data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];

	XCTAssertEqual( kRKRuuviFormat_4, data.ruuviFormatID);

	XCTAssertEqualObjects( @(0), data.ruuviTemperature);
	XCTAssertEqualObjects( @(0), data.ruuviHumidity);
	XCTAssertEqualObjects( @(50000), data.ruuviPressure);
	XCTAssertEqualObjects( @(0), data.ruuviRandomID);
	XCTAssertEqualObjects( @(65), data.ruuviRandomIDB64Mapped);

	// format 4 n/a:
	XCTAssertEqualObjects( nil, [data ruuviAccelerationForAxis:kRKRuuviAxis_X]);
	XCTAssertEqualObjects( nil, [data ruuviAccelerationForAxis:kRKRuuviAxis_Y]);
	XCTAssertEqualObjects( nil, [data ruuviAccelerationForAxis:kRKRuuviAxis_Z]);
	XCTAssertEqualObjects( nil, data.ruuviBatteryVoltage);
	XCTAssertEqualObjects( nil, data.ruuviTxPower);
	XCTAssertEqualObjects( nil, data.ruuviMovementCounter);
	XCTAssertEqualObjects( nil, data.ruuviMeasurementSequenceNumber);
	XCTAssertEqualObjects( nil, data.ruuviMACAddress);
}

-(void)test_format5
{
	uint8_t bytes[24] = { 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	RKRuuviData* data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];

	uint8_t mac[6] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	RKRuuviData* macData = [[RKRuuviData alloc] initWithBytes:mac length:sizeof(mac)];

	XCTAssertEqual( kRKRuuviFormat_5, data.ruuviFormatID);

	XCTAssertEqualObjects( @(0), data.ruuviTemperature);
	XCTAssertEqualObjects( @(0), data.ruuviHumidity);
	XCTAssertEqualObjects( @(50000), data.ruuviPressure);
	XCTAssertEqualObjects( @(0), [data ruuviAccelerationForAxis:kRKRuuviAxis_X]);
	XCTAssertEqualObjects( @(0), [data ruuviAccelerationForAxis:kRKRuuviAxis_Y]);
	XCTAssertEqualObjects( @(0), [data ruuviAccelerationForAxis:kRKRuuviAxis_Z]);
	XCTAssertEqualObjects( @(1600), data.ruuviBatteryVoltage);
	XCTAssertEqualObjects( @(-40), data.ruuviTxPower);
	XCTAssertEqualObjects( @(0), data.ruuviMovementCounter);
	XCTAssertEqualObjects( @(0), data.ruuviMeasurementSequenceNumber);
	XCTAssert( memcmp( data.ruuviMACAddress.bytes, macData.bytes, macData.length) == 0);

	// format 5 n/a:
	XCTAssertEqualObjects( nil, data.ruuviRandomID);
	XCTAssertEqualObjects( nil, data.ruuviRandomIDB64Mapped);
}

@end
