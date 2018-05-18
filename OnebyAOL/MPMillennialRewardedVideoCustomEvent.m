//
//  MPMillennialRewardedVideoCustomEvent.m
//
//  Created by Terence Worley on 8/25/16
//  Copyright (c) 2016 MillennialMedia. All rights reserved.
//

#import "MPMillennialRewardedVideoCustomEvent.h"
#import "MPMillennialInterstitialCustomEvent.h"
#import "MPLogging.h"
#import <MMAdSDK/MMAd+Experimental.h>
#import "MMAdapterVersion.h"
#import <objc/runtime.h>
#import "MPRewardedVideoCustomEvent+Caching.h"

static NSString *const kMoPubMMAdapterAdUnit = @"adUnitID";
static NSString *const kMoPubMMAdapterDCN = @"dcn";

static const char *const kMoPubMMRewardEventKey = "_rewardEvent_";

// Because there is an actual appropriate delegate method for rewards when an ad fails to show,
// we want to re-route it to the correct place here. Hence this delegate overload that
// redirects to the appropriate place.

@interface MPMillennialInterstitialRewardCustomEvent : MPMillennialInterstitialCustomEvent<MMInterstitialDelegate>
@property (nonatomic, weak) MPRewardedVideoCustomEvent* rewardEvent;
@end

@implementation MPMillennialInterstitialRewardCustomEvent

-(void)setRewardEvent:(MPRewardedVideoCustomEvent*)rewardEvent
{
    objc_setAssociatedObject(self, kMoPubMMRewardEventKey, rewardEvent, OBJC_ASSOCIATION_ASSIGN);
}

-(MPRewardedVideoCustomEvent*)rewardEvent
{
    return objc_getAssociatedObject(self, kMoPubMMRewardEventKey);
}

-(void)interstitialAd:(MMInterstitialAd*)ad showDidFailWithError:(nonnull NSError *)error
{
    [self.rewardEvent.delegate rewardedVideoDidFailToPlayForCustomEvent:self.rewardEvent error:error];
}

@end

@interface MPMillennialRewardedVideoCustomEvent () <MMXIncentiveDelegate, MPInterstitialCustomEventDelegate>
@property (nonatomic, strong) MPMillennialInterstitialRewardCustomEvent *interstitialEvent;
@property (nonatomic, assign) BOOL didTrackClick;
@end

@implementation MPMillennialRewardedVideoCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (id)init {
    if (self = [super init]) {
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
            MMSDK *mmSDK = [MMSDK sharedInstance];
            if (![mmSDK isInitialized]) {
                [mmSDK initializeWithSettings:[[MMAppSettings alloc] init]
                             withUserSettings:nil];
                MPLogDebug(@"Millennial adapter version: %@", self.version);
            }
            
            // Collect and pass the user's consent from MoPub onto the One by AOL SDK
            if ( [MoPub sharedInstance].isGDPRApplicable == MPBoolYes )
                [mmSDK setConsentRequired: TRUE];
            else
                [mmSDK setConsentRequired: FALSE];
            
            if ( [[MoPub sharedInstance] currentConsentStatus] == MPConsentStatusConsented ) {
                [mmSDK setConsentDataValue: @"1" forKey:@"mopub"];
            }
            
        } else {
            self = nil; // No support below minimum OS.
        }
    }
    return self;
}

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MMSDK *mmSDK = [MMSDK sharedInstance];
        if (![mmSDK isInitialized]) {
            [mmSDK initializeWithSettings:[[MMAppSettings alloc] init]
                         withUserSettings:nil];
            MPLogDebug(@"Millennial adapter version: %@", self.version);
        }
    });
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary<NSString *, id> *)info {

    MMSDK *mmSDK = [MMSDK sharedInstance];
    
    if (![mmSDK isInitialized]) {
        NSError *error = [NSError errorWithDomain:MMSDKErrorDomain
                                             code:MMSDKErrorNotInitialized
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Millennial adapter not properly intialized yet."]
                                                    }];
        MPLogError(@"%@", [error localizedDescription]);
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        return;
    }

    MPLogDebug(@"Requesting Millennial rewarded video with event info %@.", info);

    NSString *placementId = info[kMoPubMMAdapterAdUnit];
    if (!placementId) {
        NSError *error = [NSError errorWithDomain:MMSDKErrorDomain
                                             code:MMSDKErrorServerResponseNoContent
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Millennial received no placement ID. Request failed."]
                                                    }];
        MPLogError(@"%@", [error localizedDescription]);
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        return; // Early return
    }

    // Cache the initialization parameters
    [self setCachedInitializationParameters:info];

    [mmSDK appSettings].mediator = NSStringFromClass([MPMillennialRewardedVideoCustomEvent class]);
    if (info[kMoPubMMAdapterDCN]) {
        [mmSDK appSettings].siteId = info[kMoPubMMAdapterDCN];
    } else {
        [mmSDK appSettings].siteId = nil;
    }

    // Create a new interstitial event for the reward video playback.
    self.interstitialEvent = [[MPMillennialInterstitialRewardCustomEvent alloc] init];
    self.interstitialEvent.delegate = self;
    self.interstitialEvent.rewardEvent = self;
    [self.interstitialEvent requestInterstitialWithCustomEventInfo:info];
}

