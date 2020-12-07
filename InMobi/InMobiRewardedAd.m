//
//  InMobiRewardedAd.h
//  InMobiMopubAdvancedBiddingPlugin
//  InMobi
//
//  Created by Akshit Garg on 24/11/20.
//  Copyright © 2020 InMobi. All rights reserved.
//

#import "InMobiRewardedAd.h"
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPLogging.h"
    #import "MPRewardedVideoReward.h"
    #import "MPRewardedVideoError.h"
    #import "MPConstants.h"
#endif

#import "IMMPABConstants.h"
#import "IMMPABUtilities.h"

@interface InMobiRewardedAd ()

@property (nonatomic, strong) IMInterstitial* interstitialAd;

@end

@implementation InMobiRewardedAd

#pragma mark - MPFullscreenAdAdapter Overriden Methods

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    MPLogEvent([MPLogEvent adLoadAttemptForAdapter:IMMPAdapterName dspCreativeId:nil dspName:nil]);
    
    // Create and load a IMInterstitial instance
    long long placementId = [[info valueForKey:kIMMPPlacementID] longLongValue];

    self.interstitialAd = [[IMInterstitial alloc] initWithPlacementId:placementId delegate:self];
    
    if (self.interstitialAd) {
        NSError* error = [NSError errorWithDomain:kIMMPErrorDomain
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey : kIMMPLoadFailed}];
        MPLogEvent([MPLogEvent adLoadFailedForAdapter:IMMPAdapterName error:error]);
        IMCompletionBlock completionBlock = ^{
            [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        };
        [IMMPABUtilities invokeOnMainThreadAsSynced:NO withCompletionBlock:completionBlock];
        return;
    }
    
    //Mandatory params to be set by the publisher to identify the supply source type
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:@"c_mopub" forKey:@"tp"];
    [paramsDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];
    
    self.interstitialAd.extras = paramsDict;
    
    IMCompletionBlock completionBlock = ^{
        [self.interstitialAd load:[adMarkup dataUsingEncoding:NSUTF8StringEncoding]];
    };
    [IMMPABUtilities invokeOnMainThreadAsSynced:YES withCompletionBlock:completionBlock];
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    IMCompletionBlock completionBlock = ^{
        [self.interstitialAd showFromViewController:viewController withAnimation:kIMInterstitialAnimationTypeCoverVertical];
    };
    [IMMPABUtilities invokeOnMainThreadAsSynced:YES withCompletionBlock:completionBlock];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (BOOL)isRewardExpected {
    return YES;
}

- (BOOL)hasAdAvailable {
    return self.interstitialAd.isReady;
}

#pragma mark - IMInnterstitialDelegate Methods

- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    MPLogEvent([MPLogEvent adLoadSuccessForAdapter:IMMPAdapterName]);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)interstitial:(IMInterstitial *)interstitial didReceiveWithMetaInfo:(IMAdMetaInfo *)metaInfo {
    MPLogInfo(@"%@", kIMMPInterstitialReceived);
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    MPLogEvent([MPLogEvent adLoadFailedForAdapter:IMMPAdapterName error:error]);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialWillPresent:(IMInterstitial *)interstitial {
    MPLogEvent([MPLogEvent adWillAppearForAdapter:IMMPAdapterName]);
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    MPLogEvent([MPLogEvent adDidAppearForAdapter:IMMPAdapterName]);
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error {
    MPLogEvent([MPLogEvent adShowFailedForAdapter:IMMPAdapterName error:error]);
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
}

- (void)interstitialWillDismiss:(IMInterstitial *)interstitial {
    MPLogEvent([MPLogEvent adWillDisappearForAdapter:IMMPAdapterName]);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    MPLogEvent([MPLogEvent adDidDisappearForAdapter:IMMPAdapterName]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    }
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
    MPLogEvent([MPLogEvent adTappedForAdapter:IMMPAdapterName]);
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial *)interstitial {
    MPLogEvent([MPLogEvent adWillLeaveApplicationForAdapter:IMMPAdapterName]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    MPReward* reward = [MPReward unspecifiedReward];
    if (rewards != nil) {
        MPLogInfo(IMMPRewardActionCompleted([rewards description]));
        reward = [[MPReward alloc] initWithCurrencyAmount:[rewards allValues][0]];
    }
    [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
}

@end
