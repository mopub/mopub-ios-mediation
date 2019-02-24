///
///  @file
///  @brief Implementation for VASAdapterConfiguration
///
///  @copyright Copyright (c) 2019 Verizon. All rights reserved.
///

#import <VerizonAdsStandardEdition/VerizonAdsStandardEdition.h>
#import <VerizonAdsCore/VerizonAdsCore.h>
#import "VerizonAdapterConfiguration.h"

NSErrorDomain const kMoPubVASAdapterErrorDomain = @"com.verizon.ads.mopubvasadapter.ErrorDomain";
NSString * const kMoPubVASAdapterErrorWho = @"MoPubVASAdapter";
NSString * const kMoPubVASAdapterAdUnit = @"placementId";
NSString * const kMoPubVASAdapterDCN = @"siteId";
NSString * const kMoPubVASAdapterVersion = @"1.0.1.0";
NSTimeInterval kMoPubVASAdapterSATimeoutInterval = 600;

@implementation VerizonAdapterConfiguration

+ (NSString *)appMediator {
    return [NSString stringWithFormat:@"MoPubVAS-%@",kMoPubVASAdapterVersion];
}

+ (void)updateInitializationParameters:(NSDictionary *)parameters {}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete {
    NSString *dcn = configuration[kMoPubVASAdapterDCN];
    if (dcn.length > 0 && [VerizonAdsStandardEdition initializeWithSiteId:dcn]) {
        MPLogInfo(@"VAS adapter version: %@", kMoPubVASAdapterVersion);
    }
    if (complete) {
        complete(nil);
    }
}

- (NSString *)adapterVersion {
    return kMoPubVASAdapterVersion;
}

- (NSString *)biddingToken {
    return @"sy_bp";
}

- (NSString *)moPubNetworkName {
    return @"Verizon";
}

- (NSString *)networkSdkVersion {
    return VASAds.sdkInfo.version;
}

@end

@implementation MillennialAdapterConfiguration

- (NSString *)moPubNetworkName {
    return @"Millennial";
}

@end
