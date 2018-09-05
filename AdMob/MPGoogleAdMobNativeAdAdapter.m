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
@synthesize defaultActionURL = _defaultActionURL;

- (instancetype)initWithAdMobUnifiedNativeAd:(GADUnifiedNativeAd *)adMobUnifiedNativeAd {
  if (self = [super init]) {
    self.adMobUnifiedNativeAd = adMobUnifiedNativeAd;
    self.adMobUnifiedNativeAd.delegate = self;

    // Initializing adChoicesView with default size of (20, 20).
    _adChoicesView = [[GADAdChoicesView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];

    NSMutableDictionary *properties = [NSMutableDictionary dictionary];

    if (adMobUnifiedNativeAd.headline) {
      properties[kAdTitleKey] = adMobUnifiedNativeAd.headline;
    }

    if (adMobUnifiedNativeAd.body) {
      properties[kAdTextKey] = adMobUnifiedNativeAd.body;
    }

    if (adMobUnifiedNativeAd.callToAction) {
      properties[kAdCTATextKey] = adMobUnifiedNativeAd.callToAction;
    }

    GADNativeAdImage *mainImage = (GADNativeAdImage *)adMobUnifiedNativeAd.images.firstObject;
    if ([mainImage.imageURL absoluteString]) {
      properties[kAdMainImageKey] = mainImage.imageURL.absoluteString;
    }

    if (adMobUnifiedNativeAd.icon.image) {
      properties[kAdIconImageKey] = adMobUnifiedNativeAd.icon.image;
    }

    if (adMobUnifiedNativeAd.advertiser) {
      properties[kGADMAdvertiserKey] = adMobUnifiedNativeAd.advertiser;
    }

    _properties = properties;
  }

  return self;
}

#pragma mark - <GADUnifiedNativeAdDelegate>

- (void)nativeAdDidRecordImpression:(GADUnifiedNativeAd *)nativeAd {
  // Sending impression to MoPub SDK.
  [self.delegate nativeAdWillLogImpression:self];
}

- (void)nativeAdDidRecordClick:(GADUnifiedNativeAd *)nativeAd {
  // Sending click to MoPub SDK.
  [self.delegate nativeAdDidClick:self];
}

#pragma mark - <MPNativeAdAdapter>

- (UIView *)privacyInformationIconView {
  return _adChoicesView;
}

- (BOOL)enableThirdPartyClickTracking {
  return YES;
}

@end
