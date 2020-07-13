#import "PangleInterstitialCustomEvent.h"
#import <BUAdSDK/BUAdSDK.h>
#import "PangleAdapterConfiguration.h"
#if __has_include("MoPub.h")
    #import "MPError.h"
    #import "MPLogging.h"
    #import "MoPub.h"
#endif

@interface PangleInterstitialCustomEvent () <BUNativeAdDelegate, BUNativeExpresInterstitialAdDelegate, BUFullscreenVideoAdDelegate, PangleNativeInterstitialViewDelegate>
@property (nonatomic, strong) BUFullscreenVideoAd *fullScreenVideo;
@property (nonatomic, assign) BUAdSlotAdType adType;
@property (nonatomic, copy) NSString *adPlacementId;
@property (nonatomic, copy) NSString *appId;
@end

@implementation PangleInterstitialCustomEvent

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return self.fullScreenVideo.adValid;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSDictionary *renderInfo;
    
    if (info.count == 0) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey:
                                                        @"Incorrect or missing Pangle App ID or Placement ID on the network UI. Ensure the setting is correct on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError: error];
        return;
    }
    
    self.appId = [info objectForKey:kPangleAppIdKey];
    if (BUCheckValidString(self.appId)) {
        [PangleAdapterConfiguration updateInitializationParameters:info];
    }
    
    self.adPlacementId = [info objectForKey:kPanglePlacementIdKey];
    if (!BUCheckValidString(self.adPlacementId)) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey:
                                @"Incorrect or missing Pangle placement ID. Failing ad request. Ensure the ad placement ID is correct on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    NSError *error = nil;
    renderInfo = [BUAdSDKManager AdTypeWithRit:self.adPlacementId error:&error];
    if (error) {
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.adType = [[renderInfo objectForKey:@"adSlotType"] integerValue];
    if ([[renderInfo objectForKey:@"adSlotType"] integerValue] != BUAdSlotAdTypeFullscreenVideo){
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey:
                                @"Mismatched Pangle placement ID. Please make sure the ad placement ID corresponds to Full Screen Video format in Pangle UI"}];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.fullScreenVideo = [[BUFullscreenVideoAd alloc] initWithSlotID:self.adPlacementId];
    self.fullScreenVideo.delegate = self;
    MPLogInfo(@"Load Pangle interstitial ad");
    [self.fullScreenVideo loadAdData];
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    if (!self.fullScreenVideo || !self.fullScreenVideo.adValid) {
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

- (void)updateAppId{
    [BUAdSDKManager setAppID:self.appId];
}

#pragma mark - BUFullscreenVideoAdDelegate - Full Screen Video

- (void)fullscreenVideoMaterialMetaAdDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)fullscreenVideoAdVideoDataDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    // no-op
}

- (void)fullscreenVideoAdWillVisible:(BUFullscreenVideoAd *)fullscreenVideoAd {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
}

- (void)fullscreenVideoAdDidVisible:(BUFullscreenVideoAd *)fullscreenVideoAd{
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)fullscreenVideoAdWillClose:(BUFullscreenVideoAd *)fullscreenVideoAd{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
}

- (void)fullscreenVideoAdDidClick:(BUFullscreenVideoAd *)fullscreenVideoAd {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    if (BUCheckValidString(self.appId) && error.code == BUUnionAppSiteRelError) {
        [self updateAppId];
    }
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
    return (BUCheckValidString(self.adPlacementId)) ? self.adPlacementId : @"";
}

@end