#import <OguryAds/OguryAds.h>

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MPBaseAdapterConfiguration.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Constants

extern NSString * const kOguryConfigurationAdUnitId;

@interface OguryAdapterConfiguration : MPBaseAdapterConfiguration

/**
 Extracts the parameters used for network SDK initialization and if all required
 parameters are present, updates the cache.
 @param parameters Ad response parameters
 */
+ (void)updateInitializationParameters:(NSDictionary *)parameters;

@property (nonatomic, copy, readonly) NSString *adapterVersion;
@property (nonatomic, copy, readonly) NSString *biddingToken;
@property (nonatomic, copy, readonly) NSString *moPubNetworkName;
@property (nonatomic, copy, readonly) NSString *networkSdkVersion;

#pragma mark - Methods

+ (NSError *)MoPubErrorFromOguryError:(OguryAdsErrorType)oguryError;

@end

NS_ASSUME_NONNULL_END
