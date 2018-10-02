//
//  NHBRuuviKitFuzzing.m
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import "RKRuuviData.h"

#import "RKRuuviData+Testing.h"
#import <XCTest/XCTest.h>

// running all three fuzzing scenarios 1M times as defined below takes in the magnitude of an hour, depending on the machine.

#define FUZZ_RUUVI_GENERIC TRUE // enables general fuzzing
#define FUZZ_RUUVI_GENERIC_RNDS 100000000

#define FUZZ_EDDYSTONE_GENERIC TRUE // enables general fuzzing
#define FUZZ_EDDYSTONE_GENERIC_RNDS 100000000

#define FUZZ_EDDYSTONE_URL TRUE // enables specific URL fuzzing
#define FUZZ_EDDYSTONE_URL_RNDS 100000000

@interface NHBRuuviKitFuzzing : XCTestCase
@end

@implementation NHBRuuviKitFuzzing

#if FUZZ_RUUVI_GENERIC

-(void)test_fuzzRuuviGeneric
{
	for (int f = 0; f < FUZZ_RUUVI_GENERIC_RNDS; f++)
	{
		@autoreleasepool
		{
			size_t length = arc4random_uniform(25);
			void* buffer = malloc( length);
			arc4random_buf( buffer, length);
			RKRuuviData* ruuviData = [[RKRuuviData alloc] initWithBytes:buffer length:length];
			free( buffer);

			[ruuviData ruuviFormatID];
			[ruuviData ruuviTemperature];
			[ruuviData ruuviHumidity];
			[ruuviData ruuviPressure];
			[ruuviData ruuviAccelerationForAxis:kRKRuuviAxis_X];
			[ruuviData ruuviAccelerationForAxis:kRKRuuviAxis_Y];
			[ruuviData ruuviAccelerationForAxis:kRKRuuviAxis_Z];
			[ruuviData ruuviBatteryVoltage];
			[ruuviData ruuviMovementCounter];
			[ruuviData ruuviMeasurementSequenceNumber];
			[ruuviData ruuviRandomID];
			[ruuviData ruuviRandomIDB64Mapped];
			[ruuviData ruuviMACAddress];
			[ruuviData ruuviTxPower];
		}
	}
	XCTAssert( YES); // test is passed if fuzzing is survived
}

#endif

#if FUZZ_EDDYSTONE_GENERIC

-(void)test_fuzzEddystoneGeneric
{
	for (int f = 0; f < FUZZ_EDDYSTONE_GENERIC_RNDS; f++)
	{
		@autoreleasepool
		{
			NSMutableData* data = [NSMutableData dataWithLength:arc4random_uniform(21)];
			arc4random_buf( data.mutableBytes, data.length);

			[data RKEddystoneFrameType];
			[data RKEddystoneTxPower];
			// UID
			[data RKEddystoneUIDNamespace];
			[data RKEddystoneUIDInstance];
			// URL
			[data RKEddystoneURL];
			// TLM
			[data RKEddystoneTLMVersion];
			[data RKEddystoneTLMBatteryVoltage];
			[data RKEddystoneTLMTemperature];
			[data RKEddystoneTLMAdvPDUCount];
			[data RKEddystoneTLMUptime];
			// EID
			[data RKEddystoneEIDEphemeralIdentifier];
		}
	}
	XCTAssert( YES); // test is passed if fuzzing is survived
}

#endif

#if FUZZ_EDDYSTONE_URL

-(void)test_fuzzEddystoneURL
{
	uint8_t bytes[20] = {0x10};
	NSData* data = [NSData dataWithBytesNoCopy:bytes length:sizeof(bytes) freeWhenDone:NO];

	for (int f = 0; f < FUZZ_EDDYSTONE_URL_RNDS; f++)
	{
		@autoreleasepool
		{
			arc4random_buf( bytes, sizeof(bytes));
			[data RKEddystoneURL];
		}
	}
	XCTAssert( YES); // test is passed if fuzzing is survived
}

#endif

@end
