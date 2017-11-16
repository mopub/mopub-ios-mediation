//
//  MPChartboostRouter.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPChartboostRouter.h"
#import "MPLogging.h"
#import "MPInstanceProvider+Chartboost.h"
#import "ChartboostRewardedVideoCustomEvent.h"
#import "ChartboostInterstitialCustomEvent.h"

@interface ChartboostRewardedVideoCustomEvent (ChartboostRouter) <ChartboostDelegate>
@end

@interface ChartboostInterstitialCustomEvent (ChartboostRouter) <ChartboostDelegate>
@end

/*
 * Chartboost only provides a shared instance, so only one object may be the Chartboost delegate at
 * any given time. However, because it is common to request Chartboost interstitials for separate
 * "locations" in a single app session, we may have multiple instances of our custom event class,
 * all of which are interested in delegate callbacks.
 *
 * MPChartboostRouter is a singleton that is always the Chartboost delegate, and dispatches
 * events to all of the custom event instances.
 */

@implementation MPChartboostRouter

+ (MPChartboostRouter *)sharedRouter
{
    return [[MPInstanceProvider sharedProvider] sharedMPChartboostRouter];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.interstitialEvents = [NSMutableDictionary dictionary];
        self.rewardedVideoEvents = [NSMutableDictionary dictionary];

        /*
         * We need the active locations set to keep track of locations that are currently being
         * cached/ready to show/visible on screen for interstitial ads.
         * It is *not* enough to just use the events dictionary.  The reason is that when a user
         * taps a Chartboost interstitial.  Chartboost calls didDismissInterstitial *before* it calls
         * didClickInterstitial.  Since we *must* mark the location as available for reuse when
         * the interstitial is dismissed (e.g. the user simply closes it) the only way to allow
         * for click tracking, is to ensure that the event is still available after dismissal, but
         * is marked as free to be released.
         */
        self.activeInterstitialLocations = [NSMutableSet set];
    }
    return self;
}

- (void)startWithAppId:(NSString *)appId appSignature:(NSString *)appSignature
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [Chartboost startWithAppId:appId appSignature:appSignature delegate:self];
        [Chartboost setMediation:CBMediationMoPub withVersion:MP_SDK_VERSION];
    });
}

#pragma mark - Insterstitial Ads

- (void)cacheInterstitialWithAppId:(NSString *)appId appSignature:(NSString *)appSignature location:(NSString *)location forChartboostInterstitialCustomEvent:(ChartboostInterstitialCustomEvent *)event
{
    if ([self.activeInterstitialLocations containsObject:location]) {
        MPLogInfo(@"Failed to load Chartboost interstitial: this location is already in use.");
        [event didFailToLoadInterstitial:location withError:CBLoadErrorInternal];
        return;
    }

    if ([appId length] > 0 && [appSignature length] > 0) {
        [self setInterstitialEvent:event forLocation:location];

        [self startWithAppId:appId appSignature:appSignature];

        if ([self hasCachedInterstitialForLocation:location]) {
            [self didCacheInterstitial:location];
        } else {
            [Chartboost cacheInterstitial:location];
        }
    } else {
        MPLogInfo(@"Failed to load Chartboost interstitial: missing either appId or appSignature.");
        [event didFailToLoadInterstitial:location withError:CBLoadErrorInternal];
    }
}

- (BOOL)hasCachedInterstitialForLocation:(NSString *)location
{
    return [Chartboost hasInterstitial:location];
}

- (void)showInterstitialForLocation:(NSString *)location
{
    [Chartboost showInterstitial:location];
}

- (ChartboostInterstitialCustomEvent *)interstitialEventForLocation:(NSString *)location
{
    return [self.interstitialEvents objectForKey:location];
}

- (void)setInterstitialEvent:(ChartboostInterstitialCustomEvent *)event forLocation:(NSString *)location
{
    [self.interstitialEvents setObject:event forKey:location];
    [self.activeInterstitialLocations addObject:location];
}

- (void)unregisterInterstitialEventForLocation:(NSString *)location
{
    [self.activeInterstitialLocations removeObject:location];
}

