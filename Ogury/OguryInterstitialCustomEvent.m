#import "OguryInterstitialCustomEvent.h"
#import <OguryAds/OguryAds.h>
#import "OguryAdapterConfiguration.h"

#if __has_include("MoPub.h")
#import "MPError.h"
#import "MPLogging.h"
#endif

@interface OguryInterstitialCustomEvent () <OguryAdsInterstitialDelegate>

#pragma mark - Properties

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, strong) OguryAdsInterstitial *interstitial;

@end

@implementation OguryInterstitialCustomEvent

@dynamic adUnitId;

#pragma mark - Methods

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.adUnitId = info[kOguryConfigurationAdUnitId];
        
    self.interstitial = [[OguryAdsInterstitial alloc] initWithAdUnitID:self.adUnitId];
    self.interstitial.interstitialDelegate = self;
        
    [self.interstitial load];
    
    [OguryAdapterConfiguration updateInitializationParameters:info];

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil], self.adUnitId);
}

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return self.interstitial && self.interstitial.isLoaded;
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass([self class])], self.adUnitId);
    
    if (!self.interstitial || ![self hasAdAvailable]) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"An error occurred while showing the ad. Ad was not ready."];
        
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
        
        return;
    }
    
    [self.interstitial showAdInViewController:viewController];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (void)dealloc {
    self.interstitial = nil;
    self.interstitial.interstitialDelegate = nil;
}

#pragma mark - OguryAdsInterstitialDelegate

- (void)oguryAdsInterstitialAdAvailable {
}

- (void)oguryAdsInterstitialAdClosed {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass([self class])], self.adUnitId);
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass([self class])], self.adUnitId);

    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (void)oguryAdsInterstitialAdDisplayed {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass([self class])], self.adUnitId);

    [self.delegate fullscreenAdAdapterAdWillPresent:self];
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
}

- (void)oguryAdsInterstitialAdError:(OguryAdsErrorType)errorType {
    NSError *error = [OguryAdapterConfiguration MoPubErrorFromOguryError:errorType];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsInterstitialAdLoaded {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass([self class])], self.adUnitId);
    
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)oguryAdsInterstitialAdNotAvailable {
    NSError *error = [NSError errorWithCode:MOPUBErrorNoInventory];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsInterstitialAdNotLoaded {
    NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsInterstitialAdClicked {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.adUnitId);

    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
}

- (void)oguryAdsInterstitialAdOnAdImpression {
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

@end
