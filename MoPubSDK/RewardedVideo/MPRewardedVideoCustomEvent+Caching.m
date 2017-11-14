//
//  MPRewardedVideoCustomEvent+Caching.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPRewardedVideoCustomEvent+Caching.h"
#import "MPLogging.h"

static NSString * const kNetworkSDKInitializationParametersKey = @"com.mopub.mopub-ios-sdk.network-init-info";

@implementation MPRewardedVideoCustomEvent (Caching)

- (void)setCachedInitializationParameters:(NSDictionary * _Nullable)params {
    NSString * networkName = NSStringFromClass([self class]);

    [MPRewardedVideoCustomEvent setCachedInitializationParameters:params forNetwork:networkName];
}

+ (void)setCachedInitializationParameters:(NSDictionary * _Nullable)params forNetwork:(NSString * _Nonnull)network {
    // Empty network names and parameters are invalid.
    if (network.length == 0 || params == nil) {
        return;
    }

    @synchronized (self) {
        NSMutableDictionary * cachedParameters = [[[NSUserDefaults standardUserDefaults] objectForKey:kNetworkSDKInitializationParametersKey] mutableCopy];
        if (cachedParameters == nil) {
            cachedParameters = [NSMutableDictionary dictionaryWithCapacity:1];
        }

        cachedParameters[network] = params;
        [[NSUserDefaults standardUserDefaults] setObject:cachedParameters forKey:kNetworkSDKInitializationParametersKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        MPLogInfo(@"Cached SDK initialization parameters for %@:\n%@", network, params);
    }
}

- (NSDictionary * _Nullable)cachedInitializationParameters {
    NSString * networkName = NSStringFromClass([self class]);

    return [MPRewardedVideoCustomEvent cachedInitializationParametersForNetwork:networkName];
}

+ (NSDictionary * _Nullable)cachedInitializationParametersForNetwork:(NSString * _Nonnull)network {
    // Empty network names are invalid.
    if (network.length == 0) {
        return nil;
    }

    NSDictionary * cachedParameters = [[NSUserDefaults standardUserDefaults] objectForKey:kNetworkSDKInitializationParametersKey];
    if (cachedParameters == nil) {
        return nil;
    }

    return [cachedParameters objectForKey:network];
}

+ (NSArray<NSString *> * _Nullable)allCachedNetworks {
    NSDictionary * cachedParameters = [[NSUserDefaults standardUserDefaults] objectForKey:kNetworkSDKInitializationParametersKey];

    return [cachedParameters allKeys];
}

+ (void)clearCache {
    @synchronized (self) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNetworkSDKInitializationParametersKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        MPLogInfo(@"Cleared cached SDK initialization parameters");
    }
}

@end
