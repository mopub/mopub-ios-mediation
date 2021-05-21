#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MPNativeAdAdapter.h"
#endif

@class  MTGNativeAdManager;
@class MTGBidNativeAdManager;

extern NSString *const kMTGVideoAdsEnabledKey;

@interface MintegralNativeAdAdapter : NSObject <MPNativeAdAdapter>
@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;
@property (nonatomic, readonly) NSArray *nativeAds;

- (instancetype)initWithNativeAds:(NSArray *)nativeAds nativeAdManager:(MTGNativeAdManager *)nativeAdManager bidAdManager:(MTGBidNativeAdManager *)bidAdManager withUnitId:(NSString *)unitId;

@end
