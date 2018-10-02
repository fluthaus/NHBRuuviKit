//
//  NSData+RKManufacturer.h
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import <Foundation/Foundation.h>

typedef NSInteger RKManufacturerDataCompanyID_t;

NS_ENUM( RKManufacturerDataCompanyID_t)
{
	kRKManufacturerDataCompanyID_Invalid = -1,
};

/**

A NSData category giving access to the company identifier in BLE advertisement manufacturer data.

Use with NSData instances stored in CoreBluetooth advertisement dictionaries under @c CBAdvertisementDataManufacturerDataKey

See https://www.bluetooth.com/specifications/assigned-numbers/company-identifiers for a list of assigned company identifiers.

*/

@interface NSData (RKManufacturerData)

/// @return Bluetooth company identifier, or kRKCompanyID_Invalid if data size is insufficient

-(RKManufacturerDataCompanyID_t)RKManufacturerDataCompanyID;

@end
