//
//  AppLovinRewardedVideoCustomEvent.m
//
//
//  Created by Thomas So on 5/21/17.
//
//

#import "AppLovinRewardedVideoCustomEvent.h"

#if __has_include("MoPub.h")
    #import "MPRewardedVideoReward.h"
    #import "MPError.h"
    #import "MPLogging.h"
    #import "MoPub.h"
#endif

#if __has_include(<AppLovinSDK/AppLovinSDK.h>)
    #import <AppLovinSDK/AppLovinSDK.h>
#else
    #import "ALIncentivizedInterstitialAd.h"
    #import "ALPrivacySettings.h"
#endif

#define DEFAULT_ZONE @""
#define DEFAULT_TOKEN_ZONE @"token"
#define ZONE_FROM_INFO(__INFO) ( ([__INFO[@"zone_id"] isKindOfClass: [NSString class]] && ((NSString *) __INFO[@"zone_id"]).length > 0) ? __INFO[@"zone_id"] : @"" )

// This class implementation with the old classname is left here for backwards compatibility purposes.
@implementation AppLovinRewardedCustomEvent
@end

@interface AppLovinRewardedVideoCustomEvent() <ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate, ALAdRewardDelegate>

@property (nonatomic, strong) ALSdk *sdk;
@property (nonatomic, strong) ALIncentivizedInterstitialAd *incent;

@property (nonatomic, assign) BOOL fullyWatched;
@property (nonatomic, strong) MPRewardedVideoReward *reward;
@property (nonatomic, assign, getter=isTokenEvent) BOOL tokenEvent;
@property (nonatomic, strong) ALAd *tokenAd;

@end

@implementation AppLovinRewardedVideoCustomEvent

static const BOOL kALLoggingEnabled = YES;
static NSString *const kALMoPubMediationErrorDomain = @"com.applovin.sdk.mediation.mopub.errorDomain";

// A dictionary of Zone -> `ALIncentivizedInterstitialAd` to be shared by instances of the custom event.
// This prevents skipping of ads as this adapter will be re-created and preloaded (along with underlying `ALIncentivizedInterstitialAd`)
// on every ad load regardless if ad was actually displayed or not.
static NSMutableDictionary<NSString *, ALIncentivizedInterstitialAd *> *ALGlobalIncentivizedInterstitialAds;

#pragma mark - Class Initialization

+ (void)initialize
{
    [super initialize];
    
    ALGlobalIncentivizedInterstitialAds = [NSMutableDictionary dictionary];
}

#pragma mark - MPRewardedVideoCustomEvent Overridden Methods

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    [self requestRewardedVideoWithCustomEventInfo: info adMarkup: nil];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    // Collect and pass the user's consent from MoPub into the AppLovin SDK
    if ( [[MoPub sharedInstance] isGDPRApplicable] == MPBoolYes )
    {
        BOOL canCollectPersonalInfo = [[MoPub sharedInstance] canCollectPersonalInfo];
        [ALPrivacySettings setHasUserConsent: canCollectPersonalInfo];
    }
    
    self.sdk = [self SDKFromCustomEventInfo: info];
    [self.sdk setPluginVersion: @"MoPub-3.1.0"];
    self.sdk.mediationProvider = ALMediationProviderMoPub;
    
    
    BOOL hasAdMarkup = adMarkup.length > 0;
    
    [self log: @"Requesting AppLovin rewarded video with info: %@ and has ad markup: %d", info, hasAdMarkup];
    
    // Determine zone
    NSString *zoneIdentifier;
    if ( hasAdMarkup )
    {
        zoneIdentifier = DEFAULT_TOKEN_ZONE;
    }
    else
    {
        zoneIdentifier = ZONE_FROM_INFO(info);
    }
    
    // Create incentivized ad based off of zone
    self.incent = [[self class] incentivizedInterstitialAdForZoneIdentifier: zoneIdentifier
                                                                customEvent: self
                                                                        sdk: self.sdk];
    
    // Use token API
    if ( hasAdMarkup )
    {
        self.tokenEvent = YES;
        
        [self.sdk.adService loadNextAdForAdToken: adMarkup andNotify: self];
    }
    // Zone/regular ad load
    else
    {
        [self.incent preloadAndNotify: self];
    }
}

- (BOOL)hasAdAvailable
{
    if ( [self isTokenEvent] )
    {
        return self.tokenAd != nil;
    }
    else
    {
        return self.incent.readyForDisplay;
    }
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ( [self hasAdAvailable] )
    {
        self.reward = nil;
        self.fullyWatched = NO;
        
        if ( [self isTokenEvent] )
        {
            [self.incent showOver: [UIApplication sharedApplication].keyWindow
                         renderAd: self.tokenAd
                        andNotify: self];
        }
        else
        {
            [self.incent showAndNotify: self];
        }
    }
    else
    {
        [self log: @"Failed to show an AppLovin rewarded video before one was loaded"];
        
        NSError *error = [NSError errorWithDomain: kALMoPubMediationErrorDomain
                                             code: kALErrorCodeUnableToRenderAd
                                         userInfo: @{NSLocalizedFailureReasonErrorKey : @"Adapter requested to display a rewarded video before one was loaded"}];
        
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent: self error: error];
    }
}

