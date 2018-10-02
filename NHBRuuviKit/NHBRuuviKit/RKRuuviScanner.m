//
//  RuuviScanner.m
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

@import CoreBluetooth;

#import "RKRuuviScanner.h"

@interface RKRuuviScanner ()

@property (readwrite,strong) CBCentralManager* centralManager;
@property (readwrite) BOOL scan;

@end

@interface RKRuuviScanner (CBCentralManagerDelegate) <CBCentralManagerDelegate>
@end

@implementation RKRuuviScanner

-(instancetype)initWithDelegate:(id<RKRuuviScannerDelegate>)delegate queue:(dispatch_queue_t)queue options:(NSDictionary*)options;
{
	self = [super init];
	if (self)
	{
		_delegate = delegate;
		_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:options];
	}
	return self;
}

-(void)startScan
{
	@synchronized(self)
	{
		if (self.centralManager.state >= CBCentralManagerStatePoweredOn)
			[self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
		self.scan = YES;
	}
}

-(void)stopScan
{
	@synchronized(self)
	{
		if (self.centralManager.state >= CBCentralManagerStatePoweredOn)
			[self.centralManager stopScan];
		self.scan = NO;
	}
}

@end

@implementation RKRuuviScanner (CBCentralManagerDelegate)

-(void)centralManagerDidUpdateState:(nonnull CBCentralManager*)central
{
	@synchronized(self)
	{
		if (self.scan && (central.state >= CBCentralManagerStatePoweredOn))
			[self startScan];
	}
}

-(void)centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary<NSString*,id>*)advertisementData RSSI:(NSNumber*)RSSI
{
	NSError* error = nil;
	RKRuuviData* ruuviData = [RKRuuviData ruuviDataFromCBAdvertisementDictionary:advertisementData error:&error];
	if (ruuviData)
		[self.delegate ruuviScanner:self didReceiveAdvertisementFromRuuviTag:peripheral.identifier ruuviData:ruuviData RSSI:RSSI];
	else
		if ((error != nil) && [self.delegate respondsToSelector:@selector(ruuviScanner:failedToParseAdvertisementFromRuuviTag:withError:)])
			[self.delegate ruuviScanner:self failedToParseAdvertisementFromRuuviTag:peripheral.identifier withError:error];
}

@end

