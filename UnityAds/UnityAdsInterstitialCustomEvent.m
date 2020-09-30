//
//  UnityAdsInterstitialCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "UnityAdsInterstitialCustomEvent.h"
#import "UnityAdsInstanceMediationSettings.h"
#import "UnityRouter.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif
#import "UnityAdsAdapterConfiguration.h"

static NSString *const kMPUnityInterstitialVideoGameId = @"gameId";
static NSString *const kUnityAdsOptionPlacementIdKey = @"placementId";
static NSString *const kUnityAdsOptionZoneIdKey = @"zoneId";

@interface UnityAdsInterstitialCustomEvent () <UnityRouterDelegate>

@property BOOL loadRequested;
@property (nonatomic, copy) NSString *placementId;

@end

@implementation UnityAdsInterstitialCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

- (void)dealloc
{
    [[UnityRouter sharedRouter] clearDelegate:self];
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected
{
    return NO;
}

- (BOOL)hasAdAvailable
{
    return [[UnityRouter sharedRouter] isAdAvailableForPlacementId:self.placementId];
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.loadRequested = YES;
    NSString *gameId = [info objectForKey:kMPUnityInterstitialVideoGameId];
    self.placementId = [info objectForKey:kUnityAdsOptionPlacementIdKey];
    if (self.placementId == nil) {
        self.placementId = [info objectForKey:kUnityAdsOptionZoneIdKey];
    }
    if (gameId == nil || self.placementId == nil) {
          NSError *error = [self createErrorWith:@"Unity Ads adapter failed to requestInterstitial"
                                       andReason:@"Configured with an invalid placement id"
                                   andSuggestion:@""];
          MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];

        return;
    }
    
    // Only need to cache game ID for SDK initialization
    [UnityAdsAdapterConfiguration updateInitializationParameters:info];

    [[UnityRouter sharedRouter] requestVideoAdWithGameId:gameId placementId:self.placementId delegate:self];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reaason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reaason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        [[UnityRouter sharedRouter] presentVideoAdFromViewController:viewController customerId:nil placementId:self.placementId settings:nil delegate:self];
    } else {
        NSError *error = [self createErrorWith:@"Unity Ads failed to load failed to show Unity Interstitial"
                                 andReason:@"There is no available video ad."
                             andSuggestion:@""];
        
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    }
}

- (void)handleDidInvalidateAd
{
    [[UnityRouter sharedRouter] clearDelegate:self];
}

- (void)handleDidPlayAd
{
    // If we no longer have an ad available, report back up to the application that this ad expired.
    // We receive this message only when this ad has reported an ad has loaded and another ad unit
    // has played a video for the same ad network.
    if (![self hasAdAvailable]) {
        [self.delegate fullscreenAdAdapterDidExpire:self];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

#pragma mark - UnityRouterDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    if (self.loadRequested) {
        [self.delegate fullscreenAdAdapterDidLoadAd:self];
        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        self.loadRequested = NO;
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message
{
    NSError *errorLoad = [self createErrorWith:@"Unity Ads failed to load an ad"
                                 andReason:@""
                             andSuggestion:@""];
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:errorLoad];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:errorLoad], [self getAdNetworkId]);
}

- (void) unityAdsDidStart:(NSString *)placementId
{
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void) unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state
{
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void) unityAdsDidClick:(NSString *)placementId
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)unityAdsDidFailWithError:(NSError *)error
{
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
}

- (NSString *) getAdNetworkId {
    return (self.placementId != nil) ? self.placementId : @"";
}

@end
