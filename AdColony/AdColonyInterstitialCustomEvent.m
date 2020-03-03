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

@interface AdColonyInterstitialCustomEvent () <AdColonyInterstitialDelegate>

@property (nonatomic, retain) AdColonyInterstitial *ad;
@property (nonatomic, copy) NSString *zoneId;

@end

@implementation AdColonyInterstitialCustomEvent

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (NSString *) getAdNetworkId {
    return _zoneId;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString * const appId      = info[ADC_APPLICATION_ID_KEY];
    NSString * const zoneId     = info[ADC_ZONE_ID_KEY];
    NSArray  * const allZoneIds = info[ADC_ALL_ZONE_IDS_KEY];
    
    NSError *appIdError = [AdColonyAdapterConfiguration validateParameter:appId withName:@"appId" forOperation:@"interstitial ad request"];
    if (appIdError) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:appIdError];
        return;
    }
    
    NSError *zoneIdError = [AdColonyAdapterConfiguration validateParameter:zoneId withName:@"zoneId" forOperation:@"interstitial ad request"];
    if (zoneIdError) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:zoneIdError];
        return;
    }
    self.zoneId = zoneId;
    
    NSError *allZoneIdsError = [AdColonyAdapterConfiguration validateZoneIds:allZoneIds forOperation:@"interstitial ad request"];
    if (allZoneIdsError) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:allZoneIdsError];
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
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
            return;
        }
        
        [AdColony requestInterstitialInZone:self.zoneId
                                    options:nil
                                andDelegate:self];
    }];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    
    if (self.ad) {
        if ([self.ad showWithPresentingViewController:rootViewController]) {
            MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)],
                         [self getAdNetworkId]);
            [self.delegate interstitialCustomEventWillAppear:self];
        } else {
            NSError *unknownError = [AdColonyAdapterConfiguration createErrorWith:@"Failed to show AdColony Interstitial"
                                                                        andReason:@"AdColony SDK failed to show"
                                                                    andSuggestion:@""];
            MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class)
                                                      error:unknownError], [self getAdNetworkId]);
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:unknownError];
        }
    } else {
        NSError *adNotAvailableError = [AdColonyAdapterConfiguration createErrorWith:@"Failed to show AdColony Interstitial"
                                                                           andReason:@"Ad is not available"
                                                                       andSuggestion:@""];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:adNotAvailableError],
                     [self getAdNetworkId]);
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:adNotAvailableError];
    }
}

#pragma mark - AdColony Interstitial Delegate Methods
- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    self.ad = interstitial;
    [self.delegate interstitialCustomEvent:self didLoadAd:(id)interstitial];
}

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error],
                 [self getAdNetworkId]);
    self.ad = nil;
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adColonyInterstitialWillOpen:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)adColonyInterstitialDidClose:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate interstitialCustomEventWillDisappear:self];
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)adColonyInterstitialExpired:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogInfo(@"AdColony Interstitial has expired");
    [self.delegate interstitialCustomEventDidExpire:self];
}

- (void)adColonyInterstitialWillLeaveApplication:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)],
                 [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end
