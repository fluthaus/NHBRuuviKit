//
//  RKSAppDelegate.m
//
//  NHBRuuviKitSample
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

@import NHBRuuviKit;
@import CoreBluetooth;

#import "RKSAppDelegate.h"
#import "RKSRuuviTag.h"

@interface RKSAppDelegate () <RKRuuviScannerDelegate>

// dictionary to keep track of already known tags
@property (readonly) NSMutableDictionary<NSUUID*,RKSRuuviTag*>* ruuviTags;

// the central scanner instance. Kept here to be independent of any view controllers, and easily accessible when application goes to/comes back from background
@property (readwrite,strong) RKRuuviScanner* ruuviScanner;

@end

@implementation RKSAppDelegate

-(instancetype)init
{
	self = [super init];
	if (self)
	{
		_ruuviTags = [NSMutableDictionary dictionary];
		_ruuviScanner = [[RKRuuviScanner alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionShowPowerAlertKey: @YES}];
	}
	return self;
}

#pragma mark - starting & stoping scanning

// in this simple demo app, we just keep scanning while we're active. We stop scanning when we're backgrounded, since CoreBluetooth won't let us see ruuvi advertisements while in the background anyway

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	[self.ruuviScanner startScan];
	return YES;
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
	[self.ruuviScanner startScan];
}

-(void)applicationDidEnterBackground:(UIApplication*)application
{
	[self.ruuviScanner stopScan];
}

-(void)applicationWillTerminate:(UIApplication *)application
{
	[self.ruuviScanner stopScan];
}

#pragma mark - RKRuuviScanner delegate

-(void)ruuviScanner:(nonnull RKRuuviScanner*)ruuviScanner didReceiveAdvertisementFromRuuviTag:(nonnull NSUUID*)coreBluetoothUUID ruuviData:(nonnull RKRuuviData*)ruuviData RSSI:(NSNumber*)RSSI
{
	// when an ruuvi advertisement comes in, see if it is from an already known and existing tag, or otherwise create a new one and add it to the dictionary of known tags
	RKSRuuviTag* ruuviTag = self.ruuviTags[coreBluetoothUUID] ?: (self.ruuviTags[coreBluetoothUUID] = [[RKSRuuviTag alloc] initWithCBIdentifier:coreBluetoothUUID]);
	// update the tag with ruuvi payload data and current RSSI; the method will also post a notification to observers of this
	[ruuviTag setRuuviData:ruuviData RSSI:RSSI];
}

#pragma mark - Resetting

-(void)resetRuuviTags
{
	[self.ruuviScanner stopScan];
	[self.ruuviTags removeAllObjects];
	[self.ruuviScanner startScan];
}

@end
