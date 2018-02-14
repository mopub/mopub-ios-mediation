//
//  ChartboostRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "ChartboostRewardedVideoCustomEvent.h"
#import "MPChartboostRouter.h"
#import "MPInstanceProvider+Chartboost.h"
#import "MPLogging.h"
#import "MPRewardedVideoReward.h"
#import <Chartboost/Chartboost.h>
#import "MPRewardedVideoError.h"
#import "MPRewardedVideoCustomEvent+Caching.h"

@interface ChartboostRewardedVideoCustomEvent () <ChartboostDelegate>
@end

@implementation ChartboostRewardedVideoCustomEvent

- (void)initializeSdkWithParameters:(NSDictionary *)parameters
{
    NSString *appId = [parameters objectForKey:@"appId"];
    NSString *appSignature = [parameters objectForKey:@"appSignature"];

    if (appId == nil) {
        MPLogInfo(@"No appId found in initialization parameters.");
        return;
    }

    if (appSignature == nil) {
        MPLogInfo(@"No appSignature found in initialization parameters.");
        return;
    }

    [[MPChartboostRouter sharedRouter] startWithAppId:appId appSignature:appSignature];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    NSString *appId = [info objectForKey:@"appId"];

    NSString *appSignature = [info objectForKey:@"appSignature"];

    NSString *location = [info objectForKey:@"location"];
    self.location = location ? location : CBLocationDefault;

    // Cache the network SDK initialization parameters
    [self setCachedInitializationParameters:info];

    MPLogInfo(@"Requesting Chartboost rewarded video.");
    [[MPChartboostRouter sharedRouter] cacheRewardedAdWithAppId:appId appSignature:appSignature location:self.location forChartboostRewardedVideoCustomEvent:self];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([[MPChartboostRouter sharedRouter] hasCachedRewardedVideoForLocation:self.location]) {
        MPLogInfo(@"Chartboost rewarded video will be shown.");

        [[MPChartboostRouter sharedRouter] showRewardedVideoForLocation:self.location];
    } else {
        MPLogInfo(@"Failed to show Chartboost rewarded video.");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)handleCustomEventInvalidated
{
    [[[MPChartboostRouter sharedRouter] rewardedVideoEvents] removeObjectForKey:self.location];
}

- (BOOL)hasAdAvailable
{
    return [[MPChartboostRouter sharedRouter] hasCachedRewardedVideoForLocation:self.location];
}

- (void)handleAdPlayedForCustomEventNetwork
{
    // If we no longer have an ad available, report back up to the application that this ad expired.
    // We receive this message only when this ad has reported an ad has loaded and another ad unit
    // has played a video for the same ad network.
    if (![self hasAdAvailable]) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }
}

#pragma mark - ChartboostDelegate methods

- (void)didDisplayRewardedVideo:(CBLocation)location
{
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)didCacheRewardedVideo:(CBLocation)location
{
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)didFailToLoadRewardedVideo:(CBLocation)location
                         withError:(CBLoadError)error
{
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
}

- (void)didCloseRewardedVideo:(CBLocation)location
{
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)didClickRewardedVideo:(CBLocation)location
{
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward
{
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:[[MPRewardedVideoReward alloc] initWithCurrencyAmount:@(reward)]];
}


@end
