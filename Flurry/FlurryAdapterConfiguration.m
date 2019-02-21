//
//  FlurryAdapterConfiguration.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "FlurryAdapterConfiguration.h"
#import "FlurryMPConfig.h"

#if __has_include(<Flurry_iOS_SDK/Flurry.h>)
#import <Flurry_iOS_SDK/Flurry.h>
#import <Flurry_iOS_SDK/FlurryAdError.h>
#else
#import "Flurry.h"
#import "FlurryAdError.h"
#endif

#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

// Initialization configuration keys
static NSString * const kFlurryApiKey = @"apiKey";

// Errors
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-flurry-adapters";

typedef NS_ENUM(NSInteger, FlurryAdapterErrorCode) {
    FlurryAdapterErrorCodeMissingApiKey,
};

@implementation FlurryAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * apiKey = parameters[kFlurryApiKey];
    
    if (apiKey != nil) {
        NSDictionary * configuration = @{ kFlurryApiKey: apiKey };
        [FlurryAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return FlurryAdapterVersion;
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    // ⚠️ Do not change this value! ⚠️
    return @"yahoo";
}

- (NSString *)networkSdkVersion {
    return [Flurry getFlurryAgentVersion];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    NSString * apiKey = configuration[kFlurryApiKey];
    if (apiKey == nil) {
        NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:FlurryAdapterErrorCodeMissingApiKey userInfo:@{ NSLocalizedDescriptionKey: @"Missing FLURRY_APIKEY" }];
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [FlurryMPConfig startSessionWithApiKey:apiKey];
    });
    
    if (complete != nil) {
        complete(nil);
    }
}

@end
