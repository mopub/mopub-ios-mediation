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
    #import "MPReward.h"
    #import "MPRewardedVideoError.h"
    #import "MPLogging.h"
#endif

static NSString *const kMPUnityRewardedVideoGameId = @"gameId";
static NSString *const kUnityAdsOptionPlacementIdKey = @"placementId";
static NSString *const kUnityAdsOptionZoneIdKey = @"zoneId";

@interface UnityAdsRewardedVideoCustomEvent () <UnityRouterDelegate>

@property (nonatomic, copy) NSString *placementId;

@end

@implementation UnityAdsRewardedVideoCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

- (void)dealloc
{
    [[UnityRouter sharedRouter] clearDelegate:self];
}

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    NSString *gameId = [parameters objectForKey:kMPUnityRewardedVideoGameId];
    if (gameId == nil) {
        MPLogInfo(@"Initialization parameters did not contain gameId.");
        return;
    }

    [[UnityRouter sharedRouter] initializeWithGameId:gameId];
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected
{
    return YES;
}

- (BOOL)hasAdAvailable
{
    return [[UnityRouter sharedRouter] isAdAvailableForPlacementId:self.placementId];
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    NSString *gameId = [info objectForKey:kMPUnityRewardedVideoGameId];
    if (gameId == nil) {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorInvalidCustomEvent userInfo:@{NSLocalizedDescriptionKey: @"Custom event class data did not contain gameId.", NSLocalizedRecoverySuggestionErrorKey: @"Update your MoPub custom event class data to contain a valid Unity Ads gameId."}];

        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        return;
    }

    // Only need to cache game ID for SDK initialization
    [UnityAdsAdapterConfiguration updateInitializationParameters:info];

    self.placementId = [info objectForKey:kUnityAdsOptionPlacementIdKey];
    if (self.placementId == nil) {
        self.placementId = [info objectForKey:kUnityAdsOptionZoneIdKey];
    }

    if (self.placementId == nil) {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorInvalidCustomEvent userInfo:@{NSLocalizedDescriptionKey: @"Custom event class data did not contain placementId.", NSLocalizedRecoverySuggestionErrorKey: @"Update your MoPub custom event class data to contain a valid Unity Ads placementId."}];
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        return;
    }

    [[UnityRouter sharedRouter] requestVideoAdWithGameId:gameId placementId:self.placementId delegate:self];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        UnityAdsInstanceMediationSettings *settings = [self.delegate fullscreenAdAdapter:self instanceMediationSettingsForClass:[UnityAdsInstanceMediationSettings class]];
        
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        [[UnityRouter sharedRouter] presentVideoAdFromViewController:viewController
                                                          customerId:[self.delegate customerIdForAdapter:self]
                                                         placementId:self.placementId
                                                            settings:settings
                                                            delegate:self];

    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
         MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
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
        MPLogAdEvent([MPLogEvent adExpiredWithTimeInterval:0], [self getAdNetworkId]);
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

#pragma mark - UnityRouterDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message
{
    NSString* unityErrorMessage;
    switch (error) {
        case kUnityAdsErrorNotInitialized:
            unityErrorMessage = @"Unity Ads not initialized";
            break;

        case kUnityAdsErrorInitializedFailed:
            unityErrorMessage = @"Unity Ads initialize failed";
            break;

        case kUnityAdsErrorInvalidArgument:
            unityErrorMessage = @"Unity Ads initialize given an invalid argument";
            break;

        case kUnityAdsErrorVideoPlayerError:
            unityErrorMessage = @"Unity Ads video player failed";
            break;

        case kUnityAdsErrorInitSanityCheckFail:
            unityErrorMessage = @"Unity Ads initialized in an invalid environment";
            break;

        case kUnityAdsErrorAdBlockerDetected:
            unityErrorMessage = @"Unity Ads failed due to presence of ad blocker";
            break;

        case kUnityAdsErrorFileIoError:
            unityErrorMessage = @"Unity Ads file IO error";
            break;

        case kUnityAdsErrorDeviceIdError:
            unityErrorMessage = @"Unity Ads encountered a bad device identifier";
            break;

        case kUnityAdsErrorShowError:
            unityErrorMessage = @"Unity Ads failed while attempting to show an ad";
            break;

        case kUnityAdsErrorInternalError:
            unityErrorMessage = @"Unity Ads experienced an internal failure";
            break;

        default:
            unityErrorMessage = @"Unity Ads unknown error";
            break;
    }
    NSError *adapterError = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:@{NSLocalizedDescriptionKey: unityErrorMessage}];
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:adapterError];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:adapterError], [self getAdNetworkId]);
}

- (void) unityAdsDidStart:(NSString *)placementId
{
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void) unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state
{
    if (state == kUnityAdsFinishStateCompleted) {
        MPReward *reward = [[MPReward alloc] initWithCurrencyType:kMPRewardCurrencyTypeUnspecified
                                                           amount:@(kMPRewardCurrencyAmountUnspecified)];
        [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
    }
    
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
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
