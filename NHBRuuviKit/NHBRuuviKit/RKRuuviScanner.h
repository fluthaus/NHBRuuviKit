//
//  RuuviScanner.h
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import <Foundation/Foundation.h>
#import <NHBRuuviKit/RKRuuviData.h>

@class RKRuuviScanner;

@protocol RKRuuviScannerDelegate <NSObject>
@required

/**
@brief Sent to the deleagte when the scanner receives a valid ruuvi advertisement.
@param ruuviScanner The RKRuuviScanner instance that sent the message
@param coreBluetoothUUID The CoreBluetooth assigned identifier of the ruuvi tag
@param ruuviData The advertisement payload containing sensor readings etc.
@param RSSI The RSSI value, as reported by CoreBluetooth
*/

-(void)ruuviScanner:(nonnull RKRuuviScanner*)ruuviScanner didReceiveAdvertisementFromRuuviTag:(nonnull NSUUID*)coreBluetoothUUID ruuviData:(nonnull RKRuuviData*)ruuviData RSSI:(nonnull NSNumber*)RSSI;

@optional

/**
@brief Sent to the deleagte if parsing of a ruuvi advertisement fails. Only implement if you're interested in when this happens.
@param ruuviScanner The RKRuuviScanner instance that sent the message
@param coreBluetoothUUID The CoreBluetooth assigned identifier of the ruuvi tag
@param error A NSError instance decribing the failure. See RKRuuviData.h for error domain and codes
*/

-(void)ruuviScanner:(nonnull RKRuuviScanner*)ruuviScanner failedToParseAdvertisementFromRuuviTag:(nonnull NSUUID*)coreBluetoothUUID withError:(nonnull NSError*)error;

@end

/**
@class RKRuuviScanner
@discussion Wrapper around CBCentralManager, exposing just what's needed to scan for advertisements from ruuvi tags.
@discussion If a valid ruuvi advertisement is received, it is handed to the delegate with the @c didReceiveAdvertisementFromRuuviTag:ruuviData:RSSI: method. If parsing of the advertisement fails, and the delegate implements @c didFailParsingRuuviDataWithError: this method is called with the error returned by @c ruuviDataFromCBAdvertisementDictionary:error: method
*/

@interface RKRuuviScanner : NSObject

/**
@method initWithDelegate:queue:
@param delegate The delegate to receive ruuvi advertisements
@param queue The dispatch queue on which the delegate will receive messages. Pass nil to receive messages on the main queue.
@param options An optional dictionary containing initialization options for the underlying CBCentralManager. See the CBCentralManager documentation for available options.
*/

-(nullable instancetype)initWithDelegate:(nonnull id<RKRuuviScannerDelegate>)delegate queue:(nullable dispatch_queue_t)queue options:(nullable NSDictionary*)options;

@property (readonly,nullable,weak) id<RKRuuviScannerDelegate> delegate;

/**
@method startScan
@brief Starts scanning for BLE advertisements from ruuvi tags.
@discussion If Bluetooth is disabled when this method is called, scanning starts when Bluetooth becomes available.
*/

-(void)startScan;

/**
@method stopScan
@brief Stops scanning.
*/

-(void)stopScan;

@end
