//
//  VungleRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <VungleSDK/VungleSDK.h>
#if __has_include("MoPub.h")
    #import "MPError.h"
    #import "MPLogging.h"
    #import "MoPub.h"
    #import "MPReward.h"
    #import "MPRewardedVideoError.h"
#endif
#import "VungleAdapterConfiguration.h"
#import "VungleInstanceMediationSettings.h"
#import "VungleRewardedVideoCustomEvent.h"
#import "VungleRouter.h"

@interface VungleRewardedVideoCustomEvent ()  <VungleRouterDelegate>

@property (nonatomic, copy) NSString *placementId;
@property (nonatomic) BOOL isAdLoaded;

@end

@implementation VungleRewardedVideoCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

- (void)initializeSdkWithParameters:(NSDictionary *)parameters
{
    [[VungleRouter sharedRouter] initializeSdkWithInfo:parameters];
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return YES;
}

- (BOOL)hasAdAvailable
{
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.placementId];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    self.placementId = [info objectForKey:kVunglePlacementIdKey];

    // Cache the initialization parameters
    [VungleAdapterConfiguration updateInitializationParameters:info];

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.placementId);
    [[VungleRouter sharedRouter] requestRewardedVideoAdWithCustomEventInfo:info delegate:self];
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementId);
    if ([[VungleRouter sharedRouter] isAdAvailableForPlacementId:self.placementId]) {
        VungleInstanceMediationSettings *settings = [self.delegate fullscreenAdAdapter:self instanceMediationSettingsForClass:VungleInstanceMediationSettings.class];

        [[VungleRouter sharedRouter] presentRewardedVideoAdFromViewController:viewController
                                                                   customerId:[self.delegate customerIdForAdapter:self]
                                                                     settings:settings
                                                               forPlacementId:self.placementId];
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:@{ NSLocalizedDescriptionKey: @"Failed to show Vungle rewarded video: Vungle now claims that there is no available video ad."}];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    }
}

- (void)cleanUp
{
    [[VungleRouter sharedRouter] clearDelegateForPlacementId:self.placementId];
}

#pragma mark - MPVungleDelegate

- (void)vungleAdDidLoad
{
    if (self.isAdLoaded) {
        return;
    }
    
    self.isAdLoaded = YES;
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)vungleAdWillAppear
{
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
}

- (void)vungleAdDidAppear
{
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
}

- (void)vungleAdViewed
{
    MPLogInfo(@"Vungle Rewarded Video Ad did view");
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)vungleAdWillDisappear
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

- (void)vungleAdDidDisappear
{
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    
    // Signal that the fullscreen ad is closing and the state should be reset.
    // `fullscreenAdAdapterAdDidDismiss:` was introduced in MoPub SDK 5.15.0.
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    }
    
    [self cleanUp];
}

- (void)vungleAdTrackClick
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

- (void)vungleAdRewardUser
{
    [self performSelectorOnMainThread:@selector(rewardUser) withObject:nil waitUntilDone:NO];
}

- (void)vungleAdWillLeaveApplication
{
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)vungleAdDidFailToLoad:(NSError *)error
{
    if (self.isAdLoaded) {
        return;
    }
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    [self cleanUp];
}

- (void)vungleAdDidFailToPlay:(NSError *)error
{
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    [self cleanUp];
}

- (NSString *)getPlacementID
{
    return self.placementId;
}

- (void)rewardUser
{
    MPReward *reward = [[MPReward alloc] initWithCurrencyAmount:@(kMPRewardCurrencyAmountUnspecified)];
    MPLogAdEvent([MPLogEvent adShouldRewardUserWithReward:reward], [self getPlacementID]);
    [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
}

@end
