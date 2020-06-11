#import "PangleRewardedVideoCustomEvent.h"
    #import <BUAdSDK/BUAdSDK.h>
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPRewardedVideoError.h"
    #import "MPReward.h"
#endif
#import "PangleAdapterConfiguration.h"

@interface PangleRewardedVideoCustomEvent () <BURewardedVideoAdDelegate>
@property (nonatomic, strong) BURewardedVideoAd *rewardVideoAd;
@property (nonatomic, copy) NSString *adPlacementId;
@property (nonatomic, copy) NSString *appId;
@end

@implementation PangleRewardedVideoCustomEvent

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return YES;
}

- (BOOL)hasAdAvailable {
    return self.rewardVideoAd.isAdValid;
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    BOOL hasAdMarkup = adMarkup.length > 0;
    self.appId = [info objectForKey:kPangleAppIdKey];
    if (BUCheckValidString(self.appId)) {
        [PangleAdapterConfiguration updateInitializationParameters:info];
    }
    
    self.adPlacementId = [info objectForKey:kPanglePlacementIdKey];
    if (!BUCheckValidString(self.adPlacementId)) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey: @"Invalid Pangle placement ID"}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = self.adPlacementId;
    
    BURewardedVideoAd *RewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:self.adPlacementId rewardedVideoModel:model];
    RewardedVideoAd.delegate = self;
    self.rewardVideoAd = RewardedVideoAd;
    
    if (hasAdMarkup) {
        MPLogInfo(@"Loading Pangle rewarded video ad markup for Advanced Bidding");
        [RewardedVideoAd setMopubAdMarkUp:adMarkup];
    } else {
        MPLogInfo(@"Loading Pangle rewarded video ad");
        [RewardedVideoAd loadAdData];
    }
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}
    
- (void)presentAdFromViewController:(UIViewController *)viewController {
    if ([self hasAdAvailable]) {
        [self.rewardVideoAd showAdFromRootViewController:viewController];
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    } else {
        NSError *error = [NSError
                          errorWithDomain:MoPubRewardedVideoAdsSDKDomain
                          code:BUErrorCodeNERenderResultError
                          userInfo:@{NSLocalizedDescriptionKey : @"Render error in showing Pangle Rewarded Video Ad."}];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    }
}

- (void)updateAppId{
    [BUAdSDKManager setAppID:self.appId];
}

#pragma mark BURewardedVideoAdDelegate

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    if (BUCheckValidString(self.appId) && error.code == BUUnionAppSiteRelError) {
        [self updateAppId];
    }
}

- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
    
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
    
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    if (error != nil) {
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    } else {
        MPLogInfo(@"Rewarded video video finish playing");
    }
}

- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    if (verify) {
        MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:kMPRewardedVideoRewardCurrencyTypeUnspecified amount: @(kMPRewardedVideoRewardCurrencyAmountUnspecified)];
        MPLogEvent([MPLogEvent adShouldRewardUserWithReward:reward]);
        [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
    } else {
        MPLogInfo(@"Rewarded video ad fail to verify.");
    }
}

- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd {
    MPLogInfo(@"Rewarded video ad server fail to reward.");
}

- (NSString *) getAdNetworkId {
    return (BUCheckValidString(self.adPlacementId)) ? self.adPlacementId : @"";
}

@end
