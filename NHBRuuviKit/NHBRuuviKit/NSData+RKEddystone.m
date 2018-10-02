//
//  NSData+RKEddystone.m
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import "NSData+RKEddystone.h"
#import "RK_DATA_GET.h"

@implementation NSData (RKEddystone)

NS_ENUM( size_t)
{
	kRKEddystone_Offset_FrameType = 0,
	kRKEddystone_Offset_TxPower = 1,
	kRKEddystone_Offset_Namespace = 2,
	kRKEddystone_Offset_Instance = 12,
	kRKEddystone_Offset_URL = 2,
	kRKEddystone_Offset_TLMVersion = 1,
	kRKEddystone_Offset_BatteryVoltage = 2,
	kRKEddystone_Offset_Temperature = 4,
	kRKEddystone_Offset_AdvPDUCount = 6,
	kRKEddystone_Offset_Uptime = 10,
	kRKEddystone_Offset_EphemeralIdentifier = 2,
};

NS_ENUM( size_t)
{
	kRKEddystone_SizeMin_UIDFrame = 18,
	kRKEddystone_SizeMin_URLFrame = 4, // up to 20 bytes
	kRKEddystone_SizeMin_TLMFrame = 14,
	kRKEddystone_SizeMin_TLMEncryptedFrame = 18,
	kRKEddystone_SizeMin_EIDFrame = 10,
	kRKEddystone_Size_Namespace = 10,
	kRKEddystone_Size_Instance = 6,
	kRKEddystone_Size_EphemeralIdentifier = 8,
};

-(RKEddystoneFrameType_t)RKEddystoneFrameType
{
	RKEddystoneFrameType_t frameType = kRKEddystoneFrameType_Invalid;
	if (self.length > 0)
	{
		switch (frameType = RK_DATA_GET( uint8_t, kRKEddystone_Offset_FrameType))
		{
			case kRKEddystoneFrameType_UID:
			{
				if (self.length < kRKEddystone_SizeMin_UIDFrame)
					frameType = kRKEddystoneFrameType_Invalid;
			}
			break;
			case kRKEddystoneFrameType_URL:
			{
				if (self.length < kRKEddystone_SizeMin_URLFrame)
					frameType = kRKEddystoneFrameType_Invalid;
			}
			break;
			case kRKEddystoneFrameType_TLM:
			{
				if (self.length < kRKEddystone_SizeMin_TLMFrame)
					frameType = kRKEddystoneFrameType_Invalid;
			}
			break;
			case kRKEddystoneFrameType_EID:
			{
				if (self.length < kRKEddystone_SizeMin_EIDFrame)
					frameType = kRKEddystoneFrameType_Invalid;
			}
			break;
			case kRKEddystoneFrameType_RESERVED:
			break;
			default:
				frameType = kRKEddystoneFrameType_Invalid;
			break;
		}
	}
	return frameType;
}

-(NSNumber*)RKEddystoneTxPower
{
	RKEddystoneFrameType_t frameType = self.RKEddystoneFrameType;
	if ((frameType != kRKEddystoneFrameType_Invalid) && (frameType != kRKEddystoneFrameType_RESERVED))
		return  @(RK_DATA_GET( int8_t, kRKEddystone_Offset_TxPower));
	return nil;
}

-(NSData*)RKEddystoneUIDNamespace
{
	if (self.RKEddystoneFrameType == kRKEddystoneFrameType_UID)
	 	return [self subdataWithRange:NSMakeRange( kRKEddystone_Offset_Namespace, kRKEddystone_Size_Namespace)];
	return nil;
}

-(NSData*)RKEddystoneUIDInstance
{
	if (self.RKEddystoneFrameType == kRKEddystoneFrameType_UID)
	 	return [self subdataWithRange:NSMakeRange( kRKEddystone_Offset_Instance, kRKEddystone_Size_Instance)];
	return nil;
}

