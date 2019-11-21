//
//  MintegralRewardVideoCustomEvent.m

#import "MintegralRewardedVideoCustomEvent.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKReward/MTGRewardAdManager.h>
#import <MTGSDKReward/MTGBidRewardAdManager.h>
#import "MintegralAdapterConfiguration.h"
#if __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif
#if __has_include(<MoPubSDKFramework/MPLogging.h>)
#import <MoPubSDKFramework/MPLogging.h>
#else
#import "MPLogging.h"
#endif
#if __has_include(<MoPubSDKFramework/MPRewardedVideoReward.h>)
#import <MoPubSDKFramework/MPRewardedVideoReward.h>
#else
#import "MPRewardedVideoReward.h"
#endif

@interface MintegralRewardedVideoCustomEvent () <MTGRewardAdLoadDelegate,MTGRewardAdShowDelegate>

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, copy) NSString *rewardId;
@property (nonatomic, copy) NSString *adm;

@end

@implementation MintegralRewardedVideoCustomEvent


- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPLogInfo(@"requestRewardedVideoWithCustomEventInfo for Mintegral");
    NSString *appId = [info objectForKey:@"appId"];
    NSString *appKey = [info objectForKey:@"appKey"];
    NSString *unitId = [info objectForKey:@"unitId"];
    NSString *rewardId = [info objectForKey:@"rewardId"];
    
    NSString *errorMsg = nil;
    if (!unitId) errorMsg = @"Invalid Mintegral unitId";
    if (!rewardId) errorMsg = @"Invalid Mintegral rewardId";
        
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:kMintegralErrorDomain code:MPRewardedVideoAdErrorInvalidAdUnitID userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        return;
    }

    if (![MintegralAdapterConfiguration isSDKInitialized]) {
        [MintegralAdapterConfiguration setGDPRInfo:info];
        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        [MintegralAdapterConfiguration sdkInitialized];
    }
    
    self.adUnitId = unitId;
    self.rewardId = rewardId;
        
    self.adm = adMarkup;
    if (self.adm) {
        MPLogInfo(@"Loading Mintegral Reward ad markup for Advanced Bidding");
        [[MTGBidRewardAdManager sharedInstance] loadVideoWithBidToken:self.adm unitId:self.adUnitId delegate:self];
    }else{
        MPLogInfo(@"Loading Mintegral Reward ad");
        [[MTGRewardAdManager sharedInstance] loadVideo:self.adUnitId delegate:self];
    }

}

- (BOOL)hasAdAvailable
{
    if (self.adm) {
        return [[MTGBidRewardAdManager sharedInstance] isVideoReadyToPlay:self.adUnitId];
    }else{
        return [[MTGRewardAdManager sharedInstance] isVideoReadyToPlay:self.adUnitId];
    }
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {

        NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];

        if ([[MTGRewardAdManager sharedInstance] respondsToSelector:@selector(showVideo:withRewardId:userId:delegate:viewController:)]) {
            
            if (self.adm) {
                [[MTGBidRewardAdManager sharedInstance] showVideo:self.adUnitId withRewardId:self.rewardId userId:customerId delegate:self viewController:viewController];
            }else{
                [[MTGRewardAdManager sharedInstance] showVideo:self.adUnitId withRewardId:self.rewardId userId:customerId delegate:self viewController:viewController];
            }
        }

    } else {
        
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)handleAdPlayedForCustomEventNetwork
{
    if (![self hasAdAvailable]) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }
}

- (void)handleCustomEventInvalidated
{
    
}

#pragma mark GADRewardBasedVideoAdDelegate
- (void)onVideoAdLoadSuccess:(nullable NSString *)unitId{

    if ([self hasAdAvailable]) {
        [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    }else{
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
    }
}

- (void)onVideoAdLoadFailed:(nullable NSString *)unitId error:(nonnull NSError *)error{
    
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)onVideoAdShowSuccess:(nullable NSString *)unitId{
    
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
    
    if ([self.delegate respondsToSelector:@selector(trackImpression)]) {
        [self.delegate trackImpression];
    } else {
        MPLogWarn(@"Delegate does not implement impression tracking callback. Impressions likely not being tracked.");
    }
    
}

- (void)onVideoAdShowFailed:(nullable NSString *)unitId withError:(nonnull NSError *)error{
    
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
}

- (void)onVideoAdClicked:(nullable NSString *)unitId{
    
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];

    if ([self.delegate respondsToSelector:@selector(trackClick)]) {
        [self.delegate trackClick];
    } else {
        MPLogWarn(@"Delegate does not implement click tracking callback. Clicks likely not being tracked.");
    }
}

- (void)onVideoAdDismissed:(nullable NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(nullable MTGRewardAdInfo *)rewardInfo{

    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];

    if (!converted || !rewardInfo) {
        return;
    }

    MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:rewardInfo.rewardName amount:[NSNumber numberWithInteger:rewardInfo.rewardAmount]];
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];

}

@end


