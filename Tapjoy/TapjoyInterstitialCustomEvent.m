
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
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
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
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.placement showContentWithViewController:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _placement.delegate = nil;
}

#pragma mark - TJPlacementtDelegate

- (void)requestDidSucceed:(TJPlacement *)placement {
    if (placement.isContentAvailable) {
        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.placementName);
        [self.delegate interstitialCustomEvent:self didLoadAd:nil];
    }
    else {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"No Tapjoy interstitials available"];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.placementName);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)requestDidFail:(TJPlacement *)placement error:(NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.placementName);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)contentDidAppear:(TJPlacement *)placement {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.delegate interstitialCustomEventWillAppear:self];
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.placementName);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)contentDidDisappear:(TJPlacement *)placement {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.delegate interstitialCustomEventWillDisappear:self];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)didClick:(TJPlacement*)placement
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.placementName);
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];  
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
            [Tapjoy subjectToGDPR:YES];
            
            NSString *consentString = [[MoPub sharedInstance] canCollectPersonalInfo] ? @"1" : @"0";
            [Tapjoy setUserConsent: consentString];
        } else {
            [Tapjoy subjectToGDPR:NO];
            [Tapjoy setUserConsent:@"-1"];
        }
    }
}

@end
