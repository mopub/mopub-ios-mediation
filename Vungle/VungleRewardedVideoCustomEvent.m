//
//  VungleRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "VungleRewardedVideoCustomEvent.h"
#import "MPLogging.h"
#import <VungleSDK/VungleSDK.h>
#import "MPRewardedVideoReward.h"
#import "MPVungleRouter.h"
#import "MPRewardedVideoError.h"
#import "VungleInstanceMediationSettings.h"
#import "MPRewardedVideoCustomEvent+Caching.h"

@interface VungleRewardedVideoCustomEvent ()  <MPVungleRouterDelegate>

@property (nonatomic, copy) NSString *placementId;

@end

@implementation VungleRewardedVideoCustomEvent


- (void)initializeSdkWithParameters:(NSDictionary *)parameters
{
    [[MPVungleRouter sharedRouter] initializeSdkWithInfo:parameters];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    self.placementId = [info objectForKey:kVunglePlacementIdKey];

    // Cache the initialization parameters
    [self setCachedInitializationParameters:info];

    [[MPVungleRouter sharedRouter] requestRewardedVideoAdWithCustomEventInfo:info delegate:self];
}

- (BOOL)hasAdAvailable
{
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.placementId];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([[MPVungleRouter sharedRouter] isAdAvailableForPlacementId:self.placementId]) {
        VungleInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[VungleInstanceMediationSettings class]];

        NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
        NSDictionary *eventInfo = [self cachedInitializationParameters];
        [[MPVungleRouter sharedRouter] presentRewardedVideoAdFromViewController:viewController customerId:customerId settings:settings forPlacementId:self.placementId eventInfo:eventInfo];
    } else {
        MPLogInfo(@"Failed to show Vungle rewarded video: Vungle now claims that there is no available video ad.");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)handleCustomEventInvalidated
{
    [[MPVungleRouter sharedRouter] clearDelegateForPlacementId:self.placementId];
}

- (void)handleAdPlayedForCustomEventNetwork
{
    //empty implementation
}

#pragma mark - MPVungleDelegate

- (void)vungleAdDidLoad
{
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}
- (void)vungleAdWillAppear
{
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}
- (void)vungleAdWillDisappear
{
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)vungleAdWasTapped
{
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

- (void)vungleAdShouldRewardUser
{
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:[[MPRewardedVideoReward alloc] initWithCurrencyAmount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)]];
}


- (void)vungleAdDidFailToLoad:(NSError *)error
{
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)vungleAdDidFailToPlay:(NSError *)error
{
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
}

@end
