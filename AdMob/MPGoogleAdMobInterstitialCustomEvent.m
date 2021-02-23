//
//  MPGoogleAdMobInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPGoogleAdMobInterstitialCustomEvent.h"
#import "GoogleAdMobAdapterConfiguration.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif
#import <CoreLocation/CoreLocation.h>

@interface MPGoogleAdMobInterstitialCustomEvent () <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADInterstitialAd *interstitial;
@property(nonatomic, copy) NSString *admobAdUnitId;

@end

@implementation MPGoogleAdMobInterstitialCustomEvent
@dynamic delegate;
@dynamic localExtras;

@synthesize interstitial = _interstitial;

- (void)dealloc {
    self.interstitial.fullScreenContentDelegate = nil;
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return self.interstitial;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.admobAdUnitId = [info objectForKey:@"adUnitID"];
    
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
    
    // Consent collected from the MoPub’s consent dialogue should not be used to set up Google's
    // personalization preference. Publishers should work with Google to be GDPR-compliant.
    
    NSString *npaValue = GoogleAdMobAdapterConfiguration.npaString;
    
    if (npaValue.length > 0) {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{@"npa": npaValue};
        [request registerAdNetworkExtras:extras];
    }
    
    // Cache the network initialization parameters
    [GoogleAdMobAdapterConfiguration updateInitializationParameters:info];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
    
    [GADInterstitialAd loadWithAdUnitID:self.admobAdUnitId
                                request:request
                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
      if (error) {
        NSLog(@"Failed to load Google interstitial ad with error: %@", [error localizedDescription]);
        return;
      }

      self.interstitial = ad;
      self.interstitial.fullScreenContentDelegate = self;
        
      MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
      [self.delegate fullscreenAdAdapterDidLoadAd:self];
    }];
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    if (self.interstitial) {
      [self.interstitial presentFromRootViewController:viewController];
    } else {
      NSError *mopubError = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"Failed to show Google interstitial. An ad wasn't ready"];
      [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:mopubError];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - GADFullScreenContentDelegate

- (void)adDidPresentFullScreenContent:(id)ad {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    NSString *failureReason = [NSString stringWithFormat: @"Google interstitial failed to show with error: %@", error.localizedDescription];
    NSError *mopubError = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:failureReason];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:mopubError], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:mopubError];
}

- (void)adDidDismissFullScreenContent:(id)ad {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (NSString *) getAdNetworkId {
    return self.admobAdUnitId;
}

@dynamic hasAdAvailable;

@end
