//
//  VungleRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#if __has_include("MoPub.h")
    #import "MPError.h"
    #import "MPLogging.h"
    #import "MoPub.h"
    #import "MPReward.h"
#endif
#import "VungleAdapterConfiguration.h"
#import "VungleInstanceMediationSettings.h"
#import "VungleRewardedVideoCustomEvent.h"
#import "VungleRouter.h"

@interface VungleRewardedVideoCustomEvent ()  <VungleRouterDelegate>

@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, copy) NSString *adMarkup;
@property (nonatomic, copy) NSString *eventId;
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
    return [[VungleRouter sharedRouter] isAdAvailableForDelegate:self];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    self.placementId = [info objectForKey:kVunglePlacementIdKey];
    self.adMarkup = adMarkup;
    self.eventId = [[VungleRouter sharedRouter] parseEventId:adMarkup];

    // Cache the initialization parameters
    [VungleAdapterConfiguration updateInitializationParameters:info];

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.placementId);
    [[VungleRouter sharedRouter] requestRewardedVideoAdWithCustomEventInfo:info delegate:self];
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementId);
    if ([[VungleRouter sharedRouter] isAdAvailableForDelegate:self]) {
        VungleInstanceMediationSettings *settings = [self.delegate fullscreenAdAdapter:self instanceMediationSettingsForClass:VungleInstanceMediationSettings.class];

        [[VungleRouter sharedRouter] presentRewardedVideoAdFromViewController:viewController
                                                                   customerId:[self.delegate customerIdForAdapter:self]
                                                                     settings:settings
                                                                     delegate:self];
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorNoAdsAvailable userInfo:@{ NSLocalizedDescriptionKey: @"Failed to show Vungle rewarded video: Vungle now claims that there is no available video ad."}];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    }
}

- (void)cleanUp
{
    [[VungleRouter sharedRouter] cleanupFullScreenDelegate:self];
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
    [self.delegate fullscreenAdAdapterAdWillPresent:self];
}

- (void)vungleAdDidAppear
{
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
}

- (void)vungleAdViewed
{
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)vungleAdWillDisappear
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

- (void)vungleAdDidDisappear
{
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    
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

- (NSString *)getAdMarkup
{
    return self.adMarkup;
}

- (NSString *)getEventId
{
    return self.eventId;
}

- (void)rewardUser
{
    MPReward *reward = [[MPReward alloc] initWithCurrencyAmount:@(kMPRewardCurrencyAmountUnspecified)];
    MPLogAdEvent([MPLogEvent adShouldRewardUserWithReward:reward], [self getPlacementID]);
    [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
}

@end
