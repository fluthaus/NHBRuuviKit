//
//  RKSAppDelegate.h
//
//  NHBRuuviKitSample
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

#import <UIKit/UIKit.h>

@interface RKSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * _Nullable window;

-(void)resetRuuviTags;

@end

