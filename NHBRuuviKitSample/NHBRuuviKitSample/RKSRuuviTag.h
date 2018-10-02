//
//  RKSRuuviTag.h
//
//  NHBRuuviKitSample
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import <Foundation/Foundation.h>
@import NHBRuuviKit;

/// Notifications with this name are posted by the setRuuviData:RSSI: method of RKSRuuviTag. Notifications have the RKSRuuviTag instance as object and no user info.

extern NSString* _Nonnull const kRKNotificationName_RuuviTagDidUpdate;

/**

@class RKSRuuviTag
@brief The model object for NHBRuuviKitSample
@discussion RKSRuuviTag instances are created or updated by the RKSAppDelegate on receiving a valid advertisement from RKRuuviScanner. The CBIdentifier is constant, RSSI and ruuviData may change with an update.

*/

@interface RKSRuuviTag : NSObject

/// Assigned on initialization, constant thereafter
@property (readonly,nonnull) NSUUID* CBIdentifier;

/// ruuviData parsed from advertisement; may change when instance is updated
@property (readonly,nonnull) RKRuuviData* ruuviData;

/// RSSI as reported by CoreBluetooth, may change when instance is updated
@property (readonly,nonnull) NSNumber* RSSI;

/// Initializes a new instance with the given CoreBluetooth identifier
-(nullable instancetype)initWithCBIdentifier:(nonnull NSUUID*)CBIdentifier;

/// Updates the ruuviData and RSSI properties and posts a @c kRKNotificationName_RuuviTagDidUpdate notification
-(void)setRuuviData:(nonnull RKRuuviData*)ruuviData RSSI:(nonnull NSNumber*)RSSI;

@end

