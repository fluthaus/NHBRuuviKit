//
//  NSData+RKEddystone_Tests.m
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import <XCTest/XCTest.h>
#import "RKTestData.h"
#import "NSData+RKEddystone.h"

@interface NSData_RKEddystone_Tests : XCTestCase
@end

@implementation NSData_RKEddystone_Tests

-(void)test_frameType
{
	XCTAssertEqual( kRKEddystoneFrameType_Invalid, [NSData data].RKEddystoneFrameType);

	uint8_t frame[18];
	NSData* frameData = [NSData dataWithBytesNoCopy:frame length:sizeof(frame) freeWhenDone:NO];

	frame[0] = 0x17; // non-specified frame type
	XCTAssertEqual( kRKEddystoneFrameType_Invalid, frameData.RKEddystoneFrameType);

	frame[0] = 0x40; // RESERVED frame type
	XCTAssertEqual( kRKEddystoneFrameType_RESERVED, frameData.RKEddystoneFrameType);

	NSData* shortFrameData = [NSData dataWithBytesNoCopy:frame length:1 freeWhenDone:NO];

	frame[0] = 0x00;
	XCTAssertEqual( kRKEddystoneFrameType_UID, frameData.RKEddystoneFrameType);
	XCTAssertEqual( kRKEddystoneFrameType_Invalid, shortFrameData.RKEddystoneFrameType);

	frame[0] = 0x10;
	XCTAssertEqual( kRKEddystoneFrameType_URL, frameData.RKEddystoneFrameType);
	XCTAssertEqual( kRKEddystoneFrameType_Invalid, shortFrameData.RKEddystoneFrameType);

	frame[0] = 0x20;
	XCTAssertEqual( kRKEddystoneFrameType_TLM, frameData.RKEddystoneFrameType);
	XCTAssertEqual( kRKEddystoneFrameType_Invalid, shortFrameData.RKEddystoneFrameType);

	frame[0] = 0x30;
	XCTAssertEqual( kRKEddystoneFrameType_EID, frameData.RKEddystoneFrameType);
	XCTAssertEqual( kRKEddystoneFrameType_Invalid, shortFrameData.RKEddystoneFrameType);
}

-(void)test_TxPowerValid
{
	uint8_t bytes[18] = { 0x00};
	NSData*	data = [NSData dataWithBytesNoCopy:bytes length:sizeof(bytes) freeWhenDone:NO];

	bytes[0] = kRKEddystoneFrameType_UID;
	XCTAssertNotNil( data.RKEddystoneTxPower);

	bytes[0] = kRKEddystoneFrameType_URL;
	XCTAssertNotNil( data.RKEddystoneTxPower);

	bytes[0] = kRKEddystoneFrameType_TLM;
	XCTAssertNotNil( data.RKEddystoneTxPower);

	bytes[0] = kRKEddystoneFrameType_EID;
	XCTAssertNotNil( data.RKEddystoneTxPower);

	bytes[0] = kRKEddystoneFrameType_RESERVED;
	XCTAssertNil( data.RKEddystoneTxPower);

	bytes[0] = 0xFF;
	XCTAssertNil( data.RKEddystoneTxPower);
}

#pragma mark - UID

-(void)test_UID
{
	uint8_t namespace[] = { 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99 };
	uint8_t instance[] = { 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };
	NSData* namespaceData = [NSData dataWithBytes:namespace length:sizeof(namespace)];
	NSData* instanceData = [NSData dataWithBytes:instance length:sizeof(instance)];

	NSData* data = [NSData dataWithBytes:eddystone0x00_data length:sizeof(eddystone0x00_data)];

	XCTAssertEqual( kRKEddystoneFrameType_UID, data.RKEddystoneFrameType);
	XCTAssertEqualObjects( @(18), data.RKEddystoneTxPower);

	XCTAssertEqualObjects( namespaceData, data.RKEddystoneUIDNamespace);
	XCTAssertEqualObjects( instanceData, data.RKEddystoneUIDInstance);
}

