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
    return @"7.39.0.0";
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return @"admob_native";
}

- (NSString *)networkSdkVersion {
    return @"7.37.0";
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    // Verify application ID exists
    NSString * appId = configuration[kAdMobApplicationIdKey];
    if (appId == nil) {
        NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:AdMobAdapterErrorCodeMissingAppId userInfo:@{ NSLocalizedDescriptionKey: @"AdMob's initialization skipped. The appId is empty. Ensure it is properly configured on the MoPub dashboard." }];
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [GADMobileAds configureWithApplicationID:appId];
        });
    });
    
    if (complete != nil) {
        complete(nil);
    }
}

@end
