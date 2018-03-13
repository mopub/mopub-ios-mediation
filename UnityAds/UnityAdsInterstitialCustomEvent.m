//
//  UnityAdsInterstitialCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "UnityAdsInterstitialCustomEvent.h"
#import "MPUnityRouter.h"
#import "MPLogging.h"
#import "UnityAdsInstanceMediationSettings.h"

static NSString *const kMPUnityRewardedVideoGameId = @"gameId";
static NSString *const kUnityAdsOptionPlacementIdKey = @"placementId";
static NSString *const kUnityAdsOptionZoneIdKey = @"zoneId";

@interface UnityAdsInterstitialCustomEvent () <MPUnityRouterDelegate>

@property BOOL loadRequested;
@property (nonatomic, copy) NSString *placementId;

@end

@implementation UnityAdsInterstitialCustomEvent

- (void)dealloc
{
    [[MPUnityRouter sharedRouter] clearDelegate:self];
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    self.loadRequested = YES;
    NSString *gameId = [info objectForKey:kMPUnityRewardedVideoGameId];
    self.placementId = [info objectForKey:kUnityAdsOptionPlacementIdKey];
    if (self.placementId == nil) {
        self.placementId = [info objectForKey:kUnityAdsOptionZoneIdKey];
    }
    if (self.placementId == nil) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        MPLogInfo(@" PlacementId is nil, place check the values set in the UI");
    } else {
        [[MPUnityRouter sharedRouter] requestVideoAdWithGameId:gameId placementId:self.placementId delegate:self];
    }
}

- (BOOL)hasAdAvailable
{
    return [[MPUnityRouter sharedRouter] isAdAvailableForPlacementId:self.placementId];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        [[MPUnityRouter sharedRouter] presentVideoAdFromViewController:viewController customerId:nil placementId:self.placementId settings:nil delegate:self];
    } else {
        MPLogInfo(@"Failed to show Unity Interstitial: Unity now claims that there is no available video ad.");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)handleCustomEventInvalidated
{
    [[MPUnityRouter sharedRouter] clearDelegate:self];
}

- (void)handleAdPlayedForCustomEventNetwork
{
    // If we no longer have an ad available, report back up to the application that this ad expired.
    // We receive this message only when this ad has reported an ad has loaded and another ad unit
    // has played a video for the same ad network.
    if (![self hasAdAvailable]) {
        [self.delegate interstitialCustomEventDidExpire:self];
    }}

#pragma mark - MPUnityRouterDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    if (self.loadRequested) {
        [self.delegate interstitialCustomEvent:self didLoadAd:placementId];
        self.loadRequested = NO;
        MPLogInfo(@"Loading an Unity Ad");
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    MPLogInfo(@"Unity ads failed to load with an error message %@", message);
}

- (void) unityAdsDidStart:(NSString *)placementId
{
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
    MPLogInfo(@"Unity Ads to appear on your display");
}

- (void) unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state
{
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
    MPLogInfo(@"Unity Ads to disappear from your display");
}

- (void) unityAdsDidClick:(NSString *)placementId
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)unityAdsDidFailWithError:(NSError *)error
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    MPLogInfo(@"Unity Ads failed with an error %@", error);
}

@end

