//
//  AppLovinInterstitialCustomEvent.m
//
//
//  Created by Thomas So on 5/21/17.
//
//

#import "AppLovinInterstitialCustomEvent.h"
#import "MPError.h"
#import "MPLogging.h"

#if __has_include(<AppLovinSDK/AppLovinSDK.h>)
    #import <AppLovinSDK/AppLovinSDK.h>
#else
    #import "ALInterstitialAd.h"
#endif

// Convenience macro for checking if AppLovin SDK has support for zones
#define HAS_ZONES_SUPPORT(_SDK) [_SDK.adService respondsToSelector: @selector(loadNextAdForZoneIdentifier:andNotify:)]
#define DEFAULT_ZONE @""

@interface AppLovinInterstitialCustomEvent() <ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>

@property (nonatomic, strong) ALSdk *sdk;
@property (nonatomic, strong) ALInterstitialAd *interstitialAd;
@property (nonatomic,   copy) NSString *zoneIdentifier; // The zone identifier this instance of the custom event is loading for

@end

@implementation AppLovinInterstitialCustomEvent
static NSString *const kALMoPubMediationErrorDomain = @"com.applovin.sdk.mediation.mopub.errorDomain";

// A dictionary of Zone -> Queue of `ALAd`s to be shared by instances of the custom event.
// This prevents skipping of ads as this adapter will be re-created and preloaded
// on every ad load regardless if ad was actually displayed or not.
static NSMutableDictionary<NSString *, NSMutableArray<ALAd *> *> *ALGlobalInterstitialAds;
static NSObject *ALGlobalInterstitialAdsLock;

#pragma mark - Class Initialization

+ (void)initialize
{
    [super initialize];
    
    ALGlobalInterstitialAds = [NSMutableDictionary dictionary];
    ALGlobalInterstitialAdsLock = [[NSObject alloc] init];
}

#pragma mark - MPInterstitialCustomEvent Overridden Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    [self log: @"Requesting AppLovin interstitial with info: %@", info];
    
    self.sdk = [self SDKFromCustomEventInfo: info];
    [self.sdk setPluginVersion: @"MoPub-Certified-2.1.0"];
    
    // Zones support is available on AppLovin SDK 4.5.0 and higher
    if ( HAS_ZONES_SUPPORT(self.sdk) && info[@"zone_id"] )
    {
        self.zoneIdentifier = info[@"zone_id"];
    }
    else
    {
        self.zoneIdentifier = DEFAULT_ZONE;
    }
    
    // Check if we already have a preloaded ad for the given zone
    ALAd *preloadedAd = [[self class] dequeueAdForZoneIdentifier: self.zoneIdentifier];
    if ( preloadedAd )
    {
        [self log: @"Found preloaded ad for zone: {%@}", self.zoneIdentifier];
        [self adService: self.sdk.adService didLoadAd: preloadedAd];
    }
    // No ad currently preloaded
    else
    {
        // If this is a default Zone, create the incentivized ad normally
        if ( [DEFAULT_ZONE isEqualToString: self.zoneIdentifier] )
        {
            [self.sdk.adService loadNextAd: [ALAdSize sizeInterstitial] andNotify: self];
        }
        // Otherwise, use the Zones API
        else
        {
            // Dynamically load an ad for a given zone without breaking backwards compatibility for publishers on older SDKs
            [self.sdk.adService performSelector: @selector(loadNextAdForZoneIdentifier:andNotify:)
                                     withObject: self.zoneIdentifier
                                     withObject: self];
        }
    }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    ALAd *preloadedAd = [[self class] dequeueAdForZoneIdentifier: self.zoneIdentifier];
    if ( preloadedAd )
    {
        self.interstitialAd = [[ALInterstitialAd alloc] initWithSdk: self.sdk];
        self.interstitialAd.adDisplayDelegate = self;
        self.interstitialAd.adVideoPlaybackDelegate = self;
        [self.interstitialAd showOver: rootViewController.view.window andRender: preloadedAd];
    }
    else
    {
        [self log: @"Failed to show an AppLovin interstitial before one was loaded"];
        
        NSError *error = [NSError errorWithDomain: kALMoPubMediationErrorDomain
                                             code: kALErrorCodeUnableToRenderAd
                                         userInfo: @{NSLocalizedFailureReasonErrorKey : @"Adaptor requested to display an interstitial before one was loaded"}];
        
        [self.delegate interstitialCustomEvent: self didFailToLoadAdWithError: error];
    }
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    [self log: @"Interstitial did load ad: %@", ad.adIdNumber];
    
    [[self class] enqueueAd: ad forZoneIdentifier: self.zoneIdentifier];
    
    [self.delegate interstitialCustomEvent: self didLoadAd: ad];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    [self log: @"Interstitial failed to load with error: %d", code];
    
    NSError *error = [NSError errorWithDomain: kALMoPubMediationErrorDomain
                                         code: [self toMoPubErrorCode: code]
                                     userInfo: nil];
    [self.delegate interstitialCustomEvent: self didFailToLoadAdWithError: error];
}

