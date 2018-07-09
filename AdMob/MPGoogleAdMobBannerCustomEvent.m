//
//  MPGoogleAdMobBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPGoogleAdMobBannerCustomEvent.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "MPGoogleAdMobBannerCustomEvent.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif

@interface MPGoogleAdMobBannerCustomEvent () <GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView *adBannerView;

@end


@implementation MPGoogleAdMobBannerCustomEvent

- (id)init
{
    self = [super init];
    if (self)
    {
        self.adBannerView = [[GADBannerView alloc] initWithFrame:CGRectZero];
        self.adBannerView.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.adBannerView.delegate = nil;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Google AdMob banner");
    self.adBannerView.frame = [self frameForCustomEventInfo:info];
    self.adBannerView.adUnitID = [info objectForKey:@"adUnitID"];
    self.adBannerView.rootViewController = [self.delegate viewControllerForPresentingModalView];

    GADRequest *request = [GADRequest request];

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

    // Consent collected from the MoPub’s consent dialogue should not be used to set up Google's personalization preference. Publishers should work with Google to be GDPR-compliant.
    
    MPGoogleGlobalMediationSettings *medSettings = [[MoPub sharedInstance] globalMediationSettingsForClass:[MPGoogleGlobalMediationSettings class]];
    
    if (medSettings.npa) {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{@"npa": medSettings.npa};
        [request registerAdNetworkExtras:extras];
    }
    
    [self.adBannerView loadRequest:request];
}

- (CGRect)frameForCustomEventInfo:(NSDictionary *)info
{
    CGFloat width = [[info objectForKey:@"adWidth"] floatValue];
    CGFloat height = [[info objectForKey:@"adHeight"] floatValue];

    if (width < GAD_SIZE_320x50.width && height < GAD_SIZE_320x50.height) {
        width = GAD_SIZE_320x50.width;
        height = GAD_SIZE_320x50.height;
    }
    return CGRectMake(0, 0, width, height);
}

#pragma mark -
#pragma mark GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    MPLogInfo(@"Google AdMob Banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:self.adBannerView];
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    MPLogInfo(@"Google AdMob Banner failed to load with error: %@", error.localizedDescription);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    MPLogInfo(@"Google AdMob Banner will present modal");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    MPLogInfo(@"Google AdMob Banner did dismiss modal");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    MPLogInfo(@"Google AdMob Banner will leave the application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

@end