-(void)test_UIDInvalid
{
	uint8_t bytes[18] = { 0xFF};
	NSData*	data = [NSData dataWithBytesNoCopy:bytes length:sizeof(bytes) freeWhenDone:NO];

	XCTAssertNil( data.RKEddystoneUIDNamespace);
	XCTAssertNil( data.RKEddystoneUIDInstance);
}

#pragma mark - URL

-(void)test_URL
{
	NSData* data = [NSData dataWithBytes:eddystone0x10_data length:sizeof(eddystone0x10_data)];

	XCTAssertEqual( kRKEddystoneFrameType_URL, data.RKEddystoneFrameType);
	XCTAssertEqualObjects( @(-18), data.RKEddystoneTxPower);

	XCTAssertEqualObjects( [NSURL URLWithString:@"https://ruu.vi/setupFAIL"], data.RKEddystoneURL);
}

-(void)test_URLSchemePrefix
{
	uint8_t url[] = { 0x10, 0x00, 0x00, 'f', 'o', 'o', '.', 'b', 'a', 'r'};
	NSData* urlData = [NSData dataWithBytesNoCopy:url length:sizeof(url) freeWhenDone:NO];

	url[2] = 0x00;
	XCTAssertEqualObjects( [NSURL URLWithString:@"http://www.foo.bar"], urlData.RKEddystoneURL);
	url[2] = 0x01;
	XCTAssertEqualObjects( [NSURL URLWithString:@"https://www.foo.bar"], urlData.RKEddystoneURL);
	url[2] = 0x02;
	XCTAssertEqualObjects( [NSURL URLWithString:@"http://foo.bar"], urlData.RKEddystoneURL);
	url[2] = 0x03;
	XCTAssertEqualObjects( [NSURL URLWithString:@"https://foo.bar"], urlData.RKEddystoneURL);

	url[2] = 0x04; // invalid scheme
	XCTAssertNil( urlData.RKEddystoneURL);
}

-(void)test_URLEncoding
{
	__block uint8_t url[] = { 0x10, 0x00, 0x03, 'f', 'o', 'o', 0x00};
	NSData* urlData = [NSData dataWithBytesNoCopy:url length:sizeof(url) freeWhenDone:NO];

	NSArray* urlEncoding = @[ @".com/", @".org/", @".edu/", @".net/", @".info/", @".biz/", @".gov/", @".com",  @".org",  @".edu",  @".net",  @".info",  @".biz",  @".gov"];
	[urlEncoding enumerateObjectsUsingBlock:
		^(NSString* _Nonnull encoding, NSUInteger i, BOOL * _Nonnull stop)
		{
			((uint8_t*)urlData.bytes)[6] = i;
			XCTAssertEqualObjects( urlData.RKEddystoneURL, [NSURL URLWithString:[@"https://foo" stringByAppendingString:encoding]]);
		}];
}

-(void)test_URLInvalid
{
	uint8_t bytes[18] = { 0x00};
	NSData*	data = [NSData dataWithBytesNoCopy:bytes length:sizeof(bytes) freeWhenDone:NO];

	XCTAssertNil( data.RKEddystoneURL);
}

-(void)test_URLInvalidCharacter
{
	uint8_t bytes[] = { 0x10, 0x00, 0x00, ' ' }; // space is not allowed
	NSData* data = [NSData dataWithBytesNoCopy:bytes length:sizeof(bytes) freeWhenDone:NO];

	XCTAssertNil( data.RKEddystoneURL);
}

#pragma mark - TLM