#pragma mark - Ad Display Delegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
    [self log: @"Interstitial displayed"];
    
    [self.delegate interstitialCustomEventWillAppear: self];
    [self.delegate interstitialCustomEventDidAppear: self];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
    [self log: @"Interstitial dismissed"];
    
    [self.delegate interstitialCustomEventWillDisappear: self];
    [self.delegate interstitialCustomEventDidDisappear: self];
    
    self.interstitialAd = nil;
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view
{
    [self log: @"Interstitial clicked"];
    
    [self.delegate interstitialCustomEventDidReceiveTapEvent: self];
    [self.delegate interstitialCustomEventWillLeaveApplication: self];
}

#pragma mark - Video Playback Delegate

- (void)videoPlaybackBeganInAd:(ALAd *)ad
{
    [self log: @"Interstitial video playback began"];
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched
{
    [self log: @"Interstitial video playback ended at playback percent: %lu", percentPlayed.unsignedIntegerValue];
}

#pragma mark - Utility Methods

+ (alnullable ALAd *)dequeueAdForZoneIdentifier:(NSString *)zoneIdentifier
{
    @synchronized ( ALGlobalInterstitialAdsLock )
    {
        ALAd *preloadedAd;
        
        NSMutableArray<ALAd *> *preloadedAds = ALGlobalInterstitialAds[zoneIdentifier];
        if ( preloadedAds.count > 0 )
        {
            preloadedAd = preloadedAds[0];
            [preloadedAds removeObjectAtIndex: 0];
        }
        
        return preloadedAd;
    }
}

+ (void)enqueueAd:(ALAd *)ad forZoneIdentifier:(NSString *)zoneIdentifier
{
    @synchronized ( ALGlobalInterstitialAdsLock )
    {
        NSMutableArray<ALAd *> *preloadedAds = ALGlobalInterstitialAds[zoneIdentifier];
        if ( !preloadedAds )
        {
            preloadedAds = [NSMutableArray array];
            ALGlobalInterstitialAds[zoneIdentifier] = preloadedAds;
        }
        
        [preloadedAds addObject: ad];
    }
}

- (void)log:(NSString *)format, ...
{
    va_list valist;
    va_start(valist, format);
    NSString *message = [[NSString alloc] initWithFormat: format arguments: valist];
    va_end(valist);
    
    MPLogDebug(@"AppLovinInterstitialCustomEvent : %@", message);
}

- (MOPUBErrorCode)toMoPubErrorCode:(int)appLovinErrorCode
{
    if ( appLovinErrorCode == kALErrorCodeNoFill )
    {
        return MOPUBErrorAdapterHasNoInventory;
    }
    else if ( appLovinErrorCode == kALErrorCodeAdRequestNetworkTimeout )
    {
        return MOPUBErrorNetworkTimedOut;
    }
    else if ( appLovinErrorCode == kALErrorCodeInvalidResponse )
    {
        return MOPUBErrorServerError;
    }
    else
    {
        return MOPUBErrorUnknown;
    }
}

- (ALSdk *)SDKFromCustomEventInfo:(NSDictionary *)info
{
    NSString *SDKKey = info[@"sdk_key"];
    if ( SDKKey.length > 0 )
    {
        return [ALSdk sharedWithKey: SDKKey];
    }
    else
    {
        return [ALSdk shared];
    }
}

@end
