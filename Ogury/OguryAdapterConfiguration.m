//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryAdapterConfiguration.h"
#import <OguryAds/OguryAds.h>

#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

#pragma mark - Constants

NSString * const kOguryConfigurationAdUnitId = @"ad_unit_id";
NSString * const kOguryErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-ogury-adapters";

static NSString * const OguryConfigurationMediationName = @"MoPub";
static NSString * const OguryConfigurationAdapterVersion = @"2.2.4.0";
static NSString * const OguryConfigurationNetworkName = @"ogury";

static NSString * const OguryConfigurationKeyAssetKey = @"asset-key";

@implementation OguryAdapterConfiguration

#pragma mark - Properties

- (NSString *)adapterVersion {
    return OguryConfigurationAdapterVersion;
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return OguryConfigurationNetworkName;
}

- (NSString *)networkSdkVersion {
    return [[OguryAds shared] sdkVersion];
}

#pragma mark - Methods

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // Not implemented
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete {
    [[OguryAds shared] defineMediationName:OguryConfigurationMediationName];
    
    NSString *assetKey = configuration[OguryConfigurationKeyAssetKey];

    if (!assetKey || [assetKey isEqualToString:@""]) {
        NSError *error = [NSError errorWithDomain:kOguryErrorDomain
                                             code:MOPUBErrorAdapterInvalid
                                         userInfo:@{NSLocalizedDescriptionKey:@"OguryAdsAssetKeyNotValidError. An error occurred during the initialization of the SDK."}];
                                         
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }

        return;
    }

    [[OguryAds shared] setupWithAssetKey:assetKey];

    MPLogInfo(@"Ogury SDK successfully initialized.");

    complete(nil);
}

@end