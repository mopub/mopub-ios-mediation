#import <BUAdSDK/BUNativeAd.h>
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPNativeAdAdapter.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PangleNativeAdAdapter : NSObject  <MPNativeAdAdapter>

@property(nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) NSDictionary *properties;
@property (nonatomic, strong) NSURL *defaultActionURL;
- (instancetype)initWithBUNativeAd:(BUNativeAd *)nativeAd placementId:(NSString *)placementId;

@end

NS_ASSUME_NONNULL_END