- (void)unregisterInterstitialEvent:(ChartboostInterstitialCustomEvent *)event
{
    if ([[self.interstitialEvents objectForKey:event.location] isEqual:event]) {
        [self unregisterInterstitialEventForLocation:event.location];
    }
}

#pragma mark - Rewarded Video Ads

- (void)cacheRewardedAdWithAppId:(NSString *)appId appSignature:(NSString *)appSignature location:(NSString *)location forChartboostRewardedVideoCustomEvent:(ChartboostRewardedVideoCustomEvent *)event
{
    if ([appId length] > 0 && [appSignature length] > 0) {
        [self setRewardedVideoEvent:event forLocation:location];

        [self startWithAppId:appId appSignature:appSignature];

        if ([self hasCachedRewardedVideoForLocation:location]) {
            [self didCacheRewardedVideo:location];
        } else {
            [Chartboost cacheRewardedVideo:location];
        }
    } else {
        MPLogInfo(@"Failed to load Chartboost rewarded video: missing either appId or appSignature.");
        [event didFailToLoadRewardedVideo:location withError:CBLoadErrorInternal];
    }
}

- (BOOL)hasCachedRewardedVideoForLocation:(NSString *)location
{
    return [Chartboost hasRewardedVideo:location];
}

- (void)showRewardedVideoForLocation:(NSString *)location
{
    if ([self hasCachedRewardedVideoForLocation:location]) {
        [Chartboost showRewardedVideo:location];
    }
}

- (ChartboostRewardedVideoCustomEvent *)rewardedVideoEventForLocation:(NSString *)location
{
    return [self.rewardedVideoEvents objectForKey:location];
}

- (void)setRewardedVideoEvent:(ChartboostRewardedVideoCustomEvent *)event forLocation:(NSString *)location
{
    [self.rewardedVideoEvents setObject:event forKey:location];
}


#pragma mark - ChartboostDelegate Interstitial methods

- (void)didCacheInterstitial:(NSString *)location
{
    [[self interstitialEventForLocation:location] didCacheInterstitial:location];
}

- (void)didFailToLoadInterstitial:(NSString *)location withError:(CBLoadError)error
{
    [[self interstitialEventForLocation:location] didFailToLoadInterstitial:location withError:CBLoadErrorInternal];
    [self unregisterInterstitialEventForLocation:location];
}

- (void)didDisplayInterstitial:(NSString *)location
{
    [[self interstitialEventForLocation:location] didDisplayInterstitial:location];
}

- (void)didDismissInterstitial:(NSString *)location
{
    [[self interstitialEventForLocation:location] didDismissInterstitial:location];
    [self unregisterInterstitialEventForLocation:location];
}

- (void)didClickInterstitial:(NSString *)location
{
    [[self interstitialEventForLocation:location] didClickInterstitial:location];
}

#pragma mark - ChartboostDelegate Rewarded Video methods

- (BOOL)shouldDisplayRewardedVideo:(CBLocation)location
{
    return YES;
}

- (void)didDisplayRewardedVideo:(CBLocation)location
{
    [[self rewardedVideoEventForLocation:location] didDisplayRewardedVideo:location];
}

- (void)didCacheRewardedVideo:(CBLocation)location
{
    [[self rewardedVideoEventForLocation:location] didCacheRewardedVideo:location];
}

- (void)didFailToLoadRewardedVideo:(CBLocation)location withError:(CBLoadError)error
{
    [[self rewardedVideoEventForLocation:location] didFailToLoadRewardedVideo:location withError:CBLoadErrorInternal];
}

- (void)didCloseRewardedVideo:(CBLocation)location
{
    [[self rewardedVideoEventForLocation:location] didCloseRewardedVideo:location];
    [self.rewardedVideoEvents removeObjectForKey:location];
}

- (void)didClickRewardedVideo:(CBLocation)location
{
    [[self rewardedVideoEventForLocation:location] didClickRewardedVideo:location];
}

- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward
{
    [[self rewardedVideoEventForLocation:location] didCompleteRewardedVideo:location withReward:reward];
}

@end
