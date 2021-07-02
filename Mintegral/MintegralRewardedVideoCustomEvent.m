#import "MintegralRewardedVideoCustomEvent.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKReward/MTGRewardAdManager.h>
#import <MTGSDKReward/MTGBidRewardAdManager.h>
#import "MintegralAdapterConfiguration.h"

#if __has_include("MoPub.h")
#import "MoPub.h"
#import "MPReward.h"
#import "MPError.h"
#import "MPLogging.h"
#endif

@interface MintegralRewardedVideoCustomEvent () <MTGRewardAdLoadDelegate,MTGRewardAdShowDelegate>

@property (nonatomic, copy) NSString *adm;
@property (nonatomic, copy) NSString *adPlacementId;
@property (nonatomic, copy) NSString *mintegralAdUnitId;

@end

@implementation MintegralRewardedVideoCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected
{
    return YES;
}

- (BOOL)hasAdAvailable
{
    if (self.adm) {
        return [[MTGBidRewardAdManager sharedInstance] isVideoReadyToPlayWithPlacementId:self.adPlacementId unitId:self.mintegralAdUnitId];
    } else {
        return [[MTGRewardAdManager sharedInstance] isVideoReadyToPlayWithPlacementId:self.adPlacementId unitId:self.mintegralAdUnitId];
    }
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    NSString *appId = [info objectForKey:@"appId"];
    NSString *appKey = [info objectForKey:@"appKey"];
    NSString *unitId = [info objectForKey:@"unitId"];
    NSString *placementId = [info objectForKey:@"placementId"];
    
    NSString *errorMsg = nil;
    
    if (!appId) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral appId. Failing ad request. Ensure the app ID is valid on the MoPub dashboard."];
    if (!appKey) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral appKey. Failing ad request. Ensure the app key is valid on the MoPub dashboard."];
    if (!unitId) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral unitId. Failing ad request. Ensure the unit ID is valid on the MoPub dashboard."];
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:kMintegralErrorDomain code:MPRewardedVideoAdErrorInvalidAdUnitID userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    self.mintegralAdUnitId = unitId;
    self.adPlacementId = placementId;
    self.adm = adMarkup;
    
    [MintegralAdapterConfiguration initializeMintegral:info setAppID:appId appKey:appKey];
    [MintegralAdapterConfiguration updateInitializationParameters:info];

    if (self.adm) {
        MPLogInfo(@"Loading Mintegral rewarded ad markup for Advanced Bidding");
        [MTGBidRewardAdManager sharedInstance].playVideoMute = [MintegralAdapterConfiguration isMute];
        [[MTGBidRewardAdManager sharedInstance] loadVideoWithBidToken:self.adm placementId:placementId unitId:unitId delegate:self];
    } else {
        MPLogInfo(@"Loading Mintegral rewarded ad");
        
        [MTGRewardAdManager sharedInstance].playVideoMute = [MintegralAdapterConfiguration isMute];
        [[MTGRewardAdManager sharedInstance] loadVideoWithPlacementId:placementId unitId:unitId delegate:self];
    }
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.mintegralAdUnitId);
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        NSString *customerId = [self.delegate customerIdForAdapter:self];
        
        if ([[MTGRewardAdManager sharedInstance] respondsToSelector:@selector(showVideoWithPlacementId:unitId:withRewardId:userId:delegate:viewController:)]) {
            MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);
            MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);
            
            if (self.adm) {
                [MTGBidRewardAdManager sharedInstance].playVideoMute = [MintegralAdapterConfiguration isMute];
                [[MTGBidRewardAdManager sharedInstance] showVideoWithPlacementId:self.adPlacementId unitId:self.mintegralAdUnitId withRewardId:@"1" userId:customerId delegate:self viewController:viewController];
            } else {
                [MTGRewardAdManager sharedInstance].playVideoMute = [MintegralAdapterConfiguration isMute];
                [[MTGRewardAdManager sharedInstance] showVideoWithPlacementId:self.adPlacementId unitId:self.mintegralAdUnitId withRewardId:@"1" userId:customerId delegate:self viewController:viewController];
            }
        }
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.mintegralAdUnitId);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)handleDidPlayAd
{
    if (![self hasAdAvailable]) {
        [self.delegate fullscreenAdAdapterDidExpire:self];
    }
}

#pragma mark GADRewardBasedVideoAdDelegate
- (void)onVideoAdLoadSuccess:(NSString *)placementId unitId:(NSString *)unitId {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)onVideoAdLoadFailed:(NSString *)placementId unitId:(NSString *)unitId error:(NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)onVideoAdShowSuccess:(NSString *)placementId unitId:(NSString *)unitId {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);
    
    [self.delegate fullscreenAdAdapterAdWillPresent:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
}

- (void)onVideoAdShowFailed:(NSString *)placementId unitId:(NSString *)unitId withError:(NSError *)error {
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.mintegralAdUnitId);
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
}

- (void)onVideoAdClicked:(NSString *)placementId unitId:(NSString *)unitId {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);
    
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)onVideoAdDismissed:(NSString *)placementId unitId:(NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(MTGRewardAdInfo *)rewardInfo {    
    if (rewardInfo) {
        MPReward *reward = [[MPReward alloc] initWithCurrencyType:rewardInfo.rewardName
                                                           amount:[NSNumber numberWithInteger:rewardInfo.rewardAmount]];
        [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
        
    } else {
        MPLogInfo(@"The rewarded video was not watched until completion. The user will not get rewarded.");
    }
    
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);
    
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
}

- (void)onVideoAdDidClosed:(NSString *)placementId unitId:(NSString *)unitId {
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);
    
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

@end
