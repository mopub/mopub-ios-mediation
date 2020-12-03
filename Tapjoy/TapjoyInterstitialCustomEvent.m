
#import "TapjoyInterstitialCustomEvent.h"
#import "TapjoyAdapterConfiguration.h"
#import <Tapjoy/TJPlacement.h>
#import <Tapjoy/Tapjoy.h>
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MoPub.h"
#endif

@interface TapjoyInterstitialCustomEvent () <TJPlacementDelegate>
@property (nonatomic, strong) TJPlacement *placement;
@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, copy) NSString *placementName;
@end

@implementation TapjoyInterstitialCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

- (void)setupListeners {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectSuccess:)
                                                 name:TJC_CONNECT_SUCCESS
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectFail:)
                                                 name:TJC_CONNECT_FAILED
                                               object:nil];
}

- (void)initializeWithCustomNetworkInfo:(NSDictionary *)info {
    // Grab sdkKey and connect flags defined in MoPub dashboard
    NSString *sdkKey = info[@"sdkKey"];
    BOOL enableDebug = [info[@"debugEnabled"] boolValue];

    if (sdkKey) {
        MPLogInfo(@"Connecting to Tapjoy via MoPub dashboard settings");
        NSMutableDictionary *connectOptions = [[NSMutableDictionary alloc] init];
        [connectOptions setObject:@(enableDebug) forKey:TJC_OPTION_ENABLE_LOGGING];
        [self setupListeners];
        
        [Tapjoy connect:sdkKey options:connectOptions];

        self.isConnecting = YES;
    }
    else {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"Tapjoy interstitial is initialized with empty 'sdkKey'. You must call Tapjoy connect before requesting content."];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.placementName);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    }
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return self.placement.isContentAvailable;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    // Grab placement name defined in MoPub dashboard as custom event data
    self.placementName = info[@"name"];
    
    // Cache network initialization info
    [TapjoyAdapterConfiguration updateInitializationParameters:info];

    // Adapter is making connect call on behalf of publisher, wait for success before requesting content.
    if (self.isConnecting) {
        return;
    }
    
    // Attempt to establish a connection to Tapjoy
    if (![Tapjoy isConnected]) {
        [self initializeWithCustomNetworkInfo:info];
    }
    // Live connection to Tapjoy already exists; request the ad
    else {
        MPLogInfo(@"Requesting Tapjoy interstitial");
        [self requestPlacementContentWithAdMarkup:adMarkup];
    }
}

- (void)requestPlacementContentWithAdMarkup:(NSString *)adMarkup {
    if (self.placementName != nil) {
        self.placement = [TJPlacement placementWithName:self.placementName mediationAgent:@"mopub" mediationId:nil delegate:self];
        self.placement.adapterVersion = MP_SDK_VERSION;
        
        // Advanced bidding response
        if (adMarkup != nil) {
            // Convert the JSON string into a dictionary.
            NSData * jsonData = [adMarkup dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary * auctionData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            if (auctionData != nil) {
                [self.placement setAuctionData:auctionData];
            }
        }

        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.placementName);
        [self.placement requestContent];
    }
    else {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"Invalid Tapjoy placement name specified"];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    }
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.placement showContentWithViewController:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _placement.delegate = nil;
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO; // Disabled so adapters have control over the impression and click tracking behavior
}

#pragma mark - TJPlacementtDelegate

- (void)requestDidSucceed:(TJPlacement *)placement {
    if (placement.isContentAvailable) {
        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.placementName);
        [self.delegate fullscreenAdAdapterDidLoadAd:self];
    }
    else {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"No Tapjoy interstitials available"];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.placementName);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    }
}

- (void)requestDidFail:(TJPlacement *)placement error:(NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.placementName);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)contentDidAppear:(TJPlacement *)placement {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.placementName);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)contentDidDisappear:(TJPlacement *)placement {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    
    // Signal that the fullscreen ad is closing and the state should be reset.
    // `fullscreenAdAdapterAdDidDismiss:` was introduced in MoPub SDK 5.15.0.
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    }
}

- (void)didClick:(TJPlacement*)placement
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)tjcConnectSuccess:(NSNotification*)notifyObj {
    MPLogInfo(@"Tapjoy connect Succeeded");
    self.isConnecting = NO;
    [self fetchMoPubGDPRSettings];
    [self requestPlacementContentWithAdMarkup:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)tjcConnectFail:(NSNotification*)notifyObj {
    MPLogInfo(@"Tapjoy connect Failed");
    self.isConnecting = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Collect latest MoPub GDPR settings and pass them to Tapjoy
-(void)fetchMoPubGDPRSettings {
    // If the GDPR applies setting is unknown, assume it has been skipped/unset
    MPBool gdprApplies = [MoPub sharedInstance].isGDPRApplicable;
    if (gdprApplies != MPBoolUnknown ) {
        //Turn the MPBool into a proper bool
        if(gdprApplies == MPBoolYes) {
            [[Tapjoy getPrivacyPolicy] setSubjectToGDPR:YES];
            
            NSString *consentString = [[MoPub sharedInstance] canCollectPersonalInfo] ? @"1" : @"0";
            [[Tapjoy getPrivacyPolicy] setUserConsent: consentString];
        } else {
            [[Tapjoy getPrivacyPolicy] setSubjectToGDPR:NO];
            [[Tapjoy getPrivacyPolicy] setUserConsent: @"-1"];
        }
    }
}

@end
