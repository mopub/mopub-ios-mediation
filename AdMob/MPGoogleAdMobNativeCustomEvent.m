#import "MPGoogleAdMobNativeAdAdapter.h"
#import "MPGoogleAdMobNativeCustomEvent.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPNativeAd.h"
    #import "MPNativeAdConstants.h"
    #import "MPNativeAdError.h"
    #import "MPNativeAdUtils.h"
#endif

static void MPGoogleLogInfo(NSString *message) {
  message = [[NSString alloc] initWithFormat:@"<Google Adapter> - %@", message];
  MPLogInfo(message);
}

/// Holds the preferred location of the AdChoices icon.
static GADAdChoicesPosition adChoicesPosition;

@interface MPGoogleAdMobNativeCustomEvent () <
    GADAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate>

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
  request.requestAgent = @"MoPub";
  GADNativeAdImageAdLoaderOptions *nativeAdImageLoaderOptions =
      [[GADNativeAdImageAdLoaderOptions alloc] init];
  nativeAdImageLoaderOptions.disableImageLoading = YES;
  nativeAdImageLoaderOptions.shouldRequestMultipleImages = NO;
  nativeAdImageLoaderOptions.preferredImageOrientation =
      GADNativeAdImageAdLoaderOptionsOrientationAny;

  // In GADNativeAdViewAdOptions, the default preferredAdChoicesPosition is
  // GADAdChoicesPositionTopRightCorner.
  GADNativeAdViewAdOptions *nativeAdViewAdOptions = [[GADNativeAdViewAdOptions alloc] init];
  nativeAdViewAdOptions.preferredAdChoicesPosition = adChoicesPosition;

  self.adLoader = [[GADAdLoader alloc]
        initWithAdUnitID:adUnitID
      rootViewController:rootViewController
                 adTypes:@[ kGADAdLoaderAdTypeNativeAppInstall, kGADAdLoaderAdTypeNativeContent ]
                 options:@[ nativeAdImageLoaderOptions, nativeAdViewAdOptions ]];
  self.adLoader.delegate = self;
    
  // Consent collected from the MoPub’s consent dialogue should not be used to set up Google's personalization preference. Publishers should work with Google to be GDPR-compliant.
    
  MPGoogleGlobalMediationSettings *medSettings = [[MoPub sharedInstance] globalMediationSettingsForClass:[MPGoogleGlobalMediationSettings class]];
    
  if (medSettings.npa) {
      GADExtras *extras = [[GADExtras alloc] init];
      extras.additionalParameters = @{@"npa": medSettings.npa};
      [request registerAdNetworkExtras:extras];
  }
    
  [self.adLoader loadRequest:request];
}

#pragma mark GADAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
  [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

#pragma mark GADUnifiedNativeAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd {
  if (![self isValidUnifiedNativeAd:nativeAd]) {
    MPGoogleLogInfo(@"App install ad is missing one or more required assets, failing the request");
    [self.delegate nativeCustomEvent:self
            didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(
                                         @"Missing one or more required assets.")];
    return;
  }

  MPGoogleAdMobNativeAdAdapter *adapter =
      [[MPGoogleAdMobNativeAdAdapter alloc] initWithAdMobUnifiedNativeAd:nativeAd];
  MPNativeAd *moPubNativeAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];

  NSMutableArray *imageURLs = [NSMutableArray array];

  if ([moPubNativeAd.properties[kAdIconImageKey] length]) {
    if (![MPNativeAdUtils addURLString:moPubNativeAd.properties[kAdIconImageKey]
                            toURLArray:imageURLs]) {
      [self.delegate nativeCustomEvent:self
              didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidImageURL()];
    }
  }

  if ([moPubNativeAd.properties[kAdMainImageKey] length]) {
    if (![MPNativeAdUtils addURLString:moPubNativeAd.properties[kAdMainImageKey]
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
- (BOOL)isValidUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd {
  return (nativeAd.headline && nativeAd.body && nativeAd.icon &&
          nativeAd.images.count && nativeAd.callToAction);
}

@end
