//
//  ChartboostRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "ChartboostRewardedVideoCustomEvent.h"
#import "ChartboostRouter.h"
#import "NSError+ChartboostErrors.h"

@interface ChartboostRewardedVideoCustomEvent () <CHBRewardedDelegate>
@property (nonatomic) CHBRewarded *ad;
@end

@implementation ChartboostRewardedVideoCustomEvent

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    NSString *location = [info objectForKey:@"location"];
    location = location.length > 0 ? location : CBLocationDefault;

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], location);
    if (self.ad) {
        MPLogAdEvent([MPLogEvent error:[NSError adRequestCalledTwiceOnSameEvent] message:nil], location);
    }
    
    __weak typeof(self) weakSelf = self;
    [ChartboostRouter startWithParameters:info completion:^(BOOL initialized) {
        if (!initialized) {
            NSError *error = [NSError adRequestFailedDueToSDKStartWithAdOfType:@"rewarded"];
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], location);
            [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
            return;
        }
        
        weakSelf.ad.delegate = nil;
        weakSelf.ad = [[CHBRewarded alloc] initWithLocation:location mediation:[ChartboostRouter mediation] delegate:weakSelf];
        [weakSelf.ad cache];
    }];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.ad.location);
    [self.ad showFromViewController:viewController];
}

- (BOOL)hasAdAvailable
{
    return self.ad.isCached;
}

#pragma mark - CHBRewardedDelegate

- (void)didCacheAd:(CHBCacheEvent *)event error:(CHBCacheError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithCacheEvent:event error:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:nserror], event.ad.location);
        NSError *mopubError = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:mopubError];
    } else {
        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], event.ad.location);
        [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    }
}

- (void)willShowAd:(CHBShowEvent *)event error:(CHBShowError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithShowEvent:event error:error];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:nserror], event.ad.location);
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:nserror];
    } else {
        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], event.ad.location);
        [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    }
}

- (void)didShowAd:(CHBShowEvent *)event error:(CHBShowError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithShowEvent:event error:error];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:nserror], self.ad.location);
        NSError *mopubError = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:mopubError];
    } else {
        MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], event.ad.location);
        MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], event.ad.location);
        [self.delegate rewardedVideoDidAppearForCustomEvent:self];
    }
}

- (void)didClickAd:(CHBClickEvent *)event error:(CHBClickError *)error
{
    if (error) {
        NSError *nserror = [NSError errorWithClickEvent:event error:error];
        MPLogAdEvent([MPLogEvent error:nserror message:nil], event.ad.location);
    }
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], event.ad.location);
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

- (void)didDismissAd:(CHBDismissEvent *)event
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], event.ad.location);
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], event.ad.location);
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)didEarnReward:(CHBRewardEvent *)event
{
    MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyAmount:@(event.reward)];
    MPLogAdEvent([MPLogEvent adShouldRewardUserWithReward:reward], event.ad.location);
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
}

@end
