//
//  PangleInterstitialCustomEvent.m
//  BUAdSDKDemo
//
//  Created by Pangle on 2018/10/25.
//  Copyright © 2018年 Pangle. All rights reserved.
//

#import "PangleInterstitialCustomEvent.h"
#import <BUAdSDK/BUAdSDK.h>
#import "PangleNativeInterstitialView.h"
#import "PangleAdapterConfiguration.h"
#if __has_include("MoPub.h")
    #import "MPError.h"
    #import "MPLogging.h"
    #import "MoPub.h"
#endif

@interface PangleInterstitialCustomEvent () <BUNativeAdDelegate,BUNativeExpresInterstitialAdDelegate,BUFullscreenVideoAdDelegate,PangleNativeInterstitialViewDelegate>
@property (nonatomic, strong) BUNativeAd *nativeInterstitialAd;
@property (nonatomic, strong) PangleNativeInterstitialView *nativeInterstitialView;
@property (nonatomic, strong) BUNativeExpressInterstitialAd *expressInterstitialAd;
@property (nonatomic, strong) BUFullscreenVideoAd *fullScreenVideo;
@property (nonatomic, assign) BUAdSlotAdType adType;
@property (nonatomic, assign) NSInteger renderType;
@property (nonatomic, copy) NSString *adPlacementId;
@end

@implementation PangleInterstitialCustomEvent
- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    BOOL hasAdMarkup = adMarkup.length > 0;
    NSDictionary *ritDict;
    NSString * appId = [info objectForKey:@"app_id"];
    if (appId != nil){
        [PangleAdapterConfiguration updateInitializationParameters:info];
    }
    self.adPlacementId = [info objectForKey:@"ad_placement_id"];
    if (self.adPlacementId == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey: @"Invalid Pangle placement ID. Failing ad request. Ensure the ad placement id is valid on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    ritDict = [BUAdSDKManager AdTypeWithRit:self.adPlacementId];
    
    self.adType = [[ritDict objectForKey:@"adSlotType"] integerValue];
    //renderType: @"1" express AD   @"2" native AD
    self.renderType = [[ritDict objectForKey:@"renderType"] integerValue];
    if (self.adType == BUAdSlotAdTypeInterstitial) {
        if (self.renderType == 1) {
            NSInteger width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            self.expressInterstitialAd = [[BUNativeExpressInterstitialAd alloc] initWithSlotID:self.adPlacementId adSize:CGSizeMake(width, 0)];
            self.expressInterstitialAd.delegate = self;
            if (hasAdMarkup) {
                [self.expressInterstitialAd setMopubAdMarkUp:adMarkup];
            }else{
                [self.expressInterstitialAd loadAdData];
            }
        }else{
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            CGFloat ratio;
            if (screenSize.height > screenSize.width) {
                ratio = 3 / 2;
            }else{
                ratio = 2 / 3;
            }
            BUSize *imgSize1 = [[BUSize alloc] init];
            imgSize1.width = [UIScreen mainScreen].bounds.size.width;
            imgSize1.height = imgSize1.width * ratio;
            BUAdSlot *slot1 = [[BUAdSlot alloc] init];
            slot1.ID = self.adPlacementId;
            slot1.AdType = BUAdSlotAdTypeInterstitial;
            slot1.position = BUAdSlotPositionTop;
            slot1.imgSize = imgSize1;
            slot1.isSupportDeepLink = YES;
            slot1.isOriginAd = YES;
            
            self.nativeInterstitialView = [[PangleNativeInterstitialView alloc] init];

            BUNativeAd *nad = [[BUNativeAd alloc] initWithSlot:slot1];
            nad.delegate = self;
            self.nativeInterstitialAd = nad;
            if (hasAdMarkup) {
                [nad setMopubAdMarkUp:adMarkup];
            }else{
                [nad loadAdData];
            }
        }
    }else if (self.adType == BUAdSlotAdTypeFullscreenVideo){
        self.fullScreenVideo = [[BUFullscreenVideoAd alloc] initWithSlotID:self.adPlacementId];
        self.fullScreenVideo.delegate = self;
        if (hasAdMarkup) {
            [self.fullScreenVideo setMopubAdMarkUp:adMarkup];
        }else{
            [self.fullScreenVideo loadAdData];
        }
    }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    //renderType: @"1" express AD   @"2" native AD
    if (self.adType == BUAdSlotAdTypeInterstitial) {
        if (self.renderType == 1) {
            MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            [self.expressInterstitialAd showAdFromRootViewController:rootViewController];
        } else {
            MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            [self.nativeInterstitialView showAdFromRootViewController:rootViewController delegate:self];
        }
    } else if (self.adType == BUAdSlotAdTypeFullscreenVideo){
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        [self.fullScreenVideo showAdFromRootViewController:rootViewController ritSceneDescribe:nil];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - BUNativeAdDelegate
- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd {
    [self.nativeInterstitialView refreshUIWithAd:nativeAd];
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEvent:self didLoadAd:self.nativeInterstitialAd];
}

- (void)nativeAd:(BUNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *)view
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    [self.delegate trackClick];
}

- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd
{
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate trackImpression];
    [self.delegate interstitialCustomEventDidAppear:self];
}

#pragma mark PangleNativeInterstitialViewDelegate
- (void)nativeInterstitialAdWillClose:(BUNativeAd *)nativeAd{
    [self.delegate interstitialCustomEventWillDisappear:self];
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)nativeInterstitialAdDidClose:(BUNativeAd *)nativeAd{
    [self.delegate interstitialCustomEventDidDisappear:self];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

#pragma mark BUNativeExpresInterstitialAdDelegate
- (void)nativeExpresInterstitialAdDidLoad:(BUNativeExpressInterstitialAd *)interstitialAd {
}

- (void)nativeExpresInterstitialAd:(BUNativeExpressInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeExpresInterstitialAdRenderSuccess:(BUNativeExpressInterstitialAd *)interstitialAd {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEvent:self didLoadAd:interstitialAd];
}

- (void)nativeExpresInterstitialAdRenderFail:(BUNativeExpressInterstitialAd *)interstitialAd error:(NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeExpresInterstitialAdWillVisible:(BUNativeExpressInterstitialAd *)interstitialAd {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate trackImpression];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)nativeExpresInterstitialAdDidClick:(BUNativeExpressInterstitialAd *)interstitialAd {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    [self.delegate trackClick];
}

- (void)nativeExpresInterstitialAdWillClose:(BUNativeExpressInterstitialAd *)interstitialAd {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)nativeExpresInterstitialAdDidClose:(BUNativeExpressInterstitialAd *)interstitialAd {
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidDisappear:self];
}

#pragma mark - BUFullscreenVideoAdDelegate
- (void)fullscreenVideoMaterialMetaAdDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEvent:self didLoadAd:fullscreenVideoAd];
}

- (void)fullscreenVideoAdVideoDataDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
}

- (void)fullscreenVideoAdWillVisible:(BUFullscreenVideoAd *)fullscreenVideoAd {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate trackImpression];
}

- (void)fullscreenVideoAdDidVisible:(BUFullscreenVideoAd *)fullscreenVideoAd{
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)fullscreenVideoAdWillClose:(BUFullscreenVideoAd *)fullscreenVideoAd{
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)fullscreenVideoAdDidClick:(BUFullscreenVideoAd *)fullscreenVideoAd {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    [self.delegate trackClick];
}

- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)fullscreenVideoAdDidPlayFinish:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
}

- (void)fullscreenVideoAdDidClickSkip:(BUFullscreenVideoAd *)fullscreenVideoAd {

}

- (NSString *) getAdNetworkId {
    return (self.adPlacementId != nil) ? self.adPlacementId : @"";
}

@end
