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

@interface UnityAdsInterstitialCustomEvent () <UnityAdsLoadDelegate, UnityAdsShowDelegate>

@property (nonatomic, copy) NSString *placementId;

@end

@implementation UnityAdsInterstitialCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

- (NSString *) getAdNetworkId {
    return (self.placementId != nil) ? self.placementId : @"";
}

- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };

    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return _placementId != nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString *gameId = [info objectForKey:kMPUnityInterstitialVideoGameId];
    NSString *placementId = [info objectForKey:kUnityAdsOptionPlacementIdKey];
    
    if (placementId == nil) {
        placementId = [info objectForKey:kUnityAdsOptionZoneIdKey];
    }
    
    if (gameId == nil || placementId == nil) {
          NSError *error = [self createErrorWith:@"Unity Ads adapter failed to request interstitial ad"
                                       andReason:@"Configured with an invalid placement id"
                                   andSuggestion:@""];
          MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], placementId);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    // Only need to cache game ID for SDK initialization
    [UnityAdsAdapterConfiguration updateInitializationParameters:info];

    if (![UnityAds isInitialized]) {
        [[UnityRouter sharedRouter] initializeWithGameId:gameId withCompletionHandler:nil];
        
        NSError *error = [self createErrorWith:@"Unity Ads adapter failed to request interstitial ad, Unity Ads is not initialized yet. Failing this ad request and calling Unity Ads initialization so it would be available for an upcoming ad request"
                                     andReason:@"Unity Ads is not initialized."
                                 andSuggestion:@""];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], placementId);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    [UnityAds load:placementId loadDelegate:self];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], placementId);
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

- (void)unityAdsAdLoaded:(NSString *)placementId {
    self.placementId = placementId;
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)unityAdsAdFailedToLoad:(nonnull NSString *)placementId withError:(UnityAdsLoadError)error withMessage:(NSString *)message {
    self.placementId = placementId;
    NSError *errorLoad = [self createErrorWith:@"Unity Ads failed to load interstitial ad"
                                     andReason:message
                                 andSuggestion:@""];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:errorLoad], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:errorLoad];
}

#pragma mark - UnityAdsShowDelegate Methods

- (void)unityAdsShowStart:(nonnull NSString *)placementId {
  [self.delegate fullscreenAdAdapterAdWillPresent:self];
  MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], placementId);
  MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], placementId);

  [self.delegate fullscreenAdAdapterAdDidPresent:self];
  [self.delegate fullscreenAdAdapterDidTrackImpression:self];
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
  [self.delegate fullscreenAdAdapterAdWillDismiss:self];
  [self.delegate fullscreenAdAdapterAdWillDisappear:self];
  MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], placementId);

  [self.delegate fullscreenAdAdapterAdDidDisappear:self];
  [self.delegate fullscreenAdAdapterAdDidDismiss:self];  
  MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], placementId);
}

- (void)unityAdsShowFailed:(NSString *)placementId withError:(UnityAdsShowError)error withMessage:(NSString *)message {
    if (error == kUnityShowErrorNotReady) {
        // If we no longer have an ad available, report back up to the application that this ad expired.
        // We receive this message only when this ad has reported an ad has loaded and another ad unit
        // has played a video for the same ad network.
        NSError *showError= [self createErrorWith:@"Unity Ads interstitial ad has expired"
                                        andReason:message
                                    andSuggestion:@""];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:showError], placementId);
        [self.delegate fullscreenAdAdapterDidExpire:self];
        return;
    }

    NSError *showError= [self createErrorWith:@"Unity Ads failed to show interstitial"
                                    andReason:message
                                andSuggestion:@""];
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:showError], placementId);
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:showError];
}

@end
