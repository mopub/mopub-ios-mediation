#import "OguryRewardedVideoCustomEvent.h"
#import <OguryAds/OguryAds.h>
#import "OguryAdapterConfiguration.h"

#if __has_include("MoPub.h")
    #import "MPError.h"
    #import "MPLogging.h"
#endif

@interface OguryRewardedVideoCustomEvent () <OguryAdsOptinVideoDelegate>

#pragma mark - Properties

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, strong) OguryAdsOptinVideo *optInVideo;

@end

@implementation OguryRewardedVideoCustomEvent

@dynamic adUnitId;

#pragma mark - Methods

- (void)dealloc {
    self.optInVideo = nil;
    self.optInVideo.optInVideoDelegate = nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.adUnitId = info[kOguryConfigurationAdUnitId];
    
    if (!self.adUnitId || [self.adUnitId isEqualToString:@""]) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"An error occurred while loading the ad. Invalid ad unit identifier."];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], @"");
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    [OguryAdapterConfiguration updateInitializationParameters:info];

    self.optInVideo = [[OguryAdsOptinVideo alloc] initWithAdUnitID:self.adUnitId];
    self.optInVideo.optInVideoDelegate = self;
    
    [self.optInVideo load];
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil], self.adUnitId);
}

- (BOOL)isRewardExpected {
    return YES;
}

- (BOOL)hasAdAvailable {
    return self.optInVideo && self.optInVideo.isLoaded;
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass([self class])], self.adUnitId);
    
    if (!self.optInVideo || ![self hasAdAvailable]) {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:@"An error occurred while showing the ad. Ad was not ready."];
        
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
        return;
    }
    
    [self.optInVideo showAdInViewController:viewController];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - OguryAdsOptinVideoDelegate

- (void)oguryAdsOptinVideoAdAvailable {
}

- (void)oguryAdsOptinVideoAdClosed {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass([self class])], self.adUnitId);
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass([self class])], self.adUnitId);
    
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (void)oguryAdsOptinVideoAdDisplayed {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass([self class])], self.adUnitId);

    [self.delegate fullscreenAdAdapterAdWillPresent:self];
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
}

- (void)oguryAdsOptinVideoAdError:(OguryAdsErrorType)errorType {
    NSError *error = [OguryAdapterConfiguration MoPubErrorFromOguryError:errorType];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsOptinVideoAdLoaded {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass([self class])], self.adUnitId);
    
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)oguryAdsOptinVideoAdNotAvailable {
    NSError *error = [NSError errorWithCode:MOPUBErrorNoInventory];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsOptinVideoAdNotLoaded {
    NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsOptinVideoAdRewarded:(OGARewardItem *)item {
    NSString *currencyType = kMPRewardCurrencyTypeUnspecified;
    NSInteger amount = kMPRewardCurrencyAmountUnspecified;
    
    if (item) {
        if (item.rewardName && ![item.rewardName isEqualToString:@""]) {
            currencyType = item.rewardName;
        }
        
        if (item.rewardValue && ![item.rewardValue isEqualToString:@""]) {
            amount = item.rewardValue.integerValue;
        }
    }
    
    MPReward *reward = [[MPReward alloc] initWithCurrencyType:currencyType amount:@(amount)];
    
    [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
}

- (void)oguryAdsOptinVideoAdClicked {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.adUnitId);

    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)oguryAdsOptinVideoAdOnAdImpression {
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

@end
