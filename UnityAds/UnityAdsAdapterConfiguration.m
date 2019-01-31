//
//  UnityAdsAdapterConfiguration.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <UnityAds/UnityAds.h>
#import "UnityAdsAdapterConfiguration.h"
#import "MPUnityRouter.h"
#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif

// Initialization configuration keys
static NSString * const kUnityAdsGameId = @"gameId";

// Errors
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-unity-adapters";

typedef NS_ENUM(NSInteger, UnityAdsAdapterErrorCode) {
    UnityAdsAdapterErrorCodeMissingGameId,
};

@implementation UnityAdsAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * gameId = parameters[kUnityAdsGameId];
    
    if (gameId != nil) {
        NSDictionary * configuration = @{ kUnityAdsGameId: gameId };
        [UnityAdsAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"3.0.0.1";
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return @"unity";
}

- (NSString *)networkSdkVersion {
    return [UnityAds getVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    NSString * gameId = configuration[kUnityAdsGameId];
    if (gameId == nil) {
        NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:UnityAdsAdapterErrorCodeMissingGameId userInfo:@{ NSLocalizedDescriptionKey: @"Unity Ads initialization skipped. The gameId is empty. Ensure it is properly configured on the MoPub dashboard." }];
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        return;
    }
    
    [[MPUnityRouter sharedRouter] initializeWithGameId:gameId];
    if (complete != nil) {
        complete(nil);
    }
}

@end
