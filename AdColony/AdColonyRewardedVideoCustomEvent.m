//
//  AdColonyRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>
#import "AdColonyAdapterConfiguration.h"
#import "AdColonyRewardedVideoCustomEvent.h"
#import "AdColonyInstanceMediationSettings.h"
#import "AdColonyController.h"
#if __has_include("MoPub.h")
    #import "MoPub.h"
    #import "MPLogging.h"
    #import "MPReward.h"
#endif

#define ADCOLONY_INITIALIZATION_TIMEOUT dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC)
#define ADCOLONY_AD_MARKUP @"adm"

@interface AdColonyRewardedVideoCustomEvent () <AdColonyInterstitialDelegate>

@property (nonatomic, retain) AdColonyInterstitial *ad;
@property (nonatomic, retain) AdColonyZone *zone;
@property (nonatomic, strong) NSString *zoneId;

@end

@implementation AdColonyRewardedVideoCustomEvent
@dynamic delegate;
@dynamic localExtras;

- (NSString *) getAdNetworkId {
    return _zoneId;
}

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    // Do not wait for the callback since this method may be run on app
    // launch on the main thread.
    [self initializeSdkWithParameters:parameters callback:^(NSError *error){
        if (error) {
            MPLogEvent([MPLogEvent error:error message:@"AdColony SDK initialization failed."]);
        } else {
            MPLogInfo(@"AdColony SDK initialization complete");
        }
    }];
}

- (void)initializeSdkWithParameters:(NSDictionary *)parameters callback:(void(^)(NSError *error))completionCallback {
    NSString * const appId      = parameters[ADC_APPLICATION_ID_KEY];
    NSString * const zoneId     = parameters[ADC_ZONE_ID_KEY];
    NSArray  * const allZoneIds = parameters[ADC_ALL_ZONE_IDS_KEY];
    NSString * const userId     = [parameters objectForKey:ADC_USER_ID_KEY]; // Optional
    
    NSError *appIdError = [AdColonyAdapterConfiguration validateParameter:appId withName:@"appId" forOperation:@"rewarded video ad request"];
    if (appIdError) {
        if (completionCallback) {
            completionCallback(appIdError);
        }
        return;
    }
    
    NSError *zoneIdError = [AdColonyAdapterConfiguration validateParameter:zoneId withName:@"zoneId" forOperation:@"rewarded video ad request"];
    if (zoneIdError) {
        if (completionCallback) {
            completionCallback(zoneIdError);
        }
        return;
    }
    self.zoneId = zoneId;
    
    NSError *allZoneIdsError = [AdColonyAdapterConfiguration validateZoneIds:allZoneIds forOperation:@"rewarded video ad request"];
    if (allZoneIdsError) {
        if (completionCallback) {
            completionCallback(appIdError);
        }
        return;
    }
    
    [AdColonyAdapterConfiguration updateInitializationParameters:parameters];
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId
                                                    allZoneIds:allZoneIds
                                                        userId:userId
                                                      callback:completionCallback];
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return YES;
}

- (BOOL)hasAdAvailable {
    return self.ad != nil;
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSMutableDictionary *adColonyParameters = [NSMutableDictionary dictionaryWithDictionary:info];
    adColonyParameters[@"userId"] = [self.delegate customerIdForAdapter:self];
    
    [self initializeSdkWithParameters:adColonyParameters callback:^(NSError *error) {
        if (error) {
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class)
                                                      error:error], [self getAdNetworkId]);
            [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
            return;
        }
        
        AdColonyInstanceMediationSettings *settings = [self.delegate fullscreenAdAdapter:self instanceMediationSettingsForClass:[AdColonyInstanceMediationSettings class]];
        BOOL showPrePopup = (settings) ? settings.showPrePopup : NO;
        BOOL showPostPopup = (settings) ? settings.showPostPopup : NO;
        
        AdColonyAdOptions *adOptions = [AdColonyAdOptions new];
        adOptions.showPrePopup = showPrePopup;
        adOptions.showPostPopup = showPostPopup;
        if (adMarkup != nil) {
            [adOptions setOption:ADCOLONY_AD_MARKUP withStringValue:adMarkup];
        }

        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class)
                                           dspCreativeId:nil
                                                 dspName:nil], [self getAdNetworkId]);
        [AdColony requestInterstitialInZone:self.zoneId
                                   options:adOptions
                               andDelegate:self];
    }];
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    if (self.ad) {
        if (![self.ad showWithPresentingViewController:viewController]) {
            NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
            MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class)
                                                      error:error], [self getAdNetworkId]);
            [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class)
                                                  error:error], [self getAdNetworkId]);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    }
}

#pragma mark - AdColony Interstitial Delegate Methods

- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial * _Nonnull)interstitial {
    self.zone = [AdColony zoneForID:self.zoneId];
    self.ad = interstitial;

    __weak AdColonyRewardedVideoCustomEvent *weakSelf = self;
    [weakSelf.zone setReward:^(BOOL success, NSString * _Nonnull name, int amount) {
        if (!success) {
            MPLogInfo(@"AdColony set reward failure in zone %@", weakSelf.zoneId);
            return;
        }
        MPReward *reward = [[MPReward alloc] initWithCurrencyType:name amount:@(amount)];
        [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
    }];

    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    self.ad = nil;
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class)
                                              error:error], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)adColonyInterstitialWillOpen:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillAppear:self];

    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)adColonyInterstitialDidClose:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    
    // Signal that the fullscreen ad is closing and the state should be reset.
    // `fullscreenAdAdapterAdDidDismiss:` was introduced in MoPub SDK 5.15.0.
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    }
}

- (void)adColonyInterstitialExpired:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogInfo(@"AdColony Rewarded Video has expired");
    [self.delegate fullscreenAdAdapterDidExpire:self];
}

- (void)adColonyInterstitialWillLeaveApplication:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

@dynamic hasAdAvailable;

@end
