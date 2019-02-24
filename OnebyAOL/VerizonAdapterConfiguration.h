///
///  @file
///  @brief Definitions for VerizonAdapterConfiguration
///
///  @copyright Copyright (c) 2019 Verizon. All rights reserved.
///

#import <Foundation/Foundation.h>
#import "MoPub.h"
#import "MPBaseAdapterConfiguration.h"

// Error keys
extern NSErrorDomain const kMoPubVASAdapterErrorDomain;
extern NSString * const kMoPubVASAdapterErrorWho;

// Configuration keys
extern NSString * const kMoPubVASAdapterAdUnit;
extern NSString * const kMoPubVASAdapterDCN;
extern NSString * const kMoPubVASAdapterVersion;
extern NSTimeInterval kMoPubVASAdapterSATimeoutInterval;

@interface VerizonAdapterConfiguration : MPBaseAdapterConfiguration
+ (NSString *)appMediator;
@end

@interface MillennialAdapterConfiguration : VerizonAdapterConfiguration
@end
