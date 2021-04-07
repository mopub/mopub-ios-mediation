//
//  Copyright © 2019 Ogury Ltd. All rights reserved.
//

#import "OguryAdapterConfiguration.h"
#import <OguryAds/OguryAds.h>

#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

#pragma mark - Constants

NSString * const OguryConfigurationAdUnitId = @"ad_unit_id";

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
    [[OguryAds shared] defineMediationName:OguryConfigurationMediationName];

    NSString *assetKey = parameters[OguryConfigurationKeyAssetKey];

    if (assetKey != nil && ![assetKey isEqualToString:@""]) {
        [[OguryAds shared] setupWithAssetKey:assetKey];
    }
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete {
    MPLogInfo(@"Ogury SDK successfully initialized.");

    complete(nil);
}

@end
