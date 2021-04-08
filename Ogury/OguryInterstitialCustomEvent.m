//
//  Copyright © 2019 Ogury Ltd. All rights reserved.
//

#import "OguryInterstitialCustomEvent.h"
#import <OguryAds/OguryAds.h>
#import "OguryAdapterConfiguration.h"

@interface OguryInterstitialCustomEvent() <OguryAdsInterstitialDelegate>

#pragma mark - Properties

@property (nonatomic, strong) OguryAdsInterstitial *interstitial;

@end

@implementation OguryInterstitialCustomEvent

#pragma mark - Methods

- (void)dealloc {
    self.interstitial.interstitialDelegate = nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.interstitial = [[OguryAdsInterstitial alloc] initWithAdUnitID:info[kOguryConfigurationAdUnitId]];
    self.interstitial.interstitialDelegate = self;

    [self.interstitial load];
}

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return self.interstitial.isLoaded;
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    if (self.interstitial.isLoaded) {
        [self.delegate fullscreenAdAdapterAdWillAppear:self];
        [self.interstitial showAdInViewController:viewController];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - OguryAdsInterstitialDelegate

- (void)oguryAdsInterstitialAdAvailable {

}

- (void)oguryAdsInterstitialAdClosed {
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (void)oguryAdsInterstitialAdDisplayed {
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)oguryAdsInterstitialAdError:(OguryAdsErrorType)errorType {
    NSError *error = [NSError errorWithCode:MOPUBErrorNoInventory];
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsInterstitialAdLoaded {
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)oguryAdsInterstitialAdNotAvailable {
    NSError *error = [NSError errorWithCode:MOPUBErrorNoInventory];
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsInterstitialAdNotLoaded {
    NSError *error = [NSError errorWithCode:MOPUBErrorNoInventory];
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsInterstitialAdClicked {
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

@end
