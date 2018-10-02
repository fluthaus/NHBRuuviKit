//
//  RKSRuuviTag_Tests.m
//
//  NHBRuuviKitSample
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import <XCTest/XCTest.h>
#import "RKSRuuviTag.h"

@interface RKSRuuviTag_Tests : XCTestCase
@end

@implementation RKSRuuviTag_Tests

-(void)test_init
{
	NSUUID* identifier = [NSUUID UUID];
	RKSRuuviTag* ruuviTag = [[RKSRuuviTag alloc] initWithCBIdentifier:identifier];

	XCTAssertNotNil( ruuviTag);
	XCTAssertNotNil( ruuviTag.CBIdentifier);
	XCTAssertEqualObjects( ruuviTag.CBIdentifier, identifier);
}

-(void)test_update
{
	RKSRuuviTag* ruuviTag = [[RKSRuuviTag alloc] initWithCBIdentifier:[NSUUID UUID]];
 	__block int notificationCount = 0;

	id observer = [[NSNotificationCenter defaultCenter] addObserverForName:kRKNotificationName_RuuviTagDidUpdate object:ruuviTag queue:nil usingBlock:
		^(NSNotification * _Nonnull notification)
		{
			XCTAssertEqualObjects( notification.object, ruuviTag);
			XCTAssertEqualObjects( notification.name, kRKNotificationName_RuuviTagDidUpdate);
			notificationCount += 1;
		}];

	RKRuuviData* data = (RKRuuviData*)[NSNull null]; // for this test, we're not actually interested in the payload in any way, we only need an object pointer. So fake it.
	[ruuviTag setRuuviData:data RSSI:@(-40)];

	XCTAssertEqual( notificationCount, 1); // "Give me a notification, Ruuvi. One notification only, please."

	XCTAssertEqualObjects( ruuviTag.ruuviData, data);
	XCTAssertEqualObjects( ruuviTag.RSSI, @(-40));


	[[NSNotificationCenter defaultCenter] removeObserver:observer name:kRKNotificationName_RuuviTagDidUpdate object:ruuviTag];
}

-(void)test_equality
{
	NSUUID* uuid = [NSUUID UUID];
	RKSRuuviTag* tag = [[RKSRuuviTag alloc] initWithCBIdentifier:[[NSUUID alloc] initWithUUIDString:[uuid UUIDString]]];
	RKSRuuviTag* sameTag = [[RKSRuuviTag alloc] initWithCBIdentifier:[[NSUUID alloc] initWithUUIDString:[uuid UUIDString]]];
	RKSRuuviTag* otherTag = [[RKSRuuviTag alloc] initWithCBIdentifier:[NSUUID UUID]];

	XCTAssertEqualObjects( tag, sameTag);
	XCTAssertNotEqualObjects( tag, otherTag);

	XCTAssertNotEqualObjects( tag, uuid);

	XCTAssertEqual( tag.hash, sameTag.hash);
	XCTAssertNotEqual( tag.hash, otherTag.hash);
}

@end

