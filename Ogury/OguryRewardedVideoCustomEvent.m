//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryRewardedVideoCustomEvent.h"
#import <OguryAds/OguryAds.h>
#import "OguryAdapterConfiguration.h"

@interface OguryRewardedVideoCustomEvent () <OguryAdsOptinVideoDelegate>

#pragma mark - Properties

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, strong) OguryAdsOptinVideo *optinVideo;

@end

@implementation OguryRewardedVideoCustomEvent

@dynamic adUnitId;

#pragma mark - Methods

- (void)dealloc {
    self.optinVideo.optInVideoDelegate = nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.adUnitId = info[kOguryConfigurationAdUnitId];

    self.optinVideo = [[OguryAdsOptinVideo alloc] initWithAdUnitID:self.adUnitId];
    self.optinVideo.optInVideoDelegate = self;

    [self.optinVideo load];
}

- (BOOL)isRewardExpected {
    return YES;
}

- (BOOL)hasAdAvailable {
    return self.optinVideo.isLoaded;
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    if (self.optinVideo.isLoaded) {
        [self.optinVideo showAdInViewController:viewController];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - OguryAdsOptinVideoDelegate

- (void)oguryAdsOptinVideoAdAvailable {

}

- (void)oguryAdsOptinVideoAdClosed {
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (void)oguryAdsOptinVideoAdDisplayed {
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)oguryAdsOptinVideoAdError:(OguryAdsErrorType)errorType {
    NSError *error = [NSError errorWithDomain:kOguryErrorDomain code:MOPUBErrorNoInventory userInfo:@{NSLocalizedDescriptionKey: @"Failed to display RewardedVideo."}];
    
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass([self class]) error:error], self.adUnitId);

    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsOptinVideoAdLoaded {
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)oguryAdsOptinVideoAdNotAvailable {
    NSError *error = [NSError errorWithCode:MOPUBErrorNoInventory];
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsOptinVideoAdNotLoaded {
    NSError *error = [NSError errorWithCode:MOPUBErrorNoInventory];
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)oguryAdsOptinVideoAdRewarded:(OGARewardItem *)item {
    NSString *currencyType = kMPRewardCurrencyTypeUnspecified;
    NSInteger amount = kMPRewardCurrencyAmountUnspecified;

    if (item.rewardName != nil && ![item.rewardName isEqualToString:@""]) {
        currencyType = item.rewardName;
    }
    
    if (item.rewardValue != nil && ![item.rewardValue isEqualToString:@""]) {
        amount = item.rewardValue.integerValue;
    }

    MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:currencyType amount:@(amount)];

    [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
}

- (void)oguryAdsOptinVideoAdClicked {
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

@end
