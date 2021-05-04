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

    [OguryAdapterConfiguration applyTransparencyAndConsentStatusWithParameters:info];

    self.interstitial = [[OguryAdsInterstitial alloc] initWithAdUnitID:self.adUnitId];
    self.interstitial.interstitialDelegate = self;

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil], self.adUnitId);

    [self.interstitial load];
}

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return self.interstitial && self.interstitial.isLoaded;
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass([self class])], self.adUnitId);

    if (![self hasAdAvailable]) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"An error occurred while showing the ad. Ad was not ready."];
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
        return;
    }

    [self.interstitial showAdInViewController:viewController];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - OguryAdsInterstitialDelegate

- (void)oguryAdsInterstitialAdAvailable {

}

- (void)oguryAdsInterstitialAdClosed {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass([self class])], self.adUnitId);

    [self.delegate fullscreenAdAdapterAdWillDisappear:self];

    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass([self class])], self.adUnitId);

    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (void)oguryAdsInterstitialAdDisplayed {
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];

    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass([self class])], self.adUnitId);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass([self class])], self.adUnitId);
}

- (void)oguryAdsInterstitialAdError:(OguryAdsErrorType)errorType {
    NSError *error = [OguryAdapterConfiguration MoPubErrorFromOguryError:errorType];
    
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);

    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsInterstitialAdLoaded {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass([self class])], self.adUnitId);

    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)oguryAdsInterstitialAdNotAvailable {
    NSError *error = [NSError errorWithCode:MOPUBErrorNoInventory];

    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);

    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsInterstitialAdNotLoaded {
    NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd];

    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);
    
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsInterstitialAdClicked {
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

- (void)oguryAdsInterstitialAdOnAdImpression {
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

@end