- (BOOL)hasAdAvailable {
    return [self.interstitialEvent.interstitial ready];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    if ([self hasAdAvailable]) {
        [self.interstitialEvent showInterstitialFromRootViewController:viewController];
    } else {
        NSError *error = [NSError errorWithDomain:MMSDKErrorDomain
                                             code:MMSDKErrorNoFill
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Millennial reward video was unavailable to display."]
                                                    }];
        MPLogError(@"%@", [error localizedDescription]);
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)handleCustomEventInvalidated {
    self.interstitialEvent.delegate = nil;
    self.interstitialEvent.interstitial.xIncentiveDelegate = nil;
    self.interstitialEvent = nil;
    self.delegate = nil;
}

- (void)handleAdPlayedForCustomEventNetwork {
    // If we no longer have an ad available, report back up to the application that this ad expired.
    if (![self hasAdAvailable]) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }
}

-(MMCreativeInfo*)creativeInfo
{
    return self.interstitialEvent.creativeInfo;
}

-(NSString*)version
{
    return kMMAdapterVersion;
}

#pragma mark - MMXIncentiveDelegate

- (BOOL)incentivizedAdCompletedVideo:(MMAd *)ad {
    MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyAmount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)];
    MPLogDebug(@"%@ incentivizedAdCompletedVideo %@, reward: %@.", NSStringFromClass([self class]), ad, reward);
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
    return YES;
}

- (BOOL)incentivizedAd:(MMAd *)ad triggeredEvent:(MMXIncentiveEvent *)event {
    // kMMXIncentiveVideoCompleteEventId events already special-cased by the SDK
    // to call incentivizedAdCompletedVideo directly. Otherwise we could check
    // for it here and call incentivizedAdCompletedVideo.
    MPLogDebug(@"%@ incentivizedAd: %@  triggeredEvent: %@.", NSStringFromClass([self class]), ad, event);
    return YES;
}

-(void)xIncentiveEventWasTriggered:(MMXIncentiveEvent *)event {
    MPLogDebug(@"%@ xIncentiveEventWasTriggered %@.", NSStringFromClass([self class]), event);
}

#pragma mark - MPInterstitialCustomEventDelegate

//
// These protocol methods handle the interstitial custom event (MPMillennialInterstitialCustomEvent)
// generated by this rewarded video custom event (MPMillennialRewardedVideoCustomEvent). However these
// delegate calls are handling this rewarded video instance as the parent, and generally ignore the
// customEvent parameter.
//

- (CLLocation *)location {
    return [MMSDK sharedInstance].locationManager.location;
}

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent
                      didLoadAd:(id)ad {
    MPLogDebug(@"%@ interstitialCustomEvent didLoadAd %@/%@.", NSStringFromClass([self class]), self, customEvent);
    // Now that we have the interstitial, assign the incentive delegate to be
    // notified when the video has completed.
    if (customEvent == self.interstitialEvent) {
        self.interstitialEvent.interstitial.xIncentiveDelegate = self;
    }
    // Let the delegate know we're ready.
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent
       didFailToLoadAdWithError:(NSError *)error {
    MPLogDebug(@"%@ interstitialCustomEvent didFailToLoadAdWithError %@ / %@: %@.", NSStringFromClass([self class]), self, customEvent, error);
    if (error.code == MMSDKErrorInterstitialAdAlreadyLoaded) {
        MPLogInfo(@"Interstitial already loaded, ignoring this request.");
        [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    } else {
        MPLogError(@"Interstitial failed with error (%d) %@.", error.code, error.description);
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
}

- (void)interstitialCustomEventDidExpire:(MPInterstitialCustomEvent *)customEvent {
    [self.delegate rewardedVideoDidExpireForCustomEvent:self];
}

- (void)interstitialCustomEventWillAppear:(MPInterstitialCustomEvent *)customEvent {
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
}

- (void)interstitialCustomEventDidAppear:(MPInterstitialCustomEvent *)customEvent {
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)interstitialCustomEventWillDisappear:(MPInterstitialCustomEvent *)customEvent {
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
}

- (void)interstitialCustomEventDidDisappear:(MPInterstitialCustomEvent *)customEvent {
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)interstitialCustomEventDidReceiveTapEvent:(MPInterstitialCustomEvent *)customEvent {
    MPLogDebug(@"%@ interstitialCustomEvent tap event %@ / %@.", NSStringFromClass([self class]), self, customEvent);
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

- (void)interstitialCustomEventWillLeaveApplication:(MPInterstitialCustomEvent *)customEvent {
    [self.delegate rewardedVideoWillLeaveApplicationForCustomEvent:self];
}

- (void)trackImpression {
    MPLogDebug(@"%@ trackImpression %@.", NSStringFromClass([self class]), self);
    [self.delegate trackImpression];
}

- (void)trackClick {
    MPLogDebug(@"%@ trackClick %@.", NSStringFromClass([self class]), self);
    [self.delegate trackClick];
}

@end
