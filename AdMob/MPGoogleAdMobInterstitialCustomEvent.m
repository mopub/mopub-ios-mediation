//
//  MPGoogleAdMobInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "MPGoogleAdMobInterstitialCustomEvent.h"
#import "MPInterstitialAdController.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import <CoreLocation/CoreLocation.h>

@interface MPGoogleAdMobInterstitialCustomEvent () <GADInterstitialDelegate>

@property (nonatomic, strong) GADInterstitial *interstitial;

@end

@implementation MPGoogleAdMobInterstitialCustomEvent

@synthesize interstitial = _interstitial;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Google AdMob interstitial");
    self.interstitial = [[GADInterstitial alloc] init];

    self.interstitial.adUnitID = [info objectForKey:@"adUnitID"];
    self.interstitial.delegate = self;

    NSString *npaPref = [[NSUserDefaults standardUserDefaults] stringForKey:@"npaPref"];
    GADRequest *request = [GADRequest request];
    
    if (npaPref != nil) {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{@"npa": npaPref};
        [request registerAdNetworkExtras:extras];
    }

    CLLocation *location = self.delegate.location;
    if (location) {
        [request setLocationWithLatitude:location.coordinate.latitude
                               longitude:location.coordinate.longitude
                                accuracy:location.horizontalAccuracy];
    }

    // Here, you can specify a list of device IDs that will receive test ads.
    // Running in the simulator will automatically show test ads.
    request.testDevices = @[/*more UDIDs here*/];

    request.requestAgent = @"MoPub";

    [self.interstitial loadRequest:request];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitial presentFromRootViewController:rootViewController];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
    [self resetNpaPref];
}

- (void)resetNpaPref {
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"npaPref"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    MPLogInfo(@"Google AdMob Interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
{
    MPLogInfo(@"Google AdMob Interstitial failed to load with error: %@", error.localizedDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    [self resetNpaPref];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial
{
    MPLogInfo(@"Google AdMob Interstitial will present");
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    MPLogInfo(@"Google AdMob Interstitial will dismiss");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    MPLogInfo(@"Google AdMob Interstitial did dismiss");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    MPLogInfo(@"Google AdMob Interstitial will leave application");
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
