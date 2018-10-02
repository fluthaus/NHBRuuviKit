//
//  RKSRuuviTag.m
//
//  NHBRuuviKitSample
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import "RKSRuuviTag.h"

NSString* const kRKNotificationName_RuuviTagDidUpdate = @"RuuviTagDidUpdate_Notification";

@interface RKSRuuviTag ()

@property (readwrite,strong) NSNumber* RSSI;
@property (readwrite,strong) RKRuuviData* ruuviData;

@end

@implementation RKSRuuviTag

-(instancetype)initWithCBIdentifier:(NSUUID*)CBIdentifier
{
	self = [super init];
	if (self)
		_CBIdentifier = CBIdentifier;
	return self;
}

-(void)setRuuviData:(RKRuuviData*)ruuviData RSSI:(NSNumber*)RSSI
{
	self.RSSI = RSSI;
	self.ruuviData = ruuviData;

	[[NSNotificationCenter defaultCenter] postNotificationName:kRKNotificationName_RuuviTagDidUpdate object:self];
}

-(BOOL)isEqual:(id)object
{
	if ([object respondsToSelector:@selector(CBIdentifier)])
		return [self.CBIdentifier isEqual:[object CBIdentifier]];
	return [super isEqual:object];
}

-(NSUInteger)hash
{
	return self.CBIdentifier.hash;
}

@end
