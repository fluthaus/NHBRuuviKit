//
//  RKRuuviDataFromAdvertisement_Tests.m
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

@import CoreBluetooth;

#import <XCTest/XCTest.h>
#import "RKTestData.h"
#import "RKRuuviData.h"
#import "RKRuuviData+Testing.h"

@interface RKRuuviDataFromAdvertisement_Tests : XCTestCase
@end

@implementation RKRuuviDataFromAdvertisement_Tests

-(void)test_ruuvi3
{
	NSData* advData = [NSData dataWithBytes:ruuvi3_data length:sizeof(ruuvi3_data)];
	NSDictionary<NSString*,id>* advertisement = @{ CBAdvertisementDataManufacturerDataKey: advData};

	RKRuuviData* ruuviData = [RKRuuviData ruuviDataFromCBAdvertisementDictionary:advertisement error:nil];
	XCTAssert( memcmp( [advData subdataWithRange:NSMakeRange( 2, advData.length -2)].bytes, ruuviData.bytes, ruuviData.length) == 0);
}

-(void)test_ruuviEddystone
{
	NSData* advData = [NSData dataWithBytes:ruuviEddystone_data length:sizeof(ruuviEddystone_data)];
	CBUUID* eddystoneServiceUUID = [CBUUID UUIDWithString:@"FEAA"];
	NSDictionary<NSString*,id>* advertisement = @{ CBAdvertisementDataServiceDataKey: @{eddystoneServiceUUID:advData}, CBAdvertisementDataServiceUUIDsKey: @[eddystoneServiceUUID]};

	RKRuuviData* ruuviData = [RKRuuviData ruuviDataFromCBAdvertisementDictionary:advertisement error:nil];
	XCTAssertNotNil( ruuviData);
	XCTAssertEqual( ruuviData.ruuviFormatID, 4);
}

-(void)test_nonRuuviCompanyID
{
	uint8_t bytes[16] = { 0x01, 0x02, 0x03};
	NSData* advData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	NSDictionary<NSString*,id>* advertisement = @{ CBAdvertisementDataManufacturerDataKey: advData};

	RKRuuviData* ruuviData = [RKRuuviData ruuviDataFromCBAdvertisementDictionary:advertisement error:nil];
	XCTAssertEqualObjects( ruuviData, nil);
}

-(void)test_emptyData
{
	NSData* advData = [NSData data];
	NSDictionary<NSString*,id>* advertisement = @{ CBAdvertisementDataManufacturerDataKey: advData};

	RKRuuviData* ruuviData = [RKRuuviData ruuviDataFromCBAdvertisementDictionary:advertisement error:nil];
	XCTAssertEqualObjects( ruuviData, nil);
}

-(void)test_invalidData
{
	uint8_t bytes[16] = { 0x99, 0x04, 0x17};
	NSData* advData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	NSDictionary<NSString*,id>* advertisement = @{ CBAdvertisementDataManufacturerDataKey: advData};

	NSError* error = nil;
	RKRuuviData* ruuviData = [RKRuuviData ruuviDataFromCBAdvertisementDictionary:advertisement error:&error];
	XCTAssertEqualObjects( ruuviData, nil);
	XCTAssertNotNil( error);
	XCTAssertEqualObjects( error.domain, kRKErrorDomain);
	XCTAssertEqual( error.code, kRKErrorCode_InvalidRuuviData);
}

@end