-(NSURL*)RKEddystoneURL
{
	if (self.RKEddystoneFrameType != kRKEddystoneFrameType_URL)
		return nil;

	NSArray* schemes = @[@"http://www.", @"https://www.", @"http://", @"https://"];
	uint8_t scheme = RK_DATA_GET( uint8_t, kRKEddystone_Offset_URL);
	if (scheme >= schemes.count)
		return nil;

	NSMutableString* url = [schemes[scheme] mutableCopy];
	for (char i = 3; i < self.length; i++)
	{
		unsigned char c = RK_DATA_GET( uint8_t, i);
		if (c <= 13)
			[url appendString:@[ @".com/", @".org/", @".edu/", @".net/", @".info/", @".biz/", @".gov/",
								 @".com",  @".org",  @".edu",  @".net",  @".info",  @".biz",  @".gov"][c]];
		else if ((c > 0x20) && (c < 0x7F)) // according to spec, only 0x21 to 0x7E is allowed as characters in url
			[url appendFormat:@"%c", c];
		else
			return nil; // bail out on invalid character
	}
	return [NSURL URLWithString:url];
}

-(RKEddystoneTLMVersion_t)RKEddystoneTLMVersion
{
	if (self.RKEddystoneFrameType == kRKEddystoneFrameType_TLM)
	{
		uint8_t version = RK_DATA_GET( uint8_t, kRKEddystone_Offset_TLMVersion);
		if (((version == kRKEddystoneTLMVersion_Default) && (self.length >= kRKEddystone_SizeMin_TLMFrame)) ||
			((version == kRKEddystoneTLMVersion_Encrypted) && (self.length >= kRKEddystone_SizeMin_TLMEncryptedFrame)))
			return version;
	}
	return kRKEddystoneTLMVersion_Invalid;
}

-(NSNumber*)RKEddystoneTLMBatteryVoltage
{
	if ((self.RKEddystoneFrameType != kRKEddystoneFrameType_TLM) || (self.RKEddystoneTLMVersion != kRKEddystoneTLMVersion_Default))
		return nil;

	uint16_t voltage = NSSwapBigShortToHost( RK_DATA_GET( uint16_t, kRKEddystone_Offset_BatteryVoltage));

	if (voltage != 0)
	 	return @(voltage);
	return nil;
}

-(NSNumber*)RKEddystoneTLMTemperature
{
	if ((self.RKEddystoneFrameType != kRKEddystoneFrameType_TLM) || (self.RKEddystoneTLMVersion != kRKEddystoneTLMVersion_Default))
		return nil;

	int8_t i = RK_DATA_GET( int8_t, kRKEddystone_Offset_Temperature);
	uint8_t f = RK_DATA_GET( uint8_t, kRKEddystone_Offset_Temperature + 1);

	if ((i == -128) && (f == 0))
		return nil;

	return @(i + (f * 1./256.));
}

-(NSNumber*)RKEddystoneTLMAdvPDUCount
{
	if ((self.RKEddystoneFrameType == kRKEddystoneFrameType_TLM) && (self.RKEddystoneTLMVersion == kRKEddystoneTLMVersion_Default))
	 	return @(NSSwapBigIntToHost( RK_DATA_GET( uint32_t, kRKEddystone_Offset_AdvPDUCount)));
	return nil;
}

-(NSNumber*)RKEddystoneTLMUptime
{
	if ((self.RKEddystoneFrameType == kRKEddystoneFrameType_TLM) && (self.RKEddystoneTLMVersion == kRKEddystoneTLMVersion_Default))
	 	return @(NSSwapBigIntToHost( RK_DATA_GET( uint32_t, kRKEddystone_Offset_Uptime)));
	return nil;
}

-(NSData*)RKEddystoneTLMEncryptedPayload
{
	if ((self.RKEddystoneFrameType == kRKEddystoneFrameType_TLM) && (self.RKEddystoneTLMVersion == kRKEddystoneTLMVersion_Encrypted))
	 	return [self subdataWithRange:NSMakeRange( 2, self.length - 2)];
	return nil;
}

-(NSData*)RKEddystoneEIDEphemeralIdentifier
{
	if (self.RKEddystoneFrameType == kRKEddystoneFrameType_EID)
	 	return [self subdataWithRange:NSMakeRange( kRKEddystone_Offset_EphemeralIdentifier, kRKEddystone_Size_EphemeralIdentifier)];
	return nil;
}

@end
