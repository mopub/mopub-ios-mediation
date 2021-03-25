#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MPNativeAdAdapter.h"
#endif

#import <GoogleMobileAds/GoogleMobileAds.h>

/// This class implements the `MPNativeAdAdapter` and `GADNativeAdDelegate` protocols, that
/// allow the MoPub SDK to interact with native ad objects obtained from Google Mobile Ads SDK.
@interface MPGoogleAdMobNativeAdAdapter : NSObject <MPNativeAdAdapter, GADNativeAdDelegate>

/// MoPub native ad adapter delegate instance.
@property(nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

/// Google Mobile Ads Native ad instance.
@property(nonatomic, strong) GADNativeAd *googleNativeAd;

/// Google Mobile Ads adView to hold the native ad view.
@property(nonatomic, strong) GADNativeAdView *adMobNativeAdView;

/// Returns an MPGoogleAdMobNativeAdAdapter with GADNativeAd.
- (instancetype)initWithAdMobNativeAd:(GADNativeAd *)adMobNativeAd
                         nativeAdView:(GADNativeAdView *)adMobNativeAdView;

@end

