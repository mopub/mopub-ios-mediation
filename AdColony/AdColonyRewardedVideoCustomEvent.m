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
    #import "MPRewardedVideoReward.h"
#endif

#define ADCOLONY_INITIALIZATION_TIMEOUT dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC)

@interface AdColonyRewardedVideoCustomEvent () <AdColonyInterstitialDelegate>

@property (nonatomic, retain) AdColonyInterstitial *ad;
@property (nonatomic, retain) AdColonyZone *zone;
@property (nonatomic, strong) NSString *zoneId;

@end

@implementation AdColonyRewardedVideoCustomEvent

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
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class)
                                       dspCreativeId:nil
                                             dspName:nil], [self getAdNetworkId]);
    [AdColonyAdapterConfiguration updateInitializationParameters:parameters];
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId
                                                    allZoneIds:allZoneIds
                                                        userId:userId
                                                      callback:completionCallback];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
    NSMutableDictionary *newInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    newInfo[@"userId"] = customerId;
    
    [self initializeSdkWithParameters:newInfo callback:^(NSError *error) {
        if (error) {
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class)
                                                      error:error], [self getAdNetworkId]);
            [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
            return;
        }
        
        AdColonyInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[AdColonyInstanceMediationSettings class]];
        BOOL showPrePopup = (settings) ? settings.showPrePopup : NO;
        BOOL showPostPopup = (settings) ? settings.showPostPopup : NO;
        
        AdColonyAdOptions *adOptions = [AdColonyAdOptions new];
        adOptions.showPrePopup = showPrePopup;
        adOptions.showPostPopup = showPostPopup;
        
       [AdColony requestInterstitialInZone:self.zoneId
                                   options:adOptions
                               andDelegate:self];
    }];
}

- (BOOL)hasAdAvailable {
    return self.ad != nil;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    if (self.ad) {
        if (![self.ad showWithPresentingViewController:viewController]) {
            NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
            MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class)
                                                      error:error], [self getAdNetworkId]);
            [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class)
                                                  error:error], [self getAdNetworkId]);
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
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
        [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:[[MPRewardedVideoReward alloc] initWithCurrencyType:name amount:@(amount)]];
    }];

    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:weakSelf];
}

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    self.ad = nil;
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class)
                                              error:error], [self getAdNetworkId]);
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)adColonyInterstitialWillOpen:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];

    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)adColonyInterstitialDidClose:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)adColonyInterstitialExpired:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogInfo(@"AdColony Rewarded Video has expired");
    [self.delegate rewardedVideoDidExpireForCustomEvent:self];
}

- (void)adColonyInterstitialWillLeaveApplication:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate rewardedVideoWillLeaveApplicationForCustomEvent:self];
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

@end
