#import <Foundation/Foundation.h>
#import <BUFoundation/BUCommonMacros.h>
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MoPub.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PangleAdapterConfiguration :MPBaseAdapterConfiguration

// Caching
/**
 Extracts the parameters used for network SDK initialization and if all required
 parameters are present, updates the cache.
 @param parameters Ad response parameters
 */
+ (void)updateInitializationParameters:(NSDictionary *)parameters;

@property (nonatomic, copy, readonly) NSString * adapterVersion;
@property (nonatomic, copy, readonly) NSString * moPubNetworkName;
@property (nonatomic, copy, readonly) NSString * networkSdkVersion;

extern NSString * const kPangleNetworkName;
extern NSString * const kPangleAppIdKey;
extern NSString * const kPanglePlacementIdKey;

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration
                                  complete:(void(^ _Nullable)(NSError * _Nullable))complete;


// Set optional data for rewarded ad
+ (void)setUserId:(NSString *)userId;
+ (NSString *)userId;
+ (void)setRewardName:(NSString *)rewardName;
+ (NSString *)rewardName;
+ (void)setRewardAmount:(NSInteger)rewardAmount;
+ (NSInteger)rewardAmount;
+ (void)setMediaExtra:(NSString *)extra;
+ (NSString *)mediaExtra;

@end

NS_ASSUME_NONNULL_END
