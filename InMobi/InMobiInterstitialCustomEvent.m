//
//  InMobiInterstitialCustomEvent.m
//  MoPub
//
//  Copyright © 2021 MoPub. All rights reserved.
//

#import "InMobiInterstitialCustomEvent.h"
#import "InMobiAdapterConfiguration.h"
#import <InMobiSDK/IMSdk.h>

#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPConstants.h"
#endif

@interface InMobiInterstitialCustomEvent ()

@property (nonatomic, strong) IMInterstitial * interstitialAd;
@property (nonatomic, copy)   NSString       * placementId;

@end

@implementation InMobiInterstitialCustomEvent

- (NSString *) getAdNetworkId {
    return _placementId;
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return (self.interstitialAd && [self.interstitialAd isReady]);
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString * const accountId   = info[kIMAccountIdKey];
    NSString * const placementId = info[kIMPlacementIdKey];

    NSError * accountIdError = [InMobiAdapterConfiguration validateAccountId:accountId forOperation:@"interstitial ad request"];
    if (accountIdError) {
        [self failLoadWithError:accountIdError];
        return;
    }
    
    [InMobiAdapterConfiguration setCachedInitializationParameters: info];

    NSError * placementIdError = [InMobiAdapterConfiguration validatePlacementId:placementId forOperation:@"interstitial ad request"];
    if (placementIdError) {
        [self failLoadWithError:placementIdError];
        return;
    }
    
    self.placementId = placementId;
    long long placementIdLong = [placementId longLongValue];

    if (![InMobiAdapterConfiguration isInMobiSDKInitialized]) {
        [self failLoadWithError: [InMobiAdapterConfiguration createInitializationError:@"interstitial ad request"]];
        [InMobiAdapterConfiguration initializeInMobiSDK:accountId];
        return;
    }

    self.interstitialAd = [[IMInterstitial alloc] initWithPlacementId:placementIdLong delegate:self];
    if (!self.interstitialAd) {
        NSError * interstitialFailedToInitialize = [InMobiAdapterConfiguration createErrorWith:@"Aborting InMobi interstitial ad request"
                                                                               andReason:@"InMobi SDK was unable to initialize an interstitial object"
                                                                           andSuggestion:@""];
        [self failLoadWithError:interstitialFailedToInitialize];
        return;
    }
    
    // Mandatory params to be set by the publisher to identify the supply source type
    NSMutableDictionary * mandatoryInMobiExtrasDict = [[NSMutableDictionary alloc] init];
    [mandatoryInMobiExtrasDict setObject:@"c_mopub" forKey:@"tp"];
    [mandatoryInMobiExtrasDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];
    self.interstitialAd.extras = mandatoryInMobiExtrasDict;

    [InMobiAdapterConfiguration setupInMobiSDKDemographicsParams:accountId];
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class)
                                       dspCreativeId:nil
                                             dspName:nil], [self getAdNetworkId]);

    IMCompletionBlock completionBlock = ^{
        if ([adMarkup isKindOfClass:[NSString class]] && adMarkup.length > 0) {
            [self.interstitialAd load:[adMarkup dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [self.interstitialAd load];
        }
    };
    [InMobiAdapterConfiguration invokeOnMainThreadAsSynced:YES withCompletionBlock:completionBlock];
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);

    if ([self hasAdAvailable]) {
        IMCompletionBlock completionBlock = ^{
            [self.interstitialAd showFromViewController:viewController withAnimation:kIMInterstitialAnimationTypeCoverVertical];
        };
        [InMobiAdapterConfiguration invokeOnMainThreadAsSynced:YES withCompletionBlock:completionBlock];
    } else {
        NSError *adNotAvailableError = [InMobiAdapterConfiguration createErrorWith:@"Failed to show InMobi Interstitial"
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

#pragma mark - InMobi Interstitial Delegate Methods

-(void)interstitialDidFinishLoading:(IMInterstitial*)interstitial {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    self.interstitialAd = interstitial;
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)interstitial:(IMInterstitial *)interstitial didReceiveWithMetaInfo:(IMAdMetaInfo *)metaInfo {
    MPLogInfo(@"InMobi ad server responded with an interstitial ad");
}

-(void)interstitial:(IMInterstitial*)interstitial didFailToLoadWithError:(IMRequestStatus*)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:(NSError*)error],
                 [self getAdNetworkId]);
    self.interstitialAd = nil;
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:(NSError *)error];
}

-(void)interstitialWillPresent:(IMInterstitial*)interstitial {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillPresent:self];
}

-(void)interstitialDidPresent:(IMInterstitial *)interstitial {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

-(void)interstitial:(IMInterstitial*)interstitial didFailToPresentWithError:(IMRequestStatus*)error {
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class)error:error],
                 [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:(NSError *)error];
}

-(void)interstitialWillDismiss:(IMInterstitial*)interstitial {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

-(void)interstitialDidDismiss:(IMInterstitial*)interstitial {
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    
    // Signal that the fullscreen ad is closing and the state should be reset.
    // `fullscreenAdAdapterAdDidDismiss:` was introduced in MoPub SDK 5.15.0.
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    }   
}

-(void)interstitial:(IMInterstitial*)interstitial didInteractWithParams:(NSDictionary*)params {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

-(void)userWillLeaveApplicationFromInterstitial:(IMInterstitial*)interstitial {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

// -- Unsupported by MoPub --
// No rewards on Interstitials
-(void)interstitial:(IMInterstitial*)interstitial rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    if (rewards != nil) {
        MPLogInfo(@"InMobi interstitial reward action completed with rewards: %@", [rewards description]);
    }
}

@end
