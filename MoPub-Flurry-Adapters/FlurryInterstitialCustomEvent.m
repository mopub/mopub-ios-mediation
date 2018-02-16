//
//  FlurryInterstitialCustomEvent.m
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import "FlurryInterstitialCustomEvent.h"
#import "FlurryAdInterstitial.h"
#import "FlurryAdError.h"
#import "FlurryMPConfig.h"

#import "MPInstanceProvider.h"
#import "MPLogging.h"

@interface MPInstanceProvider (FlurryInterstitials)

- (FlurryAdInterstitial *)interstitialForSpace:(NSString *)adSpace delegate:(id<FlurryAdInterstitialDelegate>)delegate;

@end

@implementation MPInstanceProvider (FlurryInterstitials)

- (FlurryAdInterstitial *)interstitialForSpace:(NSString *)adSpace delegate:(id<FlurryAdInterstitialDelegate>)delegate
{
    FlurryAdInterstitial *interstitial = [[FlurryAdInterstitial alloc] initWithSpace:adSpace];
    interstitial.adDelegate = delegate;
    return interstitial;
}

@end

@interface  FlurryInterstitialCustomEvent()

@property (nonatomic, strong) UIView* adView;
@property (nonatomic, strong) FlurryAdInterstitial* adInterstitial;

@end

@implementation FlurryInterstitialCustomEvent

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Flurry interstitial ad");
    NSString *apiKey = [info objectForKey:@"apiKey"];
    NSString *adSpaceName = [info objectForKey:@"adSpaceName"];
    
    if (!apiKey || !adSpaceName) {
        MPLogError(@"Failed interstitial ad fetch. Missing required server extras [FLURRY_APIKEY and/or FLURRY_ADSPACE]");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    } else {
        MPLogInfo(@"Server info fetched from MoPub for Flurry. API key: %@. Ad space name: %@", apiKey, adSpaceName);
    }
    
    [FlurryMPConfig startSessionWithApiKey:apiKey];
    
    self.adInterstitial = [[MPInstanceProvider sharedProvider] interstitialForSpace:adSpaceName delegate:self];
    [self.adInterstitial fetchAd];
}


- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if (self.adInterstitial.ready) {
        [self.adInterstitial presentWithViewController:rootViewController];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)dealloc
{
    _adInterstitial.adDelegate = nil;
}

#pragma mark - FlurryAdInterstitialDelegate

- (void) adInterstitialDidFetchAd:(FlurryAdInterstitial*)interstitialAd
{
    MPLogInfo(@"Flurry interstital ad was fetched.");
    [self.delegate interstitialCustomEvent:self didLoadAd:interstitialAd];
}

- (void) adInterstitialDidRender:(FlurryAdInterstitial*)interstitialAd
{
    MPLogDebug(@"Flurry interstital ad was rendered.");
    [self.delegate interstitialCustomEventDidAppear:self];
    [self.delegate trackImpression];
}

- (void) adInterstitialWillPresent:(FlurryAdInterstitial*)interstitialAd
{
    MPLogDebug(@"Flurry interstital ad will present.");
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void) adInterstitialWillLeaveApplication:(FlurryAdInterstitial*)interstitialAd
{
    MPLogDebug(@"Flurry interstital ad will leave application.");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void) adInterstitialWillDismiss:(FlurryAdInterstitial*)interstitialAd
{
    MPLogDebug(@"Flurry interstital ad will dismiss.");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void) adInterstitialDidDismiss:(FlurryAdInterstitial*)interstitialAd
{
    MPLogDebug(@"Flurry interstital ad did dismiss.");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void) adInterstitialDidReceiveClick:(FlurryAdInterstitial*)interstitialAd
{
    MPLogInfo(@"Flurry interstital ad was clicked.");
    [self.delegate trackClick];
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void) adInterstitialVideoDidFinish:(FlurryAdInterstitial*)interstitialAd
{
    MPLogDebug(@"Flurry interstital video finished.");
}

- (void) adInterstitial:(FlurryAdInterstitial*) interstitialAd
                adError:(FlurryAdError) adError errorDescription:(NSError*) errorDescription
{
    MPLogInfo(@"Flurry interstitial failed to load with error: %@", errorDescription.description);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

@end
