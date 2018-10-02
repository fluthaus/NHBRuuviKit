//
//  RKRuuviData.m
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import "RKRuuviData.h"

#import "RK_DATA_GET.h"
#import "NSData+RKManufacturerData.h"
#import "NSData+RKEddystone.h"
#import "RKRuuviData+RuuviRaw1.h"
#import "RKRuuviData+RuuviRaw2.h"

@import CoreBluetooth;

NSErrorDomain const kRKErrorDomain = @"NHBRuuviKitErrorDomain";

// the ivar backed properties declared in the RKRuuviData () class extension are also used by the internal categories, so they are in a separate file:
#import "RKRuuviData+Private.h"

@implementation RKRuuviData

-(instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length
{
	self = [super init];
	if (self)
	{
		if ((bytes != nil) && (length > 0))
		{
			if ((_bytes = malloc( length)))
			{
				_length = length;
				memcpy( _bytes, bytes, length);
			}
		}
	}
	return self;
}

-(void)dealloc
{
	if (_bytes)
		free( _bytes);
}

+(instancetype)ruuviDataFromManufacturerData:(NSData*)manufacturerData
{
	return (manufacturerData.length >= 2 ? [[RKRuuviData alloc] initWithBytes:(manufacturerData.bytes + 2) length:manufacturerData.length - 2] : nil);
}

+(instancetype)ruuviDataFromBase64URLRuuviEncodedString:(NSString*)string
{
	if (!string)
		return nil;

	NSMutableString* str = [string mutableCopy];
	[str replaceOccurrencesOfString:@"-" withString:@"+" options:0 range:NSMakeRange( 0, str.length)];
	[str replaceOccurrencesOfString:@"_" withString:@"/" options:0 range:NSMakeRange( 0, str.length)];

	switch (str.length % 4) // add padding, if required
	{
		case 1: [str appendString:@"A=="]; break; // special case for ruuvi: last byte of original data gets clipped; append a zero (='A') to set missing bits in result to zero
		case 2: [str appendString:@"=="]; break;
		case 3: [str appendString:@"="]; break;
	}

	NSData* data = [[NSData alloc] initWithBase64EncodedData:[str dataUsingEncoding:NSASCIIStringEncoding] options:NSDataBase64DecodingIgnoreUnknownCharacters];
	return data ? [[RKRuuviData alloc] initWithBytes:data.bytes length:data.length] : nil;
}

+(RKRuuviData*)ruuviDataFromCBAdvertisementDictionary:(NSDictionary<NSString*,id>*)advertisementDictionary error:(NSError**)outError
{
	RKRuuviData* ruuviData = nil;

	// ruuvi tags advertise manufacturer data (format 3 + 5)...
	NSData* manufacturerData = advertisementDictionary[CBAdvertisementDataManufacturerDataKey];
	if (manufacturerData && (manufacturerData.RKManufacturerDataCompanyID == 0x0499))
		ruuviData = [self ruuviDataFromManufacturerData:manufacturerData];
	else
	{
		// ...or EddystoneURL-encoded sensor readings (format 2 + 4)
		NSData* eddystoneServiceData = advertisementDictionary[CBAdvertisementDataServiceDataKey][[CBUUID UUIDWithString:@"FEAA"]];
		if (eddystoneServiceData && (eddystoneServiceData.RKEddystoneFrameType == kRKEddystoneFrameType_URL))
		{
			NSURL* eddystoneURL = eddystoneServiceData.RKEddystoneURL;
			if (eddystoneURL && [eddystoneURL.host isEqualToString:@"ruu.vi"])
				ruuviData = [self ruuviDataFromBase64URLRuuviEncodedString:eddystoneURL.fragment];
		}
	}

	RKRuuviFormat_t format = [ruuviData ruuviFormatID];
	if (ruuviData && (format == kRKRuuviFormat_Invalid))
	{
		if (outError)
			*outError = [NSError errorWithDomain:kRKErrorDomain code:kRKErrorCode_InvalidRuuviData userInfo:nil];
		return nil;
	}

	return ruuviData;
}

#pragma mark - Accessors

// offsets according to documentation
const static size_t kRKRuuvi_Offset_Format = 0;

-(RKRuuviFormat_t)ruuviFormatID
{
	RKRuuviFormat_t result = kRKRuuviFormat_Invalid;
	if ((self.length > 0) && (self.bytes != NULL))
	{
		RKRuuviFormat_t format = RK_DATA_GET( uint8_t, kRKRuuvi_Offset_Format);
		switch (format)
		{
  			case kRKRuuviFormat_2:
 				result = (self.length >= 6) ? format : kRKRuuviFormat_Invalid;
			break;
    		case kRKRuuviFormat_3:
				result = (self.length >= 14) ? format : kRKRuuviFormat_Invalid;
    		break;
			case kRKRuuviFormat_4:
				result = (self.length >= 7) ? format : kRKRuuviFormat_Invalid;
    		break;
    		case kRKRuuviFormat_5:
				result = (self.length >= 24) ? format : kRKRuuviFormat_Invalid;
    		break;
    		default:
    			result = kRKRuuviFormat_Invalid;
    		break;
		}
	}
	return result;
}

-(NSNumber*)ruuviTemperature
{
	NSNumber* result;
	switch(self.ruuviFormatID)
	{
		case kRKRuuviFormat_Invalid:
			result = nil;
		break;
		case kRKRuuviFormat_5:
			result = self.ruuviRaw2Temperature;
		break;
		default:
			result = self.ruuviRaw1Temperature;
		break;
	}
	return result;
}

-(NSNumber*)ruuviHumidity
{
	NSNumber* result;
	switch(self.ruuviFormatID)
	{
		case kRKRuuviFormat_Invalid:
			result = nil;
		break;
		case kRKRuuviFormat_5:
			result = self.ruuviRaw2Humidity;
		break;
		default:
			result = self.ruuviRaw1Humidity;
		break;
	}
	return result;
}

-(NSNumber*)ruuviPressure
{
	NSNumber* result;
	switch(self.ruuviFormatID)
	{
		case kRKRuuviFormat_Invalid:
			result = nil;
		break;
		case kRKRuuviFormat_5:
			result = self.ruuviRaw2Pressure;
		break;
		default:
			result = self.ruuviRaw1Pressure;
		break;
	}
	return result;
}

-(NSNumber*)ruuviBatteryVoltage
{
	NSNumber* result;
	switch(self.ruuviFormatID)
	{
		case kRKRuuviFormat_5:
			result = self.ruuviRaw2BatteryVoltage;
		break;
		case kRKRuuviFormat_3:
			result = self.ruuviRaw1BatteryVoltage;
		break;
		default:
			result = nil;
		break;
	}
	return result;
}

-(NSNumber*)ruuviAccelerationForAxis:(RKRuuviAxis_t)axis
{
	NSNumber* result;
	switch(self.ruuviFormatID)
	{
		case kRKRuuviFormat_5:
			result = [self ruuviRaw2AccelerationForAxis:axis];
		break;
		case kRKRuuviFormat_3:
			result = [self ruuviRaw1AccelerationForAxis:axis];
		break;
		default:
			result = nil;
		break;
	}
	return result;
}

-(NSNumber*)ruuviRandomID
{
	NSNumber* result;
	switch(self.ruuviFormatID)
	{
		case kRKRuuviFormat_4:
			result = self.ruuviRaw1RandomID;
		break;
		default:
			result = nil;
		break;
	}
	return result;
}

-(NSNumber*)ruuviRandomIDB64Mapped
{
	NSNumber* result;
	switch(self.ruuviFormatID)
	{
		case kRKRuuviFormat_4:
			result = self.ruuviRaw1RandomIDB64mapped;
		break;
		default:
			result = nil;
		break;
	}
	return result;
}

-(NSNumber*)ruuviTxPower
{
	NSNumber* result = nil;
	switch(self.ruuviFormatID)
	{
		case kRKRuuviFormat_5:
			result = self.ruuviRaw2TxPower;
		break;
		default:
			result = nil;
		break;
	}
	return result;
}

-(NSNumber*)ruuviMovementCounter
{
	NSNumber* result = nil;
	switch(self.ruuviFormatID)
	{
		case kRKRuuviFormat_5:
			result = self.ruuviRaw2MovementCounter;
		break;
		default:
			result = nil;
		break;
	}
	return result;
}

-(NSNumber*)ruuviMeasurementSequenceNumber
{
	NSNumber* result = nil;
	switch(self.ruuviFormatID)
	{
		case kRKRuuviFormat_5:
			result = self.ruuviRaw2MeasurementSequenceNumber;
		break;
		default:
			result = nil;
		break;
	}
	return result;
}

-(NSData*)ruuviMACAddress
{
	NSData* result = nil;
	switch(self.ruuviFormatID)
	{
		case kRKRuuviFormat_5:
			result = self.ruuviRaw2MACAddress;
		break;
		default:
			result = nil;
		break;
	}
	return result;
}

@end
