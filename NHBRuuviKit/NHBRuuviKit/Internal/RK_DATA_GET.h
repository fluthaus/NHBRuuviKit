//
//  RK_DATA_GET.h
//
//  NHBRuuviKit
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

// Macro for simplified access to values inside memory blocks. Works with RKRuuviData and NSData, since both classes define 'bytes' and 'length' accessors

#define RK_DATA_GET( type, offset) (((offset + sizeof(type)) <= self.length) ? (*((type*)(self.bytes + (offset)))) : (type)0)
