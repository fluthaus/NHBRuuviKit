//
//  RKRuuviData+RKRuuviRaw2_Tests.m
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

@interface RKRuuviData_RKRuuviRaw2_Tests : XCTestCase
@end

@implementation RKRuuviData_RKRuuviRaw2_Tests

-(void)test_valuesFromSpec
{
	uint8_t bytes[24] = { 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	RKRuuviData* data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];

	XCTAssertEqual( kRKRuuviFormat_5, data.ruuviFormatID);

	// temperature
	*(uint16_t*)(bytes + 1) = NSSwapHostShortToBig( 0x0000);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(0), data.ruuviTemperature);
	*(uint16_t*)(bytes + 1) = NSSwapHostShortToBig( 0x01C3);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(2.255), data.ruuviTemperature);
	*(uint16_t*)(bytes + 1) = NSSwapHostShortToBig( 0xFE3D);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(-2.255), data.ruuviTemperature);
	*(uint16_t*)(bytes + 1) = NSSwapHostShortToBig( 0x8000);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( nil, data.ruuviTemperature);

	// humidity
	*(uint16_t*)(bytes + 3) = NSSwapHostShortToBig( 0);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(0), data.ruuviHumidity);
	*(uint16_t*)(bytes + 3) = NSSwapHostShortToBig( 10010);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssert( fabs( 25.025 - data.ruuviHumidity.doubleValue) < 0.00000001);    // bug in spec!
	*(uint16_t*)(bytes + 3) = NSSwapHostShortToBig( 40000);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssert( fabs( 100. - data.ruuviHumidity.doubleValue) < 0.000001);
	*(uint16_t*)(bytes + 3) = NSSwapHostShortToBig( 65535);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( nil, data.ruuviHumidity);

	// pressure
	*(uint16_t*)(bytes + 5) = NSSwapHostShortToBig( 0);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(50000), data.ruuviPressure);
	*(uint16_t*)(bytes + 5) = NSSwapHostShortToBig( 51325);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(101325), data.ruuviPressure);
	*(uint16_t*)(bytes + 5) = NSSwapHostShortToBig( 65534);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(115534), data.ruuviPressure);
	*(uint16_t*)(bytes + 5) = NSSwapHostShortToBig( 65535);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( nil, data.ruuviPressure);

	// acceleration
	*(uint16_t*)(bytes + 7) = NSSwapHostShortToBig( 0xFC18);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(-1000), [data ruuviAccelerationForAxis:kRKRuuviAxis_X]);
	*(uint16_t*)(bytes + 9) = NSSwapHostShortToBig( 0x03E8);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(1000), [data ruuviAccelerationForAxis:kRKRuuviAxis_Y]);
	*(uint16_t*)(bytes + 11) = NSSwapHostShortToBig( 0x8000);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( nil, [data ruuviAccelerationForAxis:kRKRuuviAxis_Z]);

	// battery voltage
	*(uint16_t*)(bytes + 13) = NSSwapHostShortToBig( 0 << 5);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(1600), data.ruuviBatteryVoltage);
	*(uint16_t*)(bytes + 13) = NSSwapHostShortToBig( 1400 << 5);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(3000), data.ruuviBatteryVoltage);
	*(uint16_t*)(bytes + 13) = NSSwapHostShortToBig( 2047 << 5);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( nil, data.ruuviBatteryVoltage);

	// tx power
	*(uint16_t*)(bytes + 13) = NSSwapHostShortToBig( 0);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(-40), data.ruuviTxPower);
	*(uint16_t*)(bytes + 13) = NSSwapHostShortToBig( 22);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(4), data.ruuviTxPower);
	*(uint16_t*)(bytes + 13) = NSSwapHostShortToBig( 31);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( nil, data.ruuviTxPower);

	// movement counter
	*(uint8_t*)(bytes + 15) = 0;
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(0), data.ruuviMovementCounter);
	*(uint8_t*)(bytes + 15) = 100;
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(100), data.ruuviMovementCounter);
	*(uint8_t*)(bytes + 15) = 255;
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( nil, data.ruuviMovementCounter);

	// measurement sequence number
	*(uint16_t*)(bytes + 16) = NSSwapHostShortToBig( 0);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(0), data.ruuviMeasurementSequenceNumber);
	*(uint16_t*)(bytes + 16) = NSSwapHostShortToBig( 1000);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( @(1000), data.ruuviMeasurementSequenceNumber);
	*(uint16_t*)(bytes + 16) = NSSwapHostShortToBig( 65535);
	data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];
	XCTAssertEqualObjects( nil, data.ruuviMeasurementSequenceNumber);

	// specs give no battery voltage examples
}

-(void)test_invalidMAC
{
	uint8_t bytes[24] = { 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
	RKRuuviData* data = [[RKRuuviData alloc] initWithBytes:bytes length:sizeof(bytes)];

	XCTAssertNil( data.ruuviMACAddress);
}

@end
