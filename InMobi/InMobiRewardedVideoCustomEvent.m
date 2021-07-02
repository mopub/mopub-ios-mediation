//
//  InMobiRewardedVideoCustomEvent.m
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//

#import "InMobiRewardedVideoCustomEvent.h"
#import "InMobiAdapterConfiguration.h"
#import <InMobiSDK/IMSdk.h>

#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPConstants.h"
    #import "MPReward.h"
    #import "MPRewardedVideoError.h"
#endif


@interface InMobiRewardedVideoCustomEvent () <IMInterstitialDelegate>

@property (nonatomic, strong) IMInterstitial * rewardedVideoAd;
@property (nonatomic, copy)   NSString       * placementId;
@property (nonatomic, copy)   NSString       * accountId;

@end

@implementation InMobiRewardedVideoCustomEvent

- (NSString *) getAdNetworkId {
    return _placementId;
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return YES;
}

- (BOOL)hasAdAvailable {
    return (self.rewardedVideoAd && [self.rewardedVideoAd isReady]);
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString * const accountId   = info[kIMAccountIdKey];
    NSString * const placementId = info[kIMPlacementIdKey];

    NSError * accountIdError = [InMobiAdapterConfiguration validateAccountId:accountId forOperation:@"rewarded video ad request"];
    if (accountIdError) {
        [self failLoadWithError:accountIdError];
        return;
    }
    
    [InMobiAdapterConfiguration setCachedInitializationParameters: info];

    NSError * placementIdError = [InMobiAdapterConfiguration validatePlacementId:placementId forOperation:@"rewarded video ad request"];
    if (placementIdError) {
        [self failLoadWithError:placementIdError];
        return;
    }
    
    self.placementId = placementId;
    long long placementIdLong = [placementId longLongValue];

    if (![InMobiAdapterConfiguration isInMobiSDKInitialized]) {
        [self failLoadWithError: [InMobiAdapterConfiguration createInitializationError:@"rewarded video ad request"]];
        [InMobiAdapterConfiguration initializeInMobiSDK:accountId];
        return;
    }

    self.rewardedVideoAd = [[IMInterstitial alloc] initWithPlacementId:placementIdLong delegate:self];
    if (!self.rewardedVideoAd) {
        NSError * rewardedVideoFailedToInitialize = [InMobiAdapterConfiguration createErrorWith:@"Aborting InMobi rewarded video ad request"
                                                                               andReason:@"InMobi SDK was unable to initialize a rewarded video object"
                                                                           andSuggestion:@""];
        [self failLoadWithError:rewardedVideoFailedToInitialize];
        return;
    }
    
    // Mandatory params to be set by the publisher to identify the supply source type
    NSMutableDictionary * mandatoryInMobiExtrasDict = [[NSMutableDictionary alloc] init];
    [mandatoryInMobiExtrasDict setObject:@"c_mopub" forKey:@"tp"];
    [mandatoryInMobiExtrasDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];
    self.rewardedVideoAd.extras = mandatoryInMobiExtrasDict;

    [InMobiAdapterConfiguration setupInMobiSDKDemographicsParams:self.accountId];    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class)
                                       dspCreativeId:nil
                                             dspName:nil], [self getAdNetworkId]);
    
    IMCompletionBlock completionBlock = ^{
        if ([adMarkup isKindOfClass:[NSString class]] && adMarkup.length > 0) {
            [self.rewardedVideoAd load:[adMarkup dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [self.rewardedVideoAd load];
        }        
    };
    [InMobiAdapterConfiguration invokeOnMainThreadAsSynced:YES withCompletionBlock:completionBlock];

}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    
    if ([self hasAdAvailable]) {
        IMCompletionBlock completionBlock = ^{
            [self.rewardedVideoAd showFromViewController:viewController withAnimation:kIMInterstitialAnimationTypeCoverVertical];
        };
        [InMobiAdapterConfiguration invokeOnMainThreadAsSynced:YES withCompletionBlock:completionBlock];
    } else {
        NSError *adNotAvailableError = [InMobiAdapterConfiguration createErrorWith:@"Failed to show InMobi Rewarded Video"
                                                                         andReason:@"Ad is not available"
                                                                     andSuggestion:@"Please make sure you call to show after ad is available by listening to load complete callback."];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:adNotAvailableError],
                     [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:adNotAvailableError];
    }
}

- (void)failLoadWithError:(NSError *)error {
    IMCompletionBlock completionBlock = ^{
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    };
    [InMobiAdapterConfiguration invokeOnMainThreadAsSynced:NO withCompletionBlock:completionBlock];
}

#pragma mark - InMobi Rewarded Video Delegate Methods

-(void)interstitialDidFinishLoading:(IMInterstitial*)interstitial {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    self.rewardedVideoAd = interstitial;
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)interstitial:(IMInterstitial *)interstitial didReceiveWithMetaInfo:(IMAdMetaInfo *)metaInfo {
    MPLogInfo(@"InMobi ad server responded with a rewarded video ad");
}

-(void)interstitial:(IMInterstitial*)interstitial didFailToLoadWithError:(IMRequestStatus*)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class)
                                              error:error], [self getAdNetworkId]);
    self.rewardedVideoAd = nil;
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:(NSError*)error];
}

-(void)interstitialWillPresent:(IMInterstitial*)interstitial {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillPresent:self];
}

-(void)interstitialDidPresent:(IMInterstitial *)interstitial {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];

}

-(void)interstitial:(IMInterstitial*)interstitial didFailToPresentWithError:(IMRequestStatus*)error {
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class)error:error], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:(NSError *)error];
}

-(void)interstitialWillDismiss:(IMInterstitial*)interstitial {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

-(void)interstitialDidDismiss:(IMInterstitial*)interstitial {
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    
    // Signal that the fullscreen ad is closing and the state should be reset.
    // `fullscreenAdAdapterAdDidDismiss:` was introduced in MoPub SDK 5.15.0.
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    }
}

-(void)interstitial:(IMInterstitial*)interstitial didInteractWithParams:(NSDictionary*)params {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

-(void)userWillLeaveApplicationFromInterstitial:(IMInterstitial*)interstitial {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

-(void)interstitial:(IMInterstitial*)interstitial rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    MPReward *reward = [MPReward unspecifiedReward];
    if (rewards != nil && [rewards count] > 0) {
        reward = [[MPReward alloc] initWithCurrencyType:kMPRewardCurrencyTypeUnspecified amount:[rewards allValues][0]];
    }
    MPLogInfo(@"InMobi reward action completed with rewards: %@", [rewards description]);
    [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
}

@end
