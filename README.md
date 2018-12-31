# NHBRuuviKit

<http://dev.fluthaus.de/NHBRuuviKit>

NHBRuuviKit is an iOS framework with functionality to scan for and parse BLE advertisements from [ruuvi tags](https://ruuvi.com). It currently supports [ruuvi formats](https://github.com/ruuvi/ruuvi-sensor-protocols) 2, 3, 4 and 5. It has good test coverage and withstand a few hours of fuzzing. It comes with a basic sample app demonstrating its usage.

NHBRuuviKit requires iOS 9 or later and Xcode 9 or later. It's written in Objective-C and uses ARC. It has no dependencies beyond standard iOS frameworks.

## Usage

NHBRuuviKit consists of two main classes:
  * `RKRuuviScanner` is a minimal wrapper around CoreBluetooth with just enough functionality to scan for the BLE advertisements from ruuvi tags. When a ruuvi advertisement is received, it is handed to the delegate as an instance of
 * `RKRuuviData`, which encapsulates the payload of the advertisement and allows access to the actual values (sensor readings, battery voltage etc.).
 
 Setting up scanning requires only a few steps. First, implement the scanning delegate method; doing this in the app delegate is usually a good starting point:

```objc
#import <NHBRuuviKit/NHBRuuviKit.h>

// delegate method that will be called when a ruuvi advertisement is received
-(void)ruuviScanner:(RKRuuviScanner*)ruuviScanner didReceiveAdvertisementFromRuuviTag:(NSUUID*)coreBluetoothUUID ruuviData:(RKRuuviData*)ruuviData RSSI:(NSNumber*)RSSI
{
    // do something with ruuviData et al.
}
```

Then, in an appropriate location, initialize a `RKRuuviScanner` with the delegate, and start scanning:

```objc
RKRuuviScanner* ruuviScanner = [[RKRuuviScanner alloc] initWithDelegate:self queue:nil options:nil];
[ruuviScanner startScan];

```

See _NHBRuuviKitSample_ for a full implementation.

If you prefer not to use `RKRuuviScanner` and instead implement scanning yourself, `RKRuuviData` has a class method which will examine an advertisement dictionary as provided by CoreBluetooth and, if it is a ruuvi advertisement, create a `RKRuuviData` instance from it.

NHBRuuviKit also exposes two supplemental `NSData` categories, giving access to company ids in BLE manufacturer data and the various payloads and fields in beacon advertisements following the [Eddystone protocol](https://github.com/google/eddystone/blob/master/protocol-specification.md).

## NHBRuuviKitSample

The sample app demonstrates how to scan for ruuvi advertisements with NHBRuuviKit and display the temperature readings in a basic table view.

## Quick Start

 * Clone/download the repository
 * in Xcode, open _./NHBRuuviKitSample/NHBRuuviKitSample.xcodeproj_
 * in the _NHBRuuviKitSample_ project editor, pick a developer identity (a free Apple developer account is sufficient to run the app on your own devices)
 * connect your iOS device and select it as the destination in Xcode (_Note: Running in the simulator is mostly pointless, since CoreBluetooth does not do any scanning in the simulator... so no tags will show up_)
 * make sure BT is enabled on the device, and that some ruuvi tags are within reach; then, in Xcode, hit _Run..._

## Documentation

Please see the comments in the source code on what classes and methods do and how to use them.

## Limitations

The CoreBluetooth-API imposes limitations on what apps can do with BLE beacons, especially when it comes to background scanning and identifying peripherals across devices. I've [documented](http://corebeacons.fluthaus.com/#known-limitations "CoreBeacons | Limitations") the limitations I'm aware of.  
I can't do anything about this, so please don't ask; file a bug report/feature request with Apple instead.

## CocoaPod

The podspec contains the regular unit tests, but doesn't has the fuzzing tests (which usually have to run for hours to be useful). Please clone/download the repository directly and use the included Xcode project if you're interested in running these. 

## License

NHBRuuviKit is licensed under the New/3-clause BSD License. The suggested attribution format is "Includes NHBRuuviKit by nhb | fluthaus".

If you you want to use NHBRuuviKit or parts thereof but cannot provide attribution, please feel free to contact me at nohalfbits<sub>0x40</sub>fluthaus<sub>0x2E</sub>de.



Copyright (c) 2018, nhb | fluthaus.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.