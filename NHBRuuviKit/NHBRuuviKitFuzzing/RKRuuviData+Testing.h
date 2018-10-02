//
//  RKRuuviData+Testing.h
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import <NHBRuuviKit/NHBRuuviKit.h>
#import "RKRuuviData+Private.h"

@interface RKRuuviData ()

+(instancetype _Nullable )ruuviDataFromBase64URLRuuviEncodedString:(NSString*_Nullable)string;
+(instancetype _Nullable )ruuviDataFromManufacturerData:(NSData*_Nullable)manufacturerData;
-(instancetype _Nullable )initWithBytes:(const void *_Nullable)bytes length:(NSUInteger)length;

@end


