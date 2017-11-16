//
//  ChartboostInterstitialCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "ChartboostInterstitialCustomEvent.h"
#import "MPLogging.h"
#import "MPChartboostRouter.h"
#import "MPInstanceProvider+Chartboost.h"
#import <Chartboost/Chartboost.h>

static NSString *gAppId = nil;
static NSString *gAppSignature = nil;

#define kChartboostAppID        @"YOUR_CHARTBOOST_APP_ID"
#define kChartboostAppSignature @"YOUR_CHARTBOOST_APP_SIGNATURE"

@interface ChartboostInterstitialCustomEvent () <ChartboostDelegate>
@end

@implementation ChartboostInterstitialCustomEvent

+ (void)setAppId:(NSString *)appId
{
    MPLogWarn(@"+setAppId for class ChartboostInterstitialCustomEvent is deprecated. Use the appId parameter when configuring your network in the MoPub UI.");
    gAppId = [appId copy];
}

+ (void)setAppSignature:(NSString *)appSignature
{
    MPLogWarn(@"+setAppSignature for class ChartboostInterstitialCustomEvent is deprecated. Use the appSignature parameter when configuring your network in the MoPub UI.");
    gAppSignature = [appSignature copy];
}

- (void)invalidate
{
    [[MPChartboostRouter sharedRouter] unregisterInterstitialEvent:self];
    self.location = nil;
}

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    NSString *appId = [info objectForKey:@"appId"];
    if (!appId) {
        appId = gAppId;

        if ([appId length] == 0) {
            MPLogWarn(@"Setting kChartboostAppId in ChartboostInterstitialCustomEvent.m is deprecated. Use the appId parameter when configuring your network in the MoPub UI.");
            appId = kChartboostAppID;
        }
    }
    NSString *appSignature = [info objectForKey:@"appSignature"];
    if (!appSignature) {
        appSignature = gAppSignature;

        if ([appSignature length] == 0) {
            MPLogWarn(@"Setting kChartboostAppSignature in ChartboostInterstitialCustomEvent.m is deprecated. Use the appSignature parameter when configuring your network in the MoPub UI.");
            appSignature = kChartboostAppSignature;
        }
    }
    NSString *location = [info objectForKey:@"location"];
    self.location = location ? location : @"Default";

    MPLogInfo(@"Requesting Chartboost interstitial.");
    [[MPChartboostRouter sharedRouter] cacheInterstitialWithAppId:appId
                                                     appSignature:appSignature
                                                         location:self.location
                             forChartboostInterstitialCustomEvent:self];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if ([[MPChartboostRouter sharedRouter] hasCachedInterstitialForLocation:self.location]) {
        MPLogInfo(@"Chartboost interstitial will be shown.");

        [[MPChartboostRouter sharedRouter] showInterstitialForLocation:self.location];
    } else {
        MPLogInfo(@"Failed to show Chartboost interstitial.");

        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

#pragma mark - ChartboostDelegate

- (void)didCacheInterstitial:(CBLocation)location
{
    MPLogInfo(@"Successfully loaded Chartboost interstitial. Location: %@", location);

    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

- (void)didFailToLoadInterstitial:(CBLocation)location withError:(CBLoadError)error
{
    MPLogInfo(@"Failed to load Chartboost interstitial. Location: %@", location);

    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)didDismissInterstitial:(CBLocation)location
{
    MPLogInfo(@"Chartboost interstitial was dismissed. Location: %@", location);

    // Chartboost doesn't seem to have a separate callback for the "will disappear" event, so we
    // signal "will disappear" manually.

    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)didDisplayInterstitial:(CBLocation)location
{
    MPLogInfo(@"Chartboost interstitial was displayed. Location: %@", location);

    // Chartboost doesn't seem to have a separate callback for the "will appear" event, so we
    // signal "will appear" manually.

    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)didClickInterstitial:(CBLocation)location
{
    MPLogInfo(@"Chartboost interstitial was clicked. Location: %@", location);
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end
