#import "PangleRewardedVideoCustomEvent.h"
    #import <BUAdSDK/BUAdSDK.h>
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPReward.h"
#endif
#import "PangleAdapterConfiguration.h"

@interface PangleRewardedVideoCustomEvent () <BURewardedVideoAdDelegate>
@property (nonatomic, strong) BURewardedVideoAd *rewardVideoAd;
@property (nonatomic, copy) NSString *adPlacementId;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, assign) BOOL adHasValid;
@end

@implementation PangleRewardedVideoCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return YES;
}

- (BOOL)hasAdAvailable {
    return self.adHasValid;
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    BOOL hasAdMarkup = adMarkup.length > 0;
    self.adHasValid = NO;
    
    if (info.count == 0) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey:
                                                        @"Incorrect or missing Pangle App ID or Placement ID on the network UI. Ensure the App ID and Placement ID is correct on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError: error];
        return;
    }
    
    self.appId = [info objectForKey:kPangleAppIdKey];
    NSString *appIdString = self.appId;
    if (appIdString && [appIdString isKindOfClass:[NSString class]] && appIdString.length > 0) {
        [PangleAdapterConfiguration pangleSDKInitWithAppId:appIdString];
        [PangleAdapterConfiguration updateInitializationParameters:info];
    }
    
    self.adPlacementId = [info objectForKey:kPanglePlacementIdKey];
    if (!(self.adPlacementId &&
          [self.adPlacementId isKindOfClass:[NSString class]] && self.adPlacementId.length > 0)) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey: @"Incorrect or missing Pangle placement ID. Failing ad request. Ensure the ad placement ID is correct on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = self.adPlacementId;
    
    NSString *userId = [PangleAdapterConfiguration userId];
    if (userId && [userId isKindOfClass:[NSString class]] && userId.length > 0) {
        model.userId = userId;
    }
    
    NSString *rewardName = [PangleAdapterConfiguration rewardName];
    if (rewardName && [rewardName isKindOfClass:[NSString class]] && rewardName.length > 0) {
        model.rewardName = rewardName;
    }
    
    if ([PangleAdapterConfiguration rewardAmount] != 0) {
        model.rewardAmount = [PangleAdapterConfiguration rewardAmount];
    }
    
    NSString *extra = [PangleAdapterConfiguration mediaExtra];
    if (extra && [extra isKindOfClass:[NSString class]] && extra.length > 0) {
        model.extra = extra;
    }
    
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
                          errorWithDomain:MoPubRewardedAdsSDKDomain
                          code:BUErrorCodeNERenderResultError
                          userInfo:@{NSLocalizedDescriptionKey : @"Failed to show Pangle rewarded video."}];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    }
}

#pragma mark BURewardedVideoAdDelegate

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    self.adHasValid = YES;
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
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
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
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
        MPLogInfo(@"Rewarded video finished playing");
    }
}

- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    if (verify) {
        NSString *rewardName = rewardedVideoAd.rewardedVideoModel.rewardName;
        NSString *currencyType = (rewardName && [rewardName isKindOfClass:[NSString class]] && rewardName.length > 0) ? rewardName :kMPRewardCurrencyTypeUnspecified;
        MPReward *reward = [[MPReward alloc] initWithCurrencyType:currencyType amount: @(rewardedVideoAd.rewardedVideoModel.rewardAmount)];
        
        MPLogEvent([MPLogEvent adShouldRewardUserWithReward:reward]);
        
        [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
    } else {
        MPLogInfo(@"Rewarded video ad failed to verify.");
    }
}

- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd error:(nonnull NSError *)error {
    MPLogInfo(@"Rewarded video ad server failed to reward: %@", error);
}

- (NSString *) getAdNetworkId {
    NSString *adPlacementId = self.adPlacementId;
    return (adPlacementId && [adPlacementId isKindOfClass:[NSString class]]) ? adPlacementId : @"";
}

@end
