#import "MPGoogleAdMobNativeAdAdapter.h"

#if __has_include("MoPub.h")
#import "MPLogging.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdError.h"
#endif

static NSString *const kGADMAdvertiserKey = @"advertiser";
static NSString *const kGADMPriceKey = @"price";
static NSString *const kGADMStoreKey = @"store";

@implementation MPGoogleAdMobNativeAdAdapter

@synthesize properties = _properties;

- (instancetype)initWithAdMobNativeAd:(GADNativeAd *)adMobNativeAd
                         nativeAdView:(GADNativeAdView *)adMobNativeAdView {
  if (self = [super init]) {
    self.googleNativeAd = adMobNativeAd;
    self.googleNativeAd.delegate = self;
    self.adMobNativeAdView = adMobNativeAdView;

    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    if (adMobNativeAd.headline) {
      properties[kAdTitleKey] = adMobNativeAd.headline;
    }

    if ([adMobNativeAd.icon.imageURL absoluteString]) {
      properties[kAdIconImageKey] = adMobNativeAd.icon.imageURL.absoluteString;
    }

    if (adMobNativeAd.body) {
      properties[kAdTextKey] = adMobNativeAd.body;
    }

    if (adMobNativeAd.starRating) {
      properties[kAdStarRatingKey] = adMobNativeAd.starRating;
    }

    if (adMobNativeAd.callToAction) {
      properties[kAdCTATextKey] = adMobNativeAd.callToAction;
    }

    if (adMobNativeAd.price) {
      properties[kGADMPriceKey] = adMobNativeAd.price;
    }

    if (adMobNativeAd.store) {
      properties[kGADMStoreKey] = adMobNativeAd.store;
    }

    if (adMobNativeAdView.mediaView) {
      properties[kAdMainMediaViewKey] = self.adMobNativeAdView.mediaView;
    }

    _properties = properties;
  }

  return self;
}

#pragma mark - <GADNativeAdDelegate>

- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd {
  // Sending impression to MoPub SDK.
  [self.delegate nativeAdWillLogImpression:self];
  MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], nil);
  MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], nil);
}

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
  // Sending click to MoPub SDK.
  [self.delegate nativeAdDidClick:self];
  MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], nil);
}

#pragma mark - <MPNativeAdAdapter>

- (UIView *)privacyInformationIconView {
  return self.adMobNativeAdView.adChoicesView;
}

- (UIView *)mainMediaView {
  return self.adMobNativeAdView.mediaView;
}

- (NSURL *)defaultActionURL {
  return nil;
}

- (BOOL)enableThirdPartyClickTracking {
  return YES;
}

@end

