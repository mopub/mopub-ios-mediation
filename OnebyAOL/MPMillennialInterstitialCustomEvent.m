//
//  MPMillennialInterstitialCustomEvent.m
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#import "MPMillennialInterstitialCustomEvent.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif
#import "MMAdapterVersion.h"

static NSString *const kMoPubMMAdapterAdUnit = @"adUnitID";
static NSString *const kMoPubMMAdapterDCN = @"dcn";

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
                MPLogInfo(@"Millennial adapter version: %@", self.version);
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
        [delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);

        return;
    }

    NSString *placementId = info[kMoPubMMAdapterAdUnit];
    if (placementId == nil) {
        NSError *error = [NSError errorWithDomain:MMSDKErrorDomain
                                             code:MMSDKErrorServerResponseNoContent
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Millennial received no placement ID. Request failed."]
                                                    }];
        [delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);

        return;
    }

    [mmSDK appSettings].mediator = NSStringFromClass([MPMillennialInterstitialCustomEvent class]);
    if (info[kMoPubMMAdapterDCN]) {
        [mmSDK appSettings].siteId = info[kMoPubMMAdapterDCN];
    } else {
        [mmSDK appSettings].siteId = nil;
    }

    self.interstitial = [[MMInterstitialAd alloc] initWithPlacementId:placementId];
    self.interstitial.delegate = self;

    [self.interstitial load:nil];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

    if (self.interstitial.ready) {
        [self.interstitial showFromViewController:rootViewController];
    } else {
        NSError *error = [NSError errorWithCode:MOPUBErrorUnknown localizedDescription:@"Failed to show AOL interstitial ad"];
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];

        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
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
    [self.delegate interstitialCustomEvent:self didLoadAd:ad];
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)interstitialAd:(MMInterstitialAd *)ad loadDidFailWithError:(NSError *)error {
    __strong __typeof__(self.delegate) delegate = self.delegate;
    if (error.code == MMSDKErrorInterstitialAdAlreadyLoaded) {
        MPLogInfo(@"Millennial interstitial %@ already loaded, ignoring this request.", ad);
    } else {
        [delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
}

- (void)interstitialAdWillDisplay:(MMInterstitialAd *)ad {
    [self.delegate interstitialCustomEventWillAppear:self];
    
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)interstitialAdDidDisplay:(MMInterstitialAd *)ad {
    __strong __typeof__(self.delegate) delegate = self.delegate;
    [delegate interstitialCustomEventDidAppear:self];
    [delegate trackImpression];
    
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)interstitialAd:(MMInterstitialAd *)ad showDidFailWithError:(NSError *)error {
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);

    [self.delegate interstitialCustomEventDidExpire:self];
    [self invalidate];
}


- (void)interstitialAdTapped:(MMInterstitialAd *)ad {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

    __strong __typeof__(self.delegate) delegate = self.delegate;
    if (!self.didTrackClick) {
        [delegate trackClick];
        self.didTrackClick = YES;
        [delegate interstitialCustomEventDidReceiveTapEvent:self];
    } else {
        MPLogInfo(@"Millennial interstitial %@ ignoring duplicate click.", ad);
    }
}

- (void)interstitialAdWillDismiss:(MMInterstitialAd *)ad {
    [self.delegate interstitialCustomEventWillDisappear:self];
    
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)interstitialAdDidDismiss:(MMInterstitialAd *)ad {
    __strong __typeof__(self.delegate) delegate = self.delegate;
    [delegate interstitialCustomEventDidDisappear:self];
    [self invalidate];
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)interstitialAdDidExpire:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial %@ has expired.", ad);
    [self.delegate interstitialCustomEventDidExpire:self];
    [self invalidate];
}

- (void)interstitialAdWillLeaveApplication:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial %@ leaving app.", ad);
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (NSString *) getAdNetworkId {
    return kMoPubMMAdapterAdUnit;
}


@end
