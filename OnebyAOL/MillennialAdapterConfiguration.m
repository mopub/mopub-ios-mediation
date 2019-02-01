//
//  MillennialAdapterConfiguration.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <MMAdSDK/MMAdSDK.h>
#import "MillennialAdapterConfiguration.h"

@implementation MillennialAdapterConfiguration
// Initialization configuration keys
static NSString * const kMoPubMMAdapterAdUnit = @"placementId";

#pragma mark - MPAdapterConfiguration
+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString *placementId = parameters[kMoPubMMAdapterAdUnit];
    
    if (placementId != nil) {
        NSDictionary * configuration = @{ kMoPubMMAdapterAdUnit: placementId };
        [MillennialAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

- (NSString *)adapterVersion {
    return @"6.8.1.3";
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    // ⚠️ Do not change this value! ⚠️
    return @"Millennial";
}

- (NSString *)networkSdkVersion {
    return [MMSDK.sharedInstance version];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    // Assumes SDK initialized outside of MoPub SDK.
    MMSDK *mmSDK = [MMSDK sharedInstance];
    if (![mmSDK isInitialized]) {
        [mmSDK initializeWithSettings:[[MMAppSettings alloc] init]
                     withUserSettings:nil];
    }
    if (complete != nil) {
        complete(nil);
    }
}

@end
