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
#import "AdColonyAdapterUtility.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

@interface AdColonyInterstitialCustomEvent () <AdColonyInterstitialDelegate>

@property (nonatomic, retain) AdColonyInterstitial *ad;
@property (nonatomic, copy) NSString *zoneId;

@end

@implementation AdColonyInterstitialCustomEvent

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    NSString *appId = info[ADC_APPLICATION_ID_KEY];
    NSArray *allZoneIds = info[ADC_ALL_ZONE_IDS_KEY];
    self.zoneId = info[ADC_ZONE_ID_KEY];
    NSError *error = [AdColonyAdapterUtility validateAppId:appId zonesList:allZoneIds andZone:self.zoneId];
    if (error) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    // Cache the initialization parameters
    [AdColonyAdapterConfiguration updateInitializationParameters:info];
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId allZoneIds:allZoneIds userId:nil callback:^(NSError *error){
        if (error) {
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
            return;
        }
        [AdColony requestInterstitialInZone:[self getAdNetworkId] options:nil andDelegate:self];
    }];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    if (self.ad) {
        if ([self.ad showWithPresentingViewController:rootViewController]) {
            [self.delegate interstitialCustomEventWillAppear:self];
            
            MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        } else {
            NSError *error = [AdColonyAdapterUtility createErrorWith:@"Failed to show AdColony video"
                                         andReason:@"Unknown Error"
                                     andSuggestion:@""];
            MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
            
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        }
    } else {
        NSError *error = [AdColonyAdapterUtility createErrorWith:@"Failed to show AdColony video"
                                     andReason:@"ad is not available"
                                 andSuggestion:@""];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (NSString *) getAdNetworkId {
    return self.zoneId;
}


#pragma mark - AdColony Interstitial Delegate Methods
- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial * _Nonnull)interstitial {
    self.ad = interstitial;
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
    [self.delegate interstitialCustomEvent:self didLoadAd:(id)interstitial];
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    self.ad = nil;
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
}

- (void)adColonyInterstitialWillOpen:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidAppear:self];
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)adColonyInterstitialDidClose:(AdColonyInterstitial * _Nonnull)interstitial {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventWillDisappear:self];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)adColonyInterstitialExpired:(AdColonyInterstitial * _Nonnull)interstitial {
    [self.delegate interstitialCustomEventDidExpire:self];
}

- (void)adColonyInterstitialWillLeaveApplication:(AdColonyInterstitial * _Nonnull)interstitial {
     [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial * _Nonnull)interstitial {
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}
@end
