//
//  IronSourceAdapterConfiguration.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <IronSource/IronSource.h>
#import "IronSourceAdapterConfiguration.h"
#import "IronSourceManager.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

NSString * const kIronSourceAppkey = @"applicationKey";

@implementation IronSourceAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * appKey = parameters[kIronSourceAppkey];
    
    if (appKey != nil) {
        NSDictionary * configuration = @{kIronSourceAppkey: appKey};
        [IronSourceAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"7.1.6.1.0";
}

- (NSString *)biddingToken {
    return [IronSource getISDemandOnlyBiddingData];
}

- (NSString *)moPubNetworkName {
    // ⚠️ Do not change this value! ⚠️
    return @"ironsource";
}

- (NSString *)networkSdkVersion {
    return [IronSource sdkVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    NSString *appKey = configuration[kIronSourceAppKey];
    NSString *rewardedVideoStatus = configuration[IS_REWARDED_VIDEO];
    NSString *interstitialStatus = configuration[IS_INTERSTITIAL];
    
    BOOL shouldInit = TRUE;
    
    NSMutableSet *adUnitsSet = [NSMutableSet set];
    if ([appKey length] == 0) {
        MPLogInfo(@"IronSource Adapter failed to initialize, 'applicationKey' parameter is missing. Make sure that 'applicationKey' server parameter is added");
        
        if (complete != nil) {
            complete(nil);
        }
        return;
    }
    
    if (rewardedVideoStatus != nil && [rewardedVideoStatus isKindOfClass:[NSString class]]) {
        if ([rewardedVideoStatus boolValue]) {
            [adUnitsSet addObject:IS_REWARDED_VIDEO];
        }
    }
    
    if (interstitialStatus != nil && [interstitialStatus isKindOfClass:[NSString class]]) {
        if ([interstitialStatus boolValue]) {
            [adUnitsSet addObject:IS_INTERSTITIAL];
        }
    }
    
    MPLogInfo(@"IronSource adUnits to init are %@" , [adUnitsSet allObjects]);
    
    if (shouldInit) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [IronSource setMediationType:[NSString stringWithFormat:@"%@%@SDK%@",
                                          kIronSourceMediationName,kIronSourceMediationVersion, [IronSourceUtils getMoPubSdkVersion]]];
            [[IronSourceManager sharedManager] initIronSourceSDKWithAppKey:appKey forAdUnits: adUnitsSet];
        });
    }
    
    if (complete != nil) {
        complete(nil);
    }
}
@end
