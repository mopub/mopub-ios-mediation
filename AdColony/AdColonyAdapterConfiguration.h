//
//  AdColonyAdapterConfiguration.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPBaseAdapterConfiguration.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Provides adapter information back to the SDK and is the main access point
 for all adapter-level configuration.
 */
@interface AdColonyAdapterConfiguration : MPBaseAdapterConfiguration
// Caching
/**
 Extracts the parameters used for network SDK initialization and if all required
 parameters are present, updates the cache.
 @param parameters Ad response parameters
 */
+ (void)updateInitializationParameters:(NSDictionary *)parameters;

// MPAdapterConfiguration
extern NSString * const APPLICATION_ID_KEY;
extern NSString * const ZONE_ID_KEY;
extern NSString * const ALL_ZONE_IDS_KEY;
extern NSString * const USER_ID_KEY;

@property (nonatomic, copy, readonly) NSString * adapterVersion;
@property (nonatomic, copy, readonly) NSString * biddingToken;
@property (nonatomic, copy, readonly) NSString * moPubNetworkName;
@property (nonatomic, copy, readonly) NSString * networkSdkVersion;

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration
                                  complete:(void(^ _Nullable)(NSError * _Nullable))complete;

+ (NSError *)validateParameter:(NSString *)parameter forOperation:(NSString *)operation;

+ (NSError *)validateZoneIds:(NSArray *)zoneIds forOperation:(NSString *)operation;

+ (NSError *)createErrorForOperation:(NSString *)operation forParameter:(NSString *)parameter;

+ (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reason andSuggestion:(NSString *)suggestion;

@end

NS_ASSUME_NONNULL_END
