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
    return @"6.8.4.2.0";
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    // ⚠️ Do not change this value! ⚠️
    return @"Ironsource";
}

- (NSString *)networkSdkVersion {
    return [IronSource sdkVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    NSString * appKey = configuration[kIronSourceAppKey];
    if ([appKey length] == 0) {
        MPLogInfo(@"IronSource Adapter failed to initialize, 'applicationKey' parameter is missing. Make sure that 'applicationKey' server parameter is added");
        
        if (complete != nil) {
            complete(nil);
        }
        return;
    }
    
    MPLogInfo(@"Initializing IronSource with appkey %@", appKey);
    dispatch_async(dispatch_get_main_queue(), ^{
    [IronSource setMediationType:[NSString stringWithFormat:@"%@%@SDK%@",
                                  kIronSourceMediationName,kIronSourceMediationVersion, [IronSourceUtils getMoPubSdkVersion]]];
    [[IronSourceManager sharedManager] initIronSourceSDKWithAppKey:appKey forAdUnits:[NSSet setWithObjects:IS_REWARDED_VIDEO,IS_INTERSTITIAL, nil]];
    });
    if (complete != nil) {
        complete(nil);
    }
}
@end
