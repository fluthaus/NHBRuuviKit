//
//  RKRuuviDataBase64URLEncoding_Tests.m
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

@interface RKRuuviDataBase64URLEncoding_Tests : XCTestCase
@end

@implementation RKRuuviDataBase64URLEncoding_Tests

-(void)test_decodeZeros
{
	RKRuuviData* decoded = [RKRuuviData ruuviDataFromBase64URLRuuviEncodedString:@"AAAAAAAAA"];

	uint8_t b[7] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	NSData* data = [NSData dataWithBytesNoCopy:b length:sizeof(b) freeWhenDone:NO];

	XCTAssert( memcmp( data.bytes, decoded.bytes, decoded.length) == 0);
}

-(void)test_decodeOnes
{
	RKRuuviData* decoded = [RKRuuviData ruuviDataFromBase64URLRuuviEncodedString:@"_________"];

	uint8_t b[7] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFC};
	NSData* data = [NSData dataWithBytesNoCopy:b length:sizeof(b) freeWhenDone:NO];

	XCTAssert( memcmp( data.bytes, decoded.bytes, decoded.length) == 0);
}

-(void)test_nil
{
	XCTAssertEqualObjects( [RKRuuviData ruuviDataFromBase64URLRuuviEncodedString:nil], nil);
}

-(void)test_multipleLengths
{
	NSString* string = @"";
	uint8_t bytes[16] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,};
	for (int i = 0; i < 16; i++)
	{
		RKRuuviData* data = [RKRuuviData ruuviDataFromBase64URLRuuviEncodedString:string];
		XCTAssertNotNil( data);
		XCTAssertEqual( memcmp( data.bytes, bytes, data.length), 0);

		string = [string stringByAppendingString:@"A"];
	}
}

@end
