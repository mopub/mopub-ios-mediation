//
//  FacebookInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookInterstitialCustomEvent.h"
#import "FacebookAdapterConfiguration.h"

#if __has_include("MoPub.h")
    #import "MoPub.h"
    #import "MPLogging.h"
    #import "MPRealTimeTimer.h"
#endif

//Timer to record the expiration interval
#define FB_ADS_EXPIRATION_INTERVAL  3600

@interface FacebookInterstitialCustomEvent () <FBInterstitialAdDelegate>

@property (nonatomic, strong) FBInterstitialAd *fbInterstitialAd;
@property (nonatomic, strong) MPRealTimeTimer *timer;
@property (nonatomic, assign) BOOL impressionTracked;
@property (nonatomic, copy) NSString *fbPlacementId;

@end

@implementation FacebookInterstitialCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected
{
    return NO;
}

- (BOOL)hasAdAvailable
{
    return self.fbInterstitialAd.isAdValid;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    self.fbPlacementId = [info objectForKey:@"placement_id"];
    if (self.fbPlacementId == nil) {
        
        NSError *error = [self createErrorWith:@"Invalid Facebook placement ID"
                                     andReason:@""
                                 andSuggestion:@""];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        
        return;
    }

    self.fbInterstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:[info objectForKey:@"placement_id"]];
    self.fbInterstitialAd.delegate = self;
    [FBAdSettings setMediationService:[FacebookAdapterConfiguration mediationString]];

    // Load the advanced bid payload.
    if (adMarkup != nil) {
        MPLogInfo(@"Loading Facebook interstitial ad markup for Advanced Bidding");
        [self.fbInterstitialAd loadAdWithBidPayload:adMarkup];

        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.fbPlacementId);
    }
    // Request a interstitial ad.
    else {
        MPLogInfo(@"Loading Facebook interstitial");
        [self.fbInterstitialAd loadAd];

        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.fbPlacementId);
    }
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
    if (!self.fbInterstitialAd || !self.fbInterstitialAd.isAdValid) {        
        NSError *error = [self createErrorWith:@"Error in loading Facebook Interstitial"
                                     andReason:@""
                                 andSuggestion:@""];    
        
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.fbPlacementId);
        [self.delegate fullscreenAdAdapterDidExpire:self];
    } else {
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);

        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);
        [self.delegate fullscreenAdAdapterAdWillAppear:self];

        [self.fbInterstitialAd showAdFromRootViewController:viewController];
        
        MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);
        [self.delegate fullscreenAdAdapterAdDidAppear:self];
        
        [self cancelExpirationTimer];
    }
}

- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reaason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reaason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };

    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

- (void)dealloc
{
    self.fbInterstitialAd.delegate = nil;
    [self cancelExpirationTimer];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

-(void)cancelExpirationTimer
{
    if (self.timer != nil)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark FBInterstitialAdDelegate methods

- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    [self cancelExpirationTimer];

    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
    
    // introduce timer for 1 hour per expiration logic introduced by FB
    __weak __typeof__(self) weakSelf = self;
    self.timer = [[MPRealTimeTimer alloc] initWithInterval:FB_ADS_EXPIRATION_INTERVAL block:^(MPRealTimeTimer *timer){
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (strongSelf && !strongSelf.impressionTracked) {
            [strongSelf.delegate fullscreenAdAdapterDidExpire:self];

            NSError *error = [self createErrorWith:@"Facebook interstitial ad expired  per Audience Network's expiration policy"
                                         andReason:@""
                                     andSuggestion:@""];

            MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.fbPlacementId);
            //Delete the cached objects
            strongSelf.fbInterstitialAd = nil;
        }
    }];
    [self.timer scheduleNow];
}

- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd
{
    [self cancelExpirationTimer];

    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);
    
    //set the tracker to true when the ad is shown on the screen. So that the timer is invalidated.
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
    self.impressionTracked = true;
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    [self cancelExpirationTimer];

    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.fbPlacementId);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    
    // Signal that the fullscreen ad is closing and the state should be reset.
    // `fullscreenAdAdapterAdDidDismiss:` was introduced in MoPub SDK 5.15.0.
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    }
}

- (void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.fbPlacementId);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

@end
