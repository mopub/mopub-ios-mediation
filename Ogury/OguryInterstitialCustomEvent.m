//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryInterstitialCustomEvent.h"
#import <OguryAds/OguryAds.h>
#import "OguryAdapterConfiguration.h"

@interface OguryInterstitialCustomEvent () <OguryAdsInterstitialDelegate>

#pragma mark - Properties

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, strong) OguryAdsInterstitial *interstitial;

@end

@implementation OguryInterstitialCustomEvent

@dynamic adUnitId;

#pragma mark - Methods

- (void)dealloc {
    self.interstitial.interstitialDelegate = nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.adUnitId = info[kOguryConfigurationAdUnitId];

    self.interstitial = [[OguryAdsInterstitial alloc] initWithAdUnitID:self.adUnitId];
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
    NSError *error = [NSError errorWithDomain:kOguryErrorDomain code:MOPUBErrorNoInventory userInfo:@{NSLocalizedDescriptionKey: @"Failed to display Interstitial."}];
    
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);

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
