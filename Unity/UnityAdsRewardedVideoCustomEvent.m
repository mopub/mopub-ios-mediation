//
//  UnityAdsRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "UnityAdsRewardedVideoCustomEvent.h"
#import "MPUnityRouter.h"
#import "MPRewardedVideoReward.h"
#import "MPRewardedVideoError.h"
#import "MPLogging.h"
#import "MPRewardedVideoCustomEvent+Caching.h"
#import "UnityAdsInstanceMediationSettings.h"

static NSString *const kMPUnityRewardedVideoGameId = @"gameId";
static NSString *const kUnityAdsOptionPlacementIdKey = @"placementId";
static NSString *const kUnityAdsOptionZoneIdKey = @"zoneId";

@interface UnityAdsRewardedVideoCustomEvent () <MPUnityRouterDelegate>

@property (nonatomic, copy) NSString *placementId;

@end

@implementation UnityAdsRewardedVideoCustomEvent

- (void)dealloc
{
    [[MPUnityRouter sharedRouter] clearDelegate:self];
}

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    NSString *gameId = [parameters objectForKey:kMPUnityRewardedVideoGameId];
    if (gameId == nil) {
        NSLog(@"Initialization parameters did not contain gameId.");
        return;
    }

    [[MPUnityRouter sharedRouter] initializeWithGameId:gameId];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    NSString *gameId = [info objectForKey:kMPUnityRewardedVideoGameId];
    if (gameId == nil) {
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:[NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorInvalidCustomEvent userInfo:@{NSLocalizedDescriptionKey: @"Custom event class data did not contain gameId.", NSLocalizedRecoverySuggestionErrorKey: @"Update your MoPub custom event class data to contain a valid Unity Ads gameId."}]];
        return;
    }

    // Only need to cache game ID for SDK initialization
    [self setCachedInitializationParameters:@{ kMPUnityRewardedVideoGameId: gameId }];

    self.placementId = [info objectForKey:kUnityAdsOptionPlacementIdKey];
    if (self.placementId == nil) {
        self.placementId = [info objectForKey:kUnityAdsOptionZoneIdKey];
    }

    if (self.placementId == nil) {
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:[NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorInvalidCustomEvent userInfo:@{NSLocalizedDescriptionKey: @"Custom event class data did not contain placementId.", NSLocalizedRecoverySuggestionErrorKey: @"Update your MoPub custom event class data to contain a valid Unity Ads placementId."}]];
        return;
    }

    [[MPUnityRouter sharedRouter] requestVideoAdWithGameId:gameId placementId:self.placementId delegate:self];
}

- (BOOL)hasAdAvailable
{
    return [[MPUnityRouter sharedRouter] isAdAvailableForPlacementId:self.placementId];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        UnityAdsInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[UnityAdsInstanceMediationSettings class]];

        NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
        [[MPUnityRouter sharedRouter] presentVideoAdFromViewController:viewController customerId:customerId placementId:self.placementId settings:settings delegate:self];
    } else {
        MPLogInfo(@"Failed to show Unity rewarded video: Unity now claims that there is no available video ad.");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
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
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }}

#pragma mark - MPUnityRouterDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
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
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:[NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:@{NSLocalizedDescriptionKey: unityErrorMessage}]];
}

- (void) unityAdsDidStart:(NSString *)placementId
{
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void) unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state
{
    if (state == kUnityAdsFinishStateCompleted) {
        MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:kMPRewardedVideoRewardCurrencyTypeUnspecified amount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)];
        [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
    }
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void) unityAdsDidClick:(NSString *)placementId
{
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

- (void)unityAdsDidFailWithError:(NSError *)error
{
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

@end
