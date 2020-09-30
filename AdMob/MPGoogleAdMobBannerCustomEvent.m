//
//  MPGoogleAdMobBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPGoogleAdMobBannerCustomEvent.h"
#import "GoogleAdMobAdapterConfiguration.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "MPGoogleAdMobBannerCustomEvent.h"
#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif

@interface MPGoogleAdMobBannerCustomEvent () <GADBannerViewDelegate>

@property(nonatomic, strong) GADBannerView *adBannerView;

@end

@implementation MPGoogleAdMobBannerCustomEvent
@dynamic delegate;
@dynamic localExtras;

- (id)init {
  self = [super init];
  if (self) {
    self.adBannerView = [[GADBannerView alloc] initWithFrame:CGRectZero];
    self.adBannerView.delegate = self;
  }
  return self;
}

- (void)dealloc {
  self.adBannerView.delegate = nil;
}

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
  CGFloat adWidth = size.width;
  CGFloat adHeight = size.height;
    
  if (adWidth <= 0.0 || adHeight <= 0.0) {
    NSString *failureReason = @"Google AdMob banner failed to load due to invalid ad width and/or height.";
    NSError *mopubError = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:failureReason];

    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:mopubError], [self getAdNetworkId]);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:mopubError];
        
    return;
  }
    
  self.adBannerView.frame = CGRectMake(0, 0, adWidth, adHeight);
  self.adBannerView.adUnitID = [info objectForKey:@"adUnitID"];
  self.adBannerView.rootViewController = [self.delegate inlineAdAdapterViewControllerForPresentingModalView:self];
    
  GADRequest *request = [GADRequest request];
  if ([self.localExtras objectForKey:@"contentUrl"] != nil) {
      NSString *contentUrl = [self.localExtras objectForKey:@"contentUrl"];
      if ([contentUrl length] != 0) {
          request.contentURL = contentUrl;
      }
  }

  // Test device IDs can be passed via localExtras to request test ads.
  // Running in the simulator will automatically show test ads.
  if ([self.localExtras objectForKey:@"testDevices"]) {
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = self.localExtras[@"testDevices"];
  }

  if ([self.localExtras objectForKey:@"tagForChildDirectedTreatment"]) {
    [GADMobileAds.sharedInstance.requestConfiguration tagForChildDirectedTreatment:self.localExtras[@"tagForChildDirectedTreatment"]];
  }

  if ([self.localExtras objectForKey:@"tagForUnderAgeOfConsent"]) {
    [GADMobileAds.sharedInstance.requestConfiguration
     tagForUnderAgeOfConsent:self.localExtras[@"tagForUnderAgeOfConsent"]];
  }
  
  request.requestAgent = @"MoPub";

  NSString *npaValue = GoogleAdMobAdapterConfiguration.npaString;

  if (npaValue.length > 0) {
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = @{@"npa": npaValue};
    [request registerAdNetworkExtras:extras];
  }
    
  // Cache the network initialization parameters
  [GoogleAdMobAdapterConfiguration updateInitializationParameters:info];
  MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
  [self.adBannerView loadRequest:request];
}

#pragma mark GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
  MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
  MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
  MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
  [self.delegate inlineAdAdapter:self didLoadAdWithAdView:self.adBannerView];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
 
  NSString *failureReason = [NSString stringWithFormat: @"Google AdMob Banner failed to load with error: %@", error.localizedDescription];
  NSError *mopubError = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:failureReason];

  MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:mopubError], [self getAdNetworkId]);
  [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
  [self.delegate inlineAdAdapterWillBeginUserAction:self];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
  [self.delegate inlineAdAdapterDidEndUserAction:self];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
  MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

  [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

- (NSString *) getAdNetworkId {
    return (self.adBannerView) ? self.adBannerView.adUnitID : @"";
}

@end