-(void)test_TLM
{
	NSData* data = [NSData dataWithBytes:eddystone0x20_data length:sizeof(eddystone0x20_data)];

	XCTAssertEqual( kRKEddystoneFrameType_TLM, data.RKEddystoneFrameType);
	XCTAssertEqualObjects( @(0), data.RKEddystoneTxPower);

	XCTAssertEqual( kRKEddystoneTLMVersion_Default, data.RKEddystoneTLMVersion);
	XCTAssertEqualObjects( @(3210), data.RKEddystoneTLMBatteryVoltage);
	XCTAssertEqualWithAccuracy( 25.5, data.RKEddystoneTLMTemperature.doubleValue, 0.000001);
	XCTAssertEqualObjects( @(88), data.RKEddystoneTLMAdvPDUCount);
	XCTAssertEqualObjects( @(455), data.RKEddystoneTLMUptime);
}

-(void)test_TLMTemperatureUnsupported
{
	uint8_t tlm[14] = { 0x20, 0x00, 0x0C, 0x8A, 0x80, 0x00 };
	NSData* tlmData = [NSData dataWithBytesNoCopy:tlm length:sizeof(tlm) freeWhenDone:NO];

	XCTAssertEqualObjects( nil, tlmData.RKEddystoneTLMTemperature);
}

-(void)test_TLMBatteryUnsupported
{
	uint8_t tlm[14] = { 0x20, 0x00, 0x00 };
	NSData* tlmData = [NSData dataWithBytesNoCopy:tlm length:sizeof(tlm) freeWhenDone:NO];

	XCTAssertEqualObjects( nil, tlmData.RKEddystoneTLMBatteryVoltage);
}

-(void)test_TLMInvalid
{
	uint8_t bytes[18] = { 0x00};
	NSData*	data = [NSData dataWithBytesNoCopy:bytes length:sizeof(bytes) freeWhenDone:NO];

	XCTAssertEqual( kRKEddystoneTLMVersion_Invalid, data.RKEddystoneTLMVersion);
	XCTAssertNil( data.RKEddystoneTLMBatteryVoltage);
	XCTAssertNil( data.RKEddystoneTLMTemperature);
	XCTAssertNil( data.RKEddystoneTLMAdvPDUCount);
	XCTAssertNil( data.RKEddystoneTLMUptime);
}

-(void)test_TLMEncrypted
{
	uint8_t bytes[18] = { 0x20, 0x01};
	NSData* data = [NSData dataWithBytes:bytes length:sizeof(bytes)];

	XCTAssertEqual( kRKEddystoneTLMVersion_Encrypted, data.RKEddystoneTLMVersion);
	XCTAssertEqual( 16, data.RKEddystoneTLMEncryptedPayload.length);
}

-(void)test_TLMEncryptedInvalid
{
	uint8_t bytes[14] = { 0x20, 0x01};
	NSData* data = [NSData dataWithBytes:bytes length:sizeof(bytes)];

	XCTAssertEqual( kRKEddystoneTLMVersion_Invalid, data.RKEddystoneTLMVersion);
	XCTAssertEqualObjects( nil, data.RKEddystoneTLMEncryptedPayload);
}

#pragma mark - EID

-(void)test_EIDIdentifier
{
	uint8_t eid[10] = { 0x30, 0x00, 0xDE, 0xAD, 0xBE, 0xEF, 0xCA, 0xFE, 0xBA, 0xBE };
	NSData* eidData = [NSData dataWithBytesNoCopy:eid length:sizeof(eid) freeWhenDone:NO];

	uint64_t deadbeefcafebabe = NSSwapHostLongLongToBig( 0xDEADBEEFCAFEBABE);
	XCTAssertEqualObjects( [NSData dataWithBytes:&deadbeefcafebabe length:sizeof(deadbeefcafebabe)], eidData.RKEddystoneEIDEphemeralIdentifier);
}

-(void)test_EIDInvalid
{
	uint8_t bytes[18] = { 0xFF };
	NSData*	data = [NSData dataWithBytesNoCopy:bytes length:sizeof(bytes) freeWhenDone:NO];

	XCTAssertNil( data.RKEddystoneEIDEphemeralIdentifier);
}

@end
