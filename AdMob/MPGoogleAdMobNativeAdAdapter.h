#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPNativeAdAdapter.h"
#endif

#import <GoogleMobileAds/GoogleMobileAds.h>

/// This class implements the `MPNativeAdAdapter` and `GADUnifiedNativeAdDelegate` protocols, that allow
/// the MoPub SDK to interact with native ad objects obtained from Google Mobile Ads SDK.
@interface MPGoogleAdMobNativeAdAdapter : NSObject<MPNativeAdAdapter, GADUnifiedNativeAdDelegate>

/// MoPub native ad adapter delegate instance.
@property(nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

/// Google Mobile Ads unified native ad instance.
@property(nonatomic, strong) GADUnifiedNativeAd *adMobUnifiedNativeAd;

/// Google Mobile Ads container view to hold the AdChoices icon.
@property(nonatomic, strong) GADAdChoicesView *adChoicesView;

/// Returns an MPGoogleAdMobNativeAdAdapter with GADUnifiedNativeAd.
- (instancetype)initWithAdMobUnifiedNativeAd:(GADUnifiedNativeAd *)adMobUnifiedNativeAd;

@end
