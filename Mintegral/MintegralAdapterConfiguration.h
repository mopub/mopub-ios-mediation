#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MPBaseAdapterConfiguration.h"
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kMintegralErrorDomain;

@interface MintegralAdapterConfiguration : MPBaseAdapterConfiguration

/**
 Extracts the parameters used for network SDK initialization and if all required
 parameters are present, updates the cache.
 @param parameters Ad response parameters
 */
+ (void)updateInitializationParameters:(NSDictionary *)parameters;

@property (nonatomic, copy, readonly) NSString * adapterVersion;
@property (nonatomic, copy, readonly, nullable) NSString * biddingToken;
@property (nonatomic, copy, readonly) NSString * moPubNetworkName;
@property (nonatomic, copy, readonly) NSString * networkSdkVersion;

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration
                                  complete:(void(^ _Nullable)(NSError * _Nullable))complete;

+(BOOL)isSDKInitialized;

+(void)sdkInitialized;

+(BOOL)isMute;

+(void)setMute:(BOOL)muteStatus;

+(void)initializeMintegral:(NSDictionary *)info setAppID:(nonnull NSString *)appId appKey:(nonnull NSString *)appKey;

@end

NS_ASSUME_NONNULL_END
