//
//  NSData+RKManufacturerData_Tests.m
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import "NSData+RKManufacturerData.h"
#import <XCTest/XCTest.h>

@interface NSData_RKManufacturerData_Tests : XCTestCase

@end

@implementation NSData_RKManufacturerData_Tests

-(void)test_companyID
{
	NSData* data = [NSData data];
	XCTAssertEqual( kRKManufacturerDataCompanyID_Invalid, data.RKManufacturerDataCompanyID);

	uint8_t ruuvi[] = { 0x99, 0x04};
	data = [NSData dataWithBytes:ruuvi length:sizeof(ruuvi)];
	XCTAssertEqual( 0x0499, data.RKManufacturerDataCompanyID);
}


@end
