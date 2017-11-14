//
//  MPRewardedVideoCustomEvent+Caching.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPRewardedVideoCustomEvent.h"

/**
 * Provides caching support for network SDK initialization parameters.
 */
@interface MPRewardedVideoCustomEvent (Caching)

/**
 * Updates the initialization parameters for the current network.
 * @param params New set of initialization parameters. Nothing will be done if `nil` is passed in.
 */
- (void)setCachedInitializationParameters:(NSDictionary * _Nullable)params;

/**
 * Updates the initialization parameters for the network.
 * @param params New set of initialization parameters. Nothing will be done if `nil` is passed in.
 * @param network The name of the network. This value should not be `nil`.
 */
+ (void)setCachedInitializationParameters:(NSDictionary * _Nullable)params forNetwork:(NSString * _Nonnull)network;

/**
 * Retrieves the initialization parameters for the current network (if any).
 * @return The cached initialization parameters for the network. This may be `nil` if not parameters were found.
 */
- (NSDictionary * _Nullable)cachedInitializationParameters;

/**
 * Retrieves the initialization parameters for the network (if any).
 * @param network The name of the network. This value should not be `nil`.
 * @return The cached initialization parameters for the network. This may be `nil` if not parameters were found.
 */
+ (NSDictionary * _Nullable)cachedInitializationParametersForNetwork:(NSString * _Nonnull)network;

/**
 * Retrieves a list of all the currently cached networks.
 * @return A list of all currently cached networks or `nil`.
 */
+ (NSArray<NSString *> * _Nullable)allCachedNetworks;

/**
 * Clears the cache of all network SDK initialization information.
 */
+ (void)clearCache;

@end
