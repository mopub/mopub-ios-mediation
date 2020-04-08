#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPBaseAdapterConfiguration.h"
#endif
    #import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kMintegralErrorDomain;

@interface MintegralAdapterConfiguration : MPBaseAdapterConfiguration

@property (nonatomic, copy, readonly) NSString * adapterVersion;

@property (nonatomic, copy, readonly, nullable) NSString * biddingToken;

@property (nonatomic, copy, readonly) NSString * moPubNetworkName;

@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> * moPubRequestOptions;

@property (nonatomic, copy, readonly) NSString * networkSdkVersion;

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration
                                  complete:(void(^ _Nullable)(NSError * _Nullable))complete;

- (void)addMoPubRequestOptions:(NSDictionary<NSString *, NSString *> *)options;

+ (void)setCachedInitializationParameters:(NSDictionary<NSString *, id> * _Nullable)parameters;

+ (NSDictionary<NSString *, id> * _Nullable)cachedInitializationParameters;

+(BOOL)isSDKInitialized;

+(void)sdkInitialized;

+(BOOL)isMute;

+(void)setMute:(BOOL)muteStatus;

+(void)initializeMintegral:(NSDictionary *)info setAppID:(nonnull NSString *)appId appKey:(nonnull NSString *)appKey;

@end

NS_ASSUME_NONNULL_END
