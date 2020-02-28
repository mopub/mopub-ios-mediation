//
//  GoogleAdMobAdapterConfiguration.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "GoogleAdMobAdapterConfiguration.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

// Initialization configuration keys
static NSString * const kAdMobApplicationIdKey = @"appid";

// Errors
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-admob-adapters";

typedef NS_ENUM(NSInteger, AdMobAdapterErrorCode) {
    AdMobAdapterErrorCodeMissingAppId,
};

@implementation GoogleAdMobAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * appId = parameters[kAdMobApplicationIdKey];
    
    if (appId != nil) {
        NSDictionary * configuration = @{ kAdMobApplicationIdKey: appId };
        [GoogleAdMobAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"7.55.1.0";
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return @"admob_native";
}

- (NSString *)networkSdkVersion {
    return @"7.55.1";
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
          [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status){
            MPLogInfo(@"Google Mobile Ads SDK initialized succesfully.");
            if (complete != nil) {
              complete(nil);
            }
          }];
        });
    });
}

// MoPub collects GDPR consent on behalf of Google
+ (NSString *)npaString
{
    return !MoPub.sharedInstance.canCollectPersonalInfo ? @"1" : @"";
}

@end