- (void)handleCustomEventInvalidated { }
- (void)handleAdPlayedForCustomEventNetwork { }

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    [self log: @"Rewarded video did load ad: %@", ad.adIdNumber];
    
    if ( [self isTokenEvent] )
    {
        self.tokenAd = ad;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate rewardedVideoDidLoadAdForCustomEvent: self];
    });
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    [self log: @"Rewarded video failed to load with error: %d", code];
    
    NSError *error = [NSError errorWithDomain: kALMoPubMediationErrorDomain
                                         code: [self toMoPubErrorCode: code]
                                     userInfo: nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent: self error: error];
    });
}

#pragma mark - Ad Display Delegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
    [self log: @"Rewarded video displayed"];
    
    [self.delegate rewardedVideoWillAppearForCustomEvent: self];
    [self.delegate rewardedVideoDidAppearForCustomEvent: self];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
    [self log: @"Rewarded video dismissed"];
    
    if ( self.fullyWatched && self.reward )
    {
        [self.delegate rewardedVideoShouldRewardUserForCustomEvent: self reward: self.reward];
    }
    
    [self.delegate rewardedVideoWillDisappearForCustomEvent: self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent: self];
    
    self.incent = nil;
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view
{
    [self log: @"Rewarded video clicked"];
    
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent: self];
    [self.delegate rewardedVideoWillLeaveApplicationForCustomEvent: self];
}

#pragma mark - Video Playback Delegate

- (void)videoPlaybackBeganInAd:(ALAd *)ad
{
    [self log: @"Rewarded video video playback began"];
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched
{
    [self log: @"Rewarded video video playback ended at playback percent: %lu", percentPlayed.unsignedIntegerValue];
    
    self.fullyWatched = wasFullyWatched;
}

#pragma mark - Reward Delegate

- (void)rewardValidationRequestForAd:(ALAd *)ad didExceedQuotaWithResponse:(NSDictionary *)response
{
    [self log: @"Rewarded video validation request for ad did exceed quota with response: %@", response];
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode
{
    [self log: @"Rewarded video validation request for ad failed with error code: %ld", responseCode];
}

- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response
{
    [self log: @"Rewarded video validation request was rejected with response: %@", response];
}

- (void)userDeclinedToViewAd:(ALAd *)ad
{
    [self log: @"User declined to view rewarded video"];
    
    [self.delegate rewardedVideoWillDisappearForCustomEvent: self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent: self];
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response
{
    NSNumber *amount = response[@"amount"];
    NSString *currency = response[@"currency"];
    
    [self log: @"Rewarded %@ %@", amount, currency];
    
    self.reward = [[MPRewardedVideoReward alloc] initWithCurrencyType: currency amount: amount];
}

#pragma mark - Utility Methods

- (void)log:(NSString *)format, ...
{
    if ( kALLoggingEnabled )
    {
        va_list valist;
        va_start(valist, format);
        NSString *message = [[NSString alloc] initWithFormat: format arguments: valist];
        va_end(valist);
        
        NSLog(@"AppLovinRewardedVideoCustomEvent: %@", message);
    }
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

+ (ALIncentivizedInterstitialAd *)incentivizedInterstitialAdForZoneIdentifier:(NSString *)zoneIdentifier
                                                                  customEvent:(AppLovinRewardedVideoCustomEvent *)customEvent
                                                                          sdk:(ALSdk *)sdk
{
    ALIncentivizedInterstitialAd *incent;
    
    // Check if incentivized ad for zone already exists
    if ( ALGlobalIncentivizedInterstitialAds[zoneIdentifier] )
    {
        incent = ALGlobalIncentivizedInterstitialAds[zoneIdentifier];
    }
    else
    {
        // If this is a default or token Zone, create the incentivized ad normally
        if ( [DEFAULT_ZONE isEqualToString: zoneIdentifier] || [DEFAULT_TOKEN_ZONE isEqualToString: zoneIdentifier] )
        {
            incent = [[ALIncentivizedInterstitialAd alloc] initWithSdk: sdk];
        }
        // Otherwise, use the Zones API
        else
        {
            incent = [[ALIncentivizedInterstitialAd alloc] initWithZoneIdentifier: zoneIdentifier sdk: sdk];
        }
        
        ALGlobalIncentivizedInterstitialAds[zoneIdentifier] = incent;
    }
    
    incent.adVideoPlaybackDelegate = customEvent;
    incent.adDisplayDelegate = customEvent;
    
    return incent;
}

@end
