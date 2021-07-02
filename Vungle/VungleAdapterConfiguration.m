//
//  VungleAdapterConfiguration.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <VungleSDK/VungleSDK.h>
#import "VungleAdapterConfiguration.h"
#import "VungleRouter.h"

#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif

// Errors
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-vungle-adapters";

NSString * const kVNGSDKOptionsMinSpaceForInit = @"vngMinSpaceForInit";
NSString * const kVNGSDKOptionsMinSpaceForAdLoad = @"vngMinSpaceForAdLoad";
NSString * const kVNGSDKOptionsOrientations = @"orientations";

static NSString *mOrientations;

static NSString *bidToken = nil;

typedef NS_ENUM(NSInteger, VungleAdapterErrorCode) {
    VungleAdapterErrorCodeMissingAppId,
};

@implementation VungleAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * appId = parameters[kVungleAppIdKey];
    
    if (appId != nil) {
        NSDictionary * configuration = @{ kVungleAppIdKey: appId };
        [VungleAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"6.9.2.1";
}

- (NSString *)biddingToken {
    NSString *token = [[VungleRouter sharedRouter] currentSuperToken];
    if (token.length > 0) {
        bidToken = token;
    }
    
    return bidToken;
}

- (NSString *)moPubNetworkName {
    // ⚠️ Do not change this value! ⚠️
    return @"vungle";
}

- (NSString *)networkSdkVersion {
    return VungleSDKVersion;
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    NSString * appId = configuration[kVungleAppIdKey];
    
    if (configuration[kVungleSDKCollectDevice]) {
        // Check if publisher has set this value and update Vungle here.
        // Even if we don't have an app ID, we want to update the SDK with this value now.
        self.shouldCollectDeviceId = [configuration[kVungleSDKCollectDevice] boolValue];
        [VungleRouter.sharedRouter setShouldCollectDeviceId:self.shouldCollectDeviceId];
    }
    
    if (configuration[kVNGSDKOptionsOrientations]){
        mOrientations = configuration[kVNGSDKOptionsOrientations];
    }
    
    NSMutableDictionary *sizeOverrideDict = [NSMutableDictionary dictionary];
    if (configuration[kVNGSDKOptionsMinSpaceForInit]) {
        [sizeOverrideDict setValue:configuration[kVNGSDKOptionsMinSpaceForInit] forKey:kVungleSDKMinSpaceForInit];
    } else {
        [sizeOverrideDict setValue:@(0) forKey:kVungleSDKMinSpaceForInit];
    }
    
    if (configuration[kVNGSDKOptionsMinSpaceForAdLoad]) {
        [sizeOverrideDict setValue:configuration[kVNGSDKOptionsMinSpaceForAdLoad] forKey:kVungleSDKMinSpaceForAdRequest];
        [sizeOverrideDict setValue:configuration[kVNGSDKOptionsMinSpaceForAdLoad] forKey:kVungleSDKMinSpaceForAssetLoad];
    } else {
        [sizeOverrideDict setValue:@(0) forKey:kVungleSDKMinSpaceForAdRequest];
        [sizeOverrideDict setValue:@(0) forKey:kVungleSDKMinSpaceForAssetLoad];
    }
    
    if (sizeOverrideDict.count > 0) {
        [VungleRouter.sharedRouter setSDKOptions:sizeOverrideDict];
    }
    
    if (appId == nil) {
        NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:VungleAdapterErrorCodeMissingAppId userInfo:@{ NSLocalizedDescriptionKey: @"Missing the appId parameter when configuring your network in the MoPub website." }];
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        return;
    }
    
    [VungleRouter.sharedRouter initializeSdkWithInfo:configuration];
    
    if (complete != nil) {
        complete(nil);
    }
}

// (Optional) Set rewarded video playback orientation
+ (NSString *)orientations {
    return mOrientations;
}

@end
