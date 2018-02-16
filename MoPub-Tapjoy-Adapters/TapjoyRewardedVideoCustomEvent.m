
#import "TapjoyRewardedVideoCustomEvent.h"
#import <Tapjoy/Tapjoy.h>
#import <Tapjoy/TJPlacement.h>
#import "MPRewardedVideoError.h"
#import "MPLogging.h"
#import "MPRewardedVideoReward.h"
#import "TapjoyGlobalMediationSettings.h"
#import "MoPub.h"
#import "MPRewardedVideoCustomEvent+Caching.h"

@interface TapjoyRewardedVideoCustomEvent () <TJPlacementDelegate, TJCVideoAdDelegate>
@property (nonatomic, strong) TJPlacement *placement;
@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, copy) NSString *placementName;
@end

@implementation TapjoyRewardedVideoCustomEvent

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
    //Instantiate Mediation Settings
    TapjoyGlobalMediationSettings *medSettings = [[MoPub sharedInstance] globalMediationSettingsForClass:[TapjoyGlobalMediationSettings class]];

    // Grab sdkKey and connect flags defined in MoPub dashboard
    NSString *sdkKey = info[@"sdkKey"];
    BOOL enableDebug = [info[@"debugEnabled"] boolValue];

    if (medSettings.sdkKey) {
        MPLogInfo(@"Connecting to Tapjoy via MoPub mediation settings");
        [self setupListeners];
        [Tapjoy connect:medSettings.sdkKey options:medSettings.connectFlags];

        self.isConnecting = YES;

    }
    else if (sdkKey) {
        MPLogInfo(@"Connecting to Tapjoy via MoPub dashboard settings");
        NSMutableDictionary *connectOptions = [[NSMutableDictionary alloc] init];
        [connectOptions setObject:@(enableDebug) forKey:TJC_OPTION_ENABLE_LOGGING];
        [self setupListeners];

        [Tapjoy connect:sdkKey options:connectOptions];

        self.isConnecting = YES;
    }
    else {
        MPLogInfo(@"Tapjoy rewarded video is initialized with empty 'sdkKey'. You must call Tapjoy connect before requesting content.");
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
    }
}

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    // Attempt to establish a connection to Tapjoy
    if (![Tapjoy isConnected]) {
        [self initializeWithCustomNetworkInfo:parameters];
    }
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info {
    // Grab placement name defined in MoPub dashboard as custom event data
    self.placementName = info[@"name"];

    // Cache network initialization info
    [self setCachedInitializationParameters:info];

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
        MPLogInfo(@"Requesting Tapjoy rewarded video");
        [self requestPlacementContent];
    }
}

- (void)requestPlacementContent {
    if (self.placementName) {
        self.placement = [TJPlacement placementWithName:self.placementName mediationAgent:@"mopub" mediationId:nil delegate:self];
        self.placement.adapterVersion = MP_SDK_VERSION;

        [self.placement requestContent];
    }
    else {
        MPLogInfo(@"Invalid Tapjoy placement name specified");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorInvalidCustomEvent userInfo:nil];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    if ([self hasAdAvailable]) {
        MPLogInfo(@"Tapjoy rewarded video will be shown");
        [self.placement showContentWithViewController:nil];
    }
    else {
        MPLogInfo(@"Failed to show Tapjoy rewarded video");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (BOOL)hasAdAvailable {
    return self.placement.isContentAvailable;
}

- (void)handleCustomEventInvalidated {
    self.placement.delegate = nil;
}

- (void)handleAdPlayedForCustomEventNetwork {
    // If we no longer have an ad available, report back up to the application that this ad expired.
    // We receive this message only when this ad has reported an ad has loaded and another ad unit
    // has played a video for the same ad network.
    if (![self hasAdAvailable]) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _placement.delegate = nil;
}

#pragma mark - TJPlacementDelegate methods

- (void)requestDidSucceed:(TJPlacement *)placement {
    if (!placement.isContentAvailable) {
        MPLogInfo(@"No Tapjoy rewarded videos available");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
}

- (void)contentIsReady:(TJPlacement *)placement {
    MPLogInfo(@"Tapjoy rewarded video content is ready");
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)requestDidFail:(TJPlacement *)placement error:(NSError *)error {
    MPLogInfo(@"Tapjoy rewarded video request failed");
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)contentDidAppear:(TJPlacement *)placement {
    MPLogInfo(@"Tapjoy rewarded video content did appear");
    [Tapjoy setVideoAdDelegate:self];
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)contentDidDisappear:(TJPlacement *)placement {
    MPLogInfo(@"Tapjoy rewarded video content did disappear");
    [Tapjoy setVideoAdDelegate:nil];
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

#pragma mark Tapjoy Video

- (void)videoAdCompleted {
    MPLogInfo(@"Tapjoy rewarded video completed");
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:[[MPRewardedVideoReward alloc] initWithCurrencyAmount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)]];
}

- (void)tjcConnectSuccess:(NSNotification*)notifyObj {
    MPLogInfo(@"Tapjoy connect Succeeded");
    self.isConnecting = NO;
    [self requestPlacementContent];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)tjcConnectFail:(NSNotification*)notifyObj {
    MPLogInfo(@"Tapjoy connect Failed");
    self.isConnecting = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
