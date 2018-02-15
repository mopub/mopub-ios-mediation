//
//  MPMillennialInterstitialCustomEvent.m
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#import "MPMillennialInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"
#import "MMAdapterVersion.h"

static NSString *const kMoPubMMAdapterAdUnit = @"adUnitID";
static NSString *const kMoPubMMAdapterDCN = @"dcn";

@implementation MPInstanceProvider (MillennialInterstitials)

- (MMInterstitialAd *)buildMMInterstitialWithPlacementId:(NSString *)placementId {
    return [[MMInterstitialAd alloc] initWithPlacementId:placementId];
}

@end

@interface MPMillennialInterstitialCustomEvent ()

@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, strong) MMInterstitialAd *interstitial;

@end

@implementation MPMillennialInterstitialCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (id)init {
    if (self = [super init]) {
        if([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
            MMSDK *mmSDK = [MMSDK sharedInstance];
            if(![mmSDK isInitialized]) {
                MMAppSettings *appSettings = [[MMAppSettings alloc] init];
                [mmSDK initializeWithSettings:appSettings withUserSettings:nil];
                MPLogDebug(@"Millennial adapter version: %@", self.version);
            }
        } else {
            self = nil; // No support below minimum OS.
        }
    }
    return self;
}

- (void)dealloc {
    [self invalidate];
}

- (void)invalidate {
    self.delegate = nil;
    self.interstitial = nil;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary<NSString *, id> *)info {

    MMSDK *mmSDK = [MMSDK sharedInstance];
    __strong __typeof__(self.delegate) delegate = self.delegate;

    if (![mmSDK isInitialized]) {
        NSError *error = [NSError errorWithDomain:MMSDKErrorDomain
                                             code:MMSDKErrorNotInitialized
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Millennial adapter not properly intialized yet."]
                                                    }];
        MPLogError(@"%@", [error localizedDescription]);
        [delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }

    MPLogDebug(@"Requesting Millennial interstitial with event info %@.", info);

    NSString *placementId = info[kMoPubMMAdapterAdUnit];
    if (!placementId) {
        NSError *error = [NSError errorWithDomain:MMSDKErrorDomain
                                             code:MMSDKErrorServerResponseNoContent
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Millennial received no placement ID. Request failed."]
                                                    }];
        MPLogError(@"%@", [error localizedDescription]);
        [delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }

    [mmSDK appSettings].mediator = NSStringFromClass([MPMillennialInterstitialCustomEvent class]);
    if (info[kMoPubMMAdapterDCN]) {
        [mmSDK appSettings].siteId = info[kMoPubMMAdapterDCN];
    } else {
        [mmSDK appSettings].siteId = nil;
    }

    self.interstitial = [[MPInstanceProvider sharedProvider] buildMMInterstitialWithPlacementId:placementId];
    self.interstitial.delegate = self;

    [self.interstitial load:nil];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    if (self.interstitial.ready) {
        [self.interstitial showFromViewController:rootViewController];
    }
}

-(MMCreativeInfo*)creativeInfo
{
    return self.interstitial.creativeInfo;
}

-(NSString*)version
{
    return kMMAdapterVersion;
}

#pragma mark - MMInterstitialDelegate

- (void)interstitialAdLoadDidSucceed:(MMInterstitialAd *)ad {
    MPLogDebug(@"Millennial interstitial %@ did load, creative ID %@.", ad, self.creativeInfo.creativeId);
    [self.delegate interstitialCustomEvent:self didLoadAd:ad];
}

- (void)interstitialAd:(MMInterstitialAd *)ad loadDidFailWithError:(NSError *)error {
    __strong __typeof__(self.delegate) delegate = self.delegate;
    if (error.code == MMSDKErrorInterstitialAdAlreadyLoaded) {
        MPLogDebug(@"Millennial interstitial %@ already loaded, ignoring this request.", ad);
    } else {
        MPLogWarn(@"Millennial interstitial %@ failed with error (%d) %@.", ad, error.code, error.description);
        [delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)interstitialAdWillDisplay:(MMInterstitialAd *)ad {
    MPLogDebug(@"Millennial interstial %@ will display.", ad);
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialAdDidDisplay:(MMInterstitialAd *)ad {
    __strong __typeof__(self.delegate) delegate = self.delegate;
    MPLogDebug(@"Millennial interstitial %@ did appear.", ad);
    [delegate interstitialCustomEventDidAppear:self];
    [delegate trackImpression];
}

- (void)interstitialAd:(MMInterstitialAd *)ad showDidFailWithError:(NSError *)error {
    // MoPub does not have the concept of "failed to show", but does allow for `interstitialCustomEventDidExpire:` to be
    // called in the event that an ad "should no longer be elligible for presentation", which is an appropriate
    // mapping.

    MPLogWarn(@"Millennial interstitial %@ show failed %ld: %@", ad, error.code, error.description);
    [self.delegate interstitialCustomEventDidExpire:self];
    [self invalidate];
}


- (void)interstitialAdTapped:(MMInterstitialAd *)ad {
    __strong __typeof__(self.delegate) delegate = self.delegate;
    if (!self.didTrackClick) {
        MPLogDebug(@"Millennial interstitial %@ tracking click.", ad);
        [delegate trackClick];
        self.didTrackClick = YES;
        [delegate interstitialCustomEventDidReceiveTapEvent:self];
    } else {
        MPLogDebug(@"Millennial interstitial %@ ignoring duplicate click.", ad);
    }
}

- (void)interstitialAdWillDismiss:(MMInterstitialAd *)ad {
    MPLogDebug(@"Millennial interstitial %@ will dismiss.", ad);
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialAdDidDismiss:(MMInterstitialAd *)ad {
    __strong __typeof__(self.delegate) delegate = self.delegate;
    MPLogDebug(@"Millennial interstitial %@ did dismiss.", ad);
    [delegate interstitialCustomEventDidDisappear:self];
    [self invalidate];
}

- (void)interstitialAdDidExpire:(MMInterstitialAd *)ad {
    MPLogWarn(@"Millennial interstitial %@ has expired.", ad);
    [self.delegate interstitialCustomEventDidExpire:self];
    [self invalidate];
}

- (void)interstitialAdWillLeaveApplication:(MMInterstitialAd *)ad {
    MPLogDebug(@"Millennial interstitial %@ leaving app.", ad);
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
