//
//  AdColonyInterstitialCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>
#import "AdColonyAdapterConfiguration.h"
#import "AdColonyInterstitialCustomEvent.h"
#import "AdColonyController.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

#define ADCOLONY_AD_MARKUP @"adm"

@interface AdColonyInterstitialCustomEvent () <AdColonyInterstitialDelegate>

@property (nonatomic, retain) AdColonyInterstitial *ad;
@property (nonatomic, copy) NSString *zoneId;

@end

@implementation AdColonyInterstitialCustomEvent
@dynamic delegate;
@dynamic localExtras;

- (NSString *) getAdNetworkId {
    return _zoneId;
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return self.ad != nil;
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString * const appId      = info[ADC_APPLICATION_ID_KEY];
    NSString * const zoneId     = info[ADC_ZONE_ID_KEY];
    NSArray  * const allZoneIds = info[ADC_ALL_ZONE_IDS_KEY];
    
    NSError *appIdError = [AdColonyAdapterConfiguration validateParameter:appId withName:@"appId" forOperation:@"interstitial ad request"];
    if (appIdError) {
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:appIdError];
        return;
    }
    
    NSError *zoneIdError = [AdColonyAdapterConfiguration validateParameter:zoneId withName:@"zoneId" forOperation:@"interstitial ad request"];
    if (zoneIdError) {
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:zoneIdError];
        return;
    }
    self.zoneId = zoneId;
    
    NSError *allZoneIdsError = [AdColonyAdapterConfiguration validateZoneIds:allZoneIds forOperation:@"interstitial ad request"];
    if (allZoneIdsError) {
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:allZoneIdsError];
        return;
    }
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class)
                                       dspCreativeId:nil
                                             dspName:nil], self.zoneId);
    [AdColonyAdapterConfiguration updateInitializationParameters:info];
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId
                                                    allZoneIds:allZoneIds
                                                        userId:nil
                                                      callback:^(NSError *error) {
        if (error) {
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class)
                                                      error:error], [self getAdNetworkId]);
            [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
            return;
        }
        
        AdColonyAdOptions *adOptions = nil;
        if (adMarkup != nil) {
            adOptions = [AdColonyAdOptions new];
            [adOptions setOption:ADCOLONY_AD_MARKUP withStringValue:adMarkup];
        }
        
        [AdColony requestInterstitialInZone:self.zoneId
                                    options:adOptions
                                andDelegate:self];
    }];
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    
    if (self.ad) {
        if ([self.ad showWithPresentingViewController:viewController]) {
            MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)],
                         [self getAdNetworkId]);
            [self.delegate fullscreenAdAdapterAdWillAppear:self];
        } else {
            NSError *unknownError = [AdColonyAdapterConfiguration createErrorWith:@"Failed to show AdColony Interstitial"
                                                                        andReason:@"AdColony SDK failed to show"
                                                                    andSuggestion:@""];
            MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class)
                                                      error:unknownError], [self getAdNetworkId]);
            [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:unknownError];
        }
    } else {
        NSError *adNotAvailableError = [AdColonyAdapterConfiguration createErrorWith:@"Failed to show AdColony Interstitial"
                                                                           andReason:@"Ad is not available"
                                                                       andSuggestion:@""];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:adNotAvailableError],
                     [self getAdNetworkId]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:adNotAvailableError];
    }
}

#pragma mark - AdColony Interstitial Delegate Methods

- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    self.ad = interstitial;
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error],
                 [self getAdNetworkId]);
    self.ad = nil;
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)adColonyInterstitialWillOpen:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)adColonyInterstitialDidClose:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
 
    // Signal that the fullscreen ad is closing and the state should be reset.
    // `fullscreenAdAdapterAdDidDismiss:` was introduced in MoPub SDK 5.15.0.
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    }
}

- (void)adColonyInterstitialExpired:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogInfo(@"AdColony Interstitial has expired");
    [self.delegate fullscreenAdAdapterDidExpire:self];
}

- (void)adColonyInterstitialWillLeaveApplication:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

@dynamic hasAdAvailable;

@end
