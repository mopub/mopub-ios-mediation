#import "MPGoogleAdMobNativeCustomEvent.h"
#import "MPGoogleAdMobNativeAdAdapter.h"
#if __has_include("MoPub.h")
#import "MPLogging.h"
#import "MPNativeAd.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdError.h"
#import "MPNativeAdUtils.h"
#endif


#import "UIView+MPGoogleAdMobAdditions.h"

/// Holds the preferred location of the AdChoices icon.
static GADAdChoicesPosition adChoicesPosition;

@interface MPGoogleAdMobNativeCustomEvent () <GADAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate>

/// GADAdLoader instance.
@property(nonatomic, strong) GADAdLoader *adLoader;

@end

@implementation MPGoogleAdMobNativeCustomEvent

+ (void)setAdChoicesPosition:(GADAdChoicesPosition)position {
  // Since this adapter only supports one position for all instances of native ads, publishers might
  // access this class method in multiple threads and try to set the position for various native
  // ads, so its better to use synchronized block to make "adChoicesPosition" variable thread safe.
  @synchronized([self class]) {
    adChoicesPosition = position;
  }
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info {
  NSString *applicationID = [info objectForKey:@"appid"];
  if (applicationID) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      [GADMobileAds configureWithApplicationID:applicationID];
    });
  }
  NSString *adUnitID = info[@"adunit"];
  if (!adUnitID) {
    [self.delegate nativeCustomEvent:self
            didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(
                                         @"Ad unit ID cannot be nil.")];
    return;
  }

  UIWindow *window = [UIApplication sharedApplication].keyWindow;
  UIViewController *rootViewController = window.rootViewController;
  while (rootViewController.presentedViewController) {
    rootViewController = rootViewController.presentedViewController;
  }
  GADRequest *request = [GADRequest request];
  if ([self.localExtras objectForKey:@"testDevices"]) {
    request.testDevices = self.localExtras[@"testDevices"];
  }
  request.requestAgent = @"MoPub";
    
  if ([self.localExtras objectForKey:@"contentUrl"] != nil) {
      NSString *contentUrl = [self.localExtras objectForKey:@"contentUrl"];
      if ([contentUrl length] != 0) {
          request.contentURL = contentUrl;
      }
  }

  GADNativeAdImageAdLoaderOptions *nativeAdImageLoaderOptions =
      [[GADNativeAdImageAdLoaderOptions alloc] init];
  nativeAdImageLoaderOptions.shouldRequestMultipleImages = NO;
  nativeAdImageLoaderOptions.preferredImageOrientation =
      GADNativeAdImageAdLoaderOptionsOrientationAny;

  // In GADNativeAdViewAdOptions, the default preferredAdChoicesPosition is
  // GADAdChoicesPositionTopRightCorner.
  GADNativeAdViewAdOptions *nativeAdViewAdOptions = [[GADNativeAdViewAdOptions alloc] init];
  nativeAdViewAdOptions.preferredAdChoicesPosition = adChoicesPosition;

  self.adLoader =
      [[GADAdLoader alloc] initWithAdUnitID:adUnitID
                         rootViewController:rootViewController
                                    adTypes:@[ kGADAdLoaderAdTypeUnifiedNative ]
                                    options:@[ nativeAdImageLoaderOptions, nativeAdViewAdOptions ]];
  self.adLoader.delegate = self;


  // Consent collected from the MoPub’s consent dialogue should not be used to set up
  // Google's personalization preference. Publishers should work with Google to be GDPR-compliant.


  MPGoogleGlobalMediationSettings *medSettings = [[MoPub sharedInstance]
      globalMediationSettingsForClass:[MPGoogleGlobalMediationSettings class]];

  if (medSettings.npa) {
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = @{@"npa" : medSettings.npa};
    [request registerAdNetworkExtras:extras];
  }

  [self.adLoader loadRequest:request];
}

