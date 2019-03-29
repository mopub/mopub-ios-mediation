//
//  FlurryInterstitialCustomEvent.m
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import "FlurryInterstitialCustomEvent.h"
#import "FlurryMPConfig.h"
#import "FlurryAdapterConfiguration.h"

#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

@interface  FlurryInterstitialCustomEvent()

@property (nonatomic, strong) UIView* adView;
@property (nonatomic, strong) FlurryAdInterstitial* adInterstitial;
@property (nonatomic, copy) NSString *apiKey;

@end

@implementation FlurryInterstitialCustomEvent

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    self.apiKey = [info objectForKey:@"apiKey"];
    NSString *adSpaceName = [info objectForKey:@"adSpaceName"];
    
    if (!self.apiKey || !adSpaceName) {        
        NSError *error = [self createErrorWith:@"Failed interstitial ad fetch"
                                     andReason:@"Missing required server extras [FLURRY_APIKEY and/or FLURRY_ADSPACE]"
                                 andSuggestion:@"Make sure that the Flurry API key or ad space parameter is not nil"];
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);

        return;
    } else {
        MPLogInfo(@"Server info fetched from MoPub for Flurry. API key: %@. Ad space name: %@", [self getAdNetworkId], adSpaceName);
    }
    
    // Cache the initialization parameters
    [FlurryAdapterConfiguration updateInitializationParameters:info];
    
    [FlurryMPConfig startSessionWithApiKey:self.apiKey];
    
    self.adInterstitial = [[FlurryAdInterstitial alloc] initWithSpace:adSpaceName];
    self.adInterstitial.adDelegate = self;
    [self.adInterstitial fetchAd];
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

    if (self.adInterstitial.ready) {
        [self.adInterstitial presentWithViewController:rootViewController];
    } else {
        NSError *error = [self createErrorWith:@"Trying to show a Flurry interstitial ad when it's not ready."
                                     andReason:@""
                                 andSuggestion:@""];

        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)dealloc
{
    self.adInterstitial.adDelegate = nil;
}

- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reaason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reaason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

#pragma mark - FlurryAdInterstitialDelegate

- (void) adInterstitialDidFetchAd:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate interstitialCustomEvent:self didLoadAd:interstitialAd];

    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void) adInterstitialDidRender:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate interstitialCustomEventDidAppear:self];
    [self.delegate trackImpression];

    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void) adInterstitialWillPresent:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate interstitialCustomEventWillAppear:self];
    
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void) adInterstitialWillLeaveApplication:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void) adInterstitialWillDismiss:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate interstitialCustomEventWillDisappear:self];

    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void) adInterstitialDidDismiss:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate interstitialCustomEventDidDisappear:self];

    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void) adInterstitialDidReceiveClick:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate trackClick];
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void) adInterstitialVideoDidFinish:(FlurryAdInterstitial*)interstitialAd
{
    MPLogInfo(@"Flurry interstital video finished.");
}

- (void) adInterstitial:(FlurryAdInterstitial*) interstitialAd
                adError:(FlurryAdError) adError errorDescription:(NSError*) errorDescription
{
    NSString *failureReason = [NSString stringWithFormat:@"Flurry interstitial failed to load with error: %@", errorDescription.description];

    NSError *error = [self createErrorWith:failureReason
                                 andReason:@""
                             andSuggestion:@""];

    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
}

- (NSString *) getAdNetworkId {
    return self.apiKey;
}

@end