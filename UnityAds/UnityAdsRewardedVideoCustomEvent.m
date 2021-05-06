//
//  UnityAdsRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "UnityAdsRewardedVideoCustomEvent.h"
#import "UnityAdsInstanceMediationSettings.h"
#import "UnityAdsAdapterConfiguration.h"
#import "UnityRouter.h"
#if __has_include("MoPub.h")
    #import "MPRewardedAdsError.h"
    #import "MPReward.h"
    #import "MPLogging.h"
#endif

static NSString *const kMPUnityRewardedVideoGameId = @"gameId";
static NSString *const kUnityAdsOptionPlacementIdKey = @"placementId";
static NSString *const kUnityAdsOptionZoneIdKey = @"zoneId";

@interface UnityAdsRewardedVideoCustomEvent () <UnityAdsLoadDelegate, UnityAdsShowDelegate>

@property (nonatomic, copy) NSString *placementId;

@end

@implementation UnityAdsRewardedVideoCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    NSString *gameId = [parameters objectForKey:kMPUnityRewardedVideoGameId];
    if (gameId == nil) {
        MPLogInfo(@"Initialization parameters did not contain gameId.");
        return;
    }

    [[UnityRouter sharedRouter] initializeWithGameId:gameId withCompletionHandler:nil];
}

- (NSString *) getAdNetworkId {
    return (self.placementId != nil) ? self.placementId : @"";
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (BOOL)isRewardExpected
{
    return YES;
}

- (BOOL)hasAdAvailable {
    return _placementId != nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    NSString *gameId = [info objectForKey:kMPUnityRewardedVideoGameId];
   
    if (gameId == nil) {
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorInvalidCustomEvent userInfo:@{NSLocalizedDescriptionKey: @"Custom event class data did not contain gameId.", NSLocalizedRecoverySuggestionErrorKey: @"Update your MoPub custom event class data to contain a valid Unity Ads gameId."}];

        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }

    // Only need to cache game ID for SDK initialization
    [UnityAdsAdapterConfiguration updateInitializationParameters:info];

    NSString *placementId = [info objectForKey:kUnityAdsOptionPlacementIdKey];
    if (placementId == nil) {
        placementId = [info objectForKey:kUnityAdsOptionZoneIdKey];
    }

    if (placementId == nil) {
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorInvalidCustomEvent userInfo:@{NSLocalizedDescriptionKey: @"Custom event class data did not contain placementId.", NSLocalizedRecoverySuggestionErrorKey: @"Update your MoPub custom event class data to contain a valid Unity Ads placementId."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], placementId);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    if (![UnityAds isInitialized]) {
        [[UnityRouter sharedRouter] initializeWithGameId:gameId withCompletionHandler:nil];
        
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorInvalidCustomEvent userInfo:@{NSLocalizedDescriptionKey: @"Unity Ads adapter failed to request rewarded video ad. Unity Ads is not initialized yet. Failing this ad request and calling Unity Ads initialization so it would be available for an upcoming ad request.", NSLocalizedRecoverySuggestionErrorKey: @""}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], placementId);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], placementId);
    [UnityAds load:placementId loadDelegate:self];
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
    if (![self hasAdAvailable]) {
        MPLogWarn(@"Unity Ads received call to show before successfully loading an ad");
    }

    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [UnityAds show:viewController placementId:_placementId showDelegate:self];
}

- (void)handleDidInvalidateAd
{
  // Nothing to clean up.
}

#pragma mark - UnityAdsLoadDelegate Methods

- (void)unityAdsAdLoaded:(nonnull NSString *)placementId {
    self.placementId = placementId;
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], placementId);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)unityAdsAdFailedToLoad:(nonnull NSString *)placementId withError:(UnityAdsLoadError)error withMessage:(NSString *)message {
    self.placementId = placementId;
    NSString* unityErrorMessage = [NSString stringWithFormat:@"Unity Ads failed to load a rewarded video ad for %@, with error message: %@", placementId, message];
    NSError *loadError = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorUnknown userInfo:@{NSLocalizedDescriptionKey: unityErrorMessage}];

    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:loadError], placementId);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:loadError];
}

#pragma mark - UnityAdsShowDelegate Methods

- (void)unityAdsShowStart:(nonnull NSString *)placementId {
  [self.delegate fullscreenAdAdapterAdWillAppear:self];
  MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], placementId);

  [self.delegate fullscreenAdAdapterAdDidAppear:self];
  [self.delegate fullscreenAdAdapterDidTrackImpression:self];
  MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], placementId);
  MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], placementId);
}

- (void)unityAdsShowClick:(NSString *)placementId {
  MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], placementId);
  [self.delegate fullscreenAdAdapterDidReceiveTap:self];
  [self.delegate fullscreenAdAdapterDidTrackClick:self];
  MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], placementId);
  [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)unityAdsShowComplete:(NSString *)placementId withFinishState:(UnityAdsShowCompletionState)state {
  if (state == kUnityShowCompletionStateCompleted) {
      MPReward *reward = [[MPReward alloc] initWithCurrencyType:kMPRewardCurrencyTypeUnspecified
                                                         amount:@(kMPRewardCurrencyAmountUnspecified)];
      [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
  }

  MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], placementId);
  MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], placementId);
  [self.delegate fullscreenAdAdapterAdWillDismiss:self];
  [self.delegate fullscreenAdAdapterAdWillDisappear:self];
  [self.delegate fullscreenAdAdapterAdDidDisappear:self];
  [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (void)unityAdsShowFailed:(NSString *)placementId withError:(UnityAdsShowError)error withMessage:(NSString *)message {
    if (error == kUnityShowErrorNotReady) {
        // If we no longer have an ad available, report back up to the application that this ad expired.
        // We receive this message only when this ad has reported an ad has loaded and another ad unit
        // has played a video for the same ad network.
        NSString* unityErrorMessage = [NSString stringWithFormat:@"Unity Ads rewarded ad has expired with error message: %@", message];
        NSError *showError = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorUnknown userInfo:@{NSLocalizedDescriptionKey: unityErrorMessage}];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:showError], placementId);
        [self.delegate fullscreenAdAdapterDidExpire:self];
        return;
    }

    NSString* unityErrorMessage = unityErrorMessage = [NSString stringWithFormat:@"Unity Ads failed to show a rewarded video ad for %@, with error message: %@", placementId, message];
    NSError *showError = showError = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorUnknown userInfo:@{NSLocalizedDescriptionKey: unityErrorMessage}];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:showError], placementId);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:showError];
}

@end
