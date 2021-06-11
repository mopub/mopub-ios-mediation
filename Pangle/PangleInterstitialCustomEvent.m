#import "PangleInterstitialCustomEvent.h"
#import <BUAdSDK/BUAdSDK.h>
#import "PangleAdapterConfiguration.h"
#if __has_include("MoPub.h")
    #import "MPError.h"
    #import "MPLogging.h"
    #import "MoPub.h"
#endif

@interface PangleInterstitialCustomEvent () <BUFullscreenVideoAdDelegate>
@property (nonatomic, strong) BUFullscreenVideoAd *fullScreenVideo;
@property (nonatomic, copy) NSString *adPlacementId;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, assign) BOOL adHasValid;
@end

@implementation PangleInterstitialCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return self.adHasValid;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    BOOL hasAdMarkup = adMarkup.length > 0;
    self.adHasValid = NO;
    
    if (info.count == 0) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey:
                                                        @"Incorrect or missing Pangle App ID or Placement ID on the network UI. Ensure the setting is correct on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError: error];
        return;
    }
    NSString *appId = [info objectForKey:kPangleAppIdKey];
    self.appId = appId;
    if (appId && [appId isKindOfClass:[NSString class]] && appId.length > 0) {
        [PangleAdapterConfiguration pangleSDKInitWithAppId:self.appId];
        [PangleAdapterConfiguration updateInitializationParameters:info];
    }
    
    NSString *adPlacementId = [info objectForKey:kPanglePlacementIdKey];
    self.adPlacementId = adPlacementId;
    if (!(adPlacementId && [adPlacementId isKindOfClass:[NSString class]] && adPlacementId.length > 0)) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey:
                                @"Incorrect or missing Pangle placement ID. Failing ad request. Ensure the ad placement ID is correct on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
        
    self.fullScreenVideo = [[BUFullscreenVideoAd alloc] initWithSlotID:self.adPlacementId];
    self.fullScreenVideo.delegate = self;
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
    
    if (hasAdMarkup) {
        MPLogInfo(@"Loading Pangle interstitial ad markup for Advanced Bidding");

        [self.fullScreenVideo setMopubAdMarkUp:adMarkup];
    } else {
        MPLogInfo(@"Loading Pangle interstitial ad");

        [self.fullScreenVideo loadAdData];
    }
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    if (!self.fullScreenVideo || !self.adHasValid) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeNERenderResultError
                                         userInfo:@{NSLocalizedDescriptionKey: @"Failed to show Pangle intersitial ad."}];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    } else {
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        
        [self.fullScreenVideo showAdFromRootViewController:viewController ritSceneDescribe:nil];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - BUFullscreenVideoAdDelegate - Full Screen Video

- (void)fullscreenVideoMaterialMetaAdDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    self.adHasValid = YES;
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)fullscreenVideoAdVideoDataDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    // no-op
}

- (void)fullscreenVideoAdWillVisible:(BUFullscreenVideoAd *)fullscreenVideoAd {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterAdWillPresent:self];
}

- (void)fullscreenVideoAdDidVisible:(BUFullscreenVideoAd *)fullscreenVideoAd{
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)fullscreenVideoAdWillClose:(BUFullscreenVideoAd *)fullscreenVideoAd{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

- (void)fullscreenVideoAdDidClick:(BUFullscreenVideoAd *)fullscreenVideoAd {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)fullscreenVideoAdDidPlayFinish:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    if (error) {
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    }
}

- (void)fullscreenVideoAdDidClickSkip:(BUFullscreenVideoAd *)fullscreenVideoAd {

}

- (NSString *) getAdNetworkId {
    NSString *adPlacementId = self.adPlacementId;
    return (adPlacementId && [adPlacementId isKindOfClass:[NSString class]]) ? adPlacementId : @"";
}

@end