#pragma mark GADAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
  [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

#pragma mark GADUnifiedNativeAdLoaderDelegate implementation

- (void)adLoader:(nonnull GADAdLoader *)adLoader
    didReceiveUnifiedNativeAd:(nonnull GADUnifiedNativeAd *)nativeAd {
  if (![self isValidUnifiedNativeAd:nativeAd]) {
    MPLogInfo(
        @"Unified native ad is missing one or more required assets, failing the request");
    [self.delegate nativeCustomEvent:self
            didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(
                                         @"Missing one or more required assets.")];
    return;
  }

  GADUnifiedNativeAdView *gadUnifiedNativeAdView = [[GADUnifiedNativeAdView alloc] init];

  GADAdChoicesView *adChoicesView = [[GADAdChoicesView alloc] initWithFrame:CGRectZero];
  adChoicesView.userInteractionEnabled = NO;
  [gadUnifiedNativeAdView addSubview:adChoicesView];
  gadUnifiedNativeAdView.adChoicesView = adChoicesView;

  GADMediaView *mediaView = [[GADMediaView alloc] initWithFrame:CGRectZero];
  [gadUnifiedNativeAdView addSubview:mediaView];
  gadUnifiedNativeAdView.mediaView = mediaView;

  gadUnifiedNativeAdView.nativeAd = nativeAd;

  UILabel *headlineView = [[UILabel alloc] initWithFrame:CGRectZero];
  headlineView.text = nativeAd.headline;
  headlineView.textColor = [UIColor clearColor];
  [gadUnifiedNativeAdView addSubview:headlineView];
  gadUnifiedNativeAdView.headlineView = headlineView;

  UILabel *bodyView = [[UILabel alloc] initWithFrame:CGRectZero];
  bodyView.text = nativeAd.body;
  bodyView.textColor = [UIColor clearColor];
  [gadUnifiedNativeAdView addSubview:bodyView];
  gadUnifiedNativeAdView.bodyView = bodyView;

  UILabel *callToActionView = [[UILabel alloc] initWithFrame:CGRectZero];
  callToActionView.text = nativeAd.callToAction;
  callToActionView.textColor = [UIColor clearColor];
  [gadUnifiedNativeAdView addSubview:callToActionView];
  gadUnifiedNativeAdView.callToActionView = callToActionView;

  UIImageView *mainMediaImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
  mainMediaImageView.image = nativeAd.images.firstObject.image;
  [gadUnifiedNativeAdView addSubview:mainMediaImageView];
  gadUnifiedNativeAdView.imageView = mainMediaImageView;

  UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
  iconView.image = nativeAd.icon.image;
  [gadUnifiedNativeAdView addSubview:iconView];
  gadUnifiedNativeAdView.iconView = iconView;

  MPGoogleAdMobNativeAdAdapter *adapter =
      [[MPGoogleAdMobNativeAdAdapter alloc] initWithAdMobUnifiedNativeAd:nativeAd
                                                     unifiedNativeAdView:gadUnifiedNativeAdView];
  MPNativeAd *moPubNativeAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];

  NSMutableArray *imageURLs = [NSMutableArray array];

  if ([moPubNativeAd.properties[kAdIconImageKey] length]) {
    if (![MPNativeAdUtils addURLString:moPubNativeAd.properties[kAdIconImageKey]
                            toURLArray:imageURLs]) {
      [self.delegate nativeCustomEvent:self
              didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidImageURL()];
    }
  }

  [super precacheImagesWithURLs:imageURLs
                completionBlock:^(NSArray *errors) {
                  if (errors) {
                    [self.delegate nativeCustomEvent:self
                            didFailToLoadAdWithError:MPNativeAdNSErrorForImageDownloadFailure()];
                  } else {
                    [self.delegate nativeCustomEvent:self didLoadAd:moPubNativeAd];
                  }
                }];
}

#pragma mark - Private Methods

/// Checks the unified native ad has required assets or not.
- (BOOL)isValidUnifiedNativeAd:(GADUnifiedNativeAd *)unifiedNativeAd {
  return (unifiedNativeAd.headline && unifiedNativeAd.body && unifiedNativeAd.icon &&
          unifiedNativeAd.images.count && unifiedNativeAd.callToAction);
}

@end

