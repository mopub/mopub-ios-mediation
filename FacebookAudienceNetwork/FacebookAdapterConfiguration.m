//
//  FacebookAdapterConfiguration.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "FacebookAdapterConfiguration.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookAdapterConfiguration.h"

#if __has_include("MoPub.h")
#import "MPLogging.h"
#import "MPConstants.h"
#endif

#define FACEBOOK_SDK_VERSION                 @"5.3.0"
#define FACEBOOK_ADAPTER_VERSION             @"5.3.0.0"
#define MOPUB_NETWORK_NAME                   @"facebook"

@implementation FacebookAdapterConfiguration

#pragma mark - Test Mode

+ (BOOL)isTestMode {
    return FBAdSettings.isTestMode;
}

+ (void)setIsTestMode:(BOOL)isTestMode {
    // Transition to test mode by adding the current device hash as a test device.
    if (isTestMode && !FBAdSettings.isTestMode) {
        [FBAdSettings addTestDevice:FBAdSettings.testDeviceHash];
    }
    // Transition out of test mode by removing the current device hash.
    else if (!isTestMode && FBAdSettings.isTestMode) {
        [FBAdSettings clearTestDevice:FBAdSettings.testDeviceHash];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return FACEBOOK_ADAPTER_VERSION;
}

- (NSString *)biddingToken {
    return [FBAdSettings bidderToken];
}

- (NSString *)moPubNetworkName {
    return MOPUB_NETWORK_NAME;
}

- (NSString *)networkSdkVersion {
    // `FBAdSettings` has no API to retrieve the Facebook Audience Network SDK version
    return FACEBOOK_SDK_VERSION;
}

+ (NSString*)mediationString {
    return [NSString stringWithFormat:@"MOPUB_%@:%@", MP_SDK_VERSION, FACEBOOK_ADAPTER_VERSION];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    // Facebook Audience Network does not have a SDK-level initialization that needs to
    // be invoked prior to requesting ads.
    
    // However, we need to initialize an adview to trigger the internal
    // `[FBAdUtility initializeAudienceNetwork]` method which is required to
    // properly initialize the bidding tokens from FAN.
    dispatch_async(dispatch_get_main_queue(), ^{
        FBAdView * initHackforFacebook = [[FBAdView alloc] initWithPlacementID:@"" adSize:kFBAdSize320x50 rootViewController:[UIViewController new]];
        if (initHackforFacebook) {
            MPLogDebug(@"Initialized Facebook Audience Network");
        }
    });
    
    if (complete != nil) {
        complete(nil);
    }
}

@end
