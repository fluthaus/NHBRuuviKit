//
//  NSData+RKManufacturer.m
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import "NSData+RKManufacturerData.h"
#import "RK_DATA_GET.h"

@implementation NSData (RKManufacturerData)

-(RKManufacturerDataCompanyID_t)RKManufacturerDataCompanyID
{
	return (self.length >= sizeof(uint16_t) ? RK_DATA_GET( uint16_t, 0) : kRKManufacturerDataCompanyID_Invalid);
}

@end
