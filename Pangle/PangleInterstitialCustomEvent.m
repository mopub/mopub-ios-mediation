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

@interface PangleInterstitialCustomEvent () <BUNativeAdDelegate,BUNativeExpresInterstitialAdDelegate,BUFullscreenVideoAdDelegate,PangleNativeInterstitialViewDelegate>
@property (nonatomic, strong) BUNativeAd *nativeInterstitialAd;
@property (nonatomic, strong) PangleNativeInterstitialView *nativeInterstitialVC;
@property (nonatomic, strong) BUNativeExpressInterstitialAd *expressInterstitialAd;
@property (nonatomic, strong) BUFullscreenVideoAd *fullScreenVideo;
@property (nonatomic, assign) BUAdSlotAdType adType;
@property (nonatomic, assign) NSInteger renderType;
@end

@implementation PangleInterstitialCustomEvent
- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    BOOL hasAdMarkup = adMarkup.length > 0;
    NSDictionary *ritDict;
    NSString * appId = [info objectForKey:@"app_id"];
    if (appId != nil){
        [PangleAdapterConfiguration updateInitializationParameters:info];
    }
    NSString *ritStr;
    ritStr = [info objectForKey:@"ad_placement_id"];
    if (ritStr == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey: @"Invalid Pangle placement ID"}];
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    ritDict = [BUAdSDKManager AdTypeWithRit:ritStr];
    
    self.adType = [[ritDict objectForKey:@"adSlotType"] integerValue];
    //renderType: @"1" express AD   @"2" native AD
    self.renderType = [[ritDict objectForKey:@"renderType"] integerValue];
    if (self.adType == BUAdSlotAdTypeInterstitial) {
        if (self.renderType == 1) {
            self.expressInterstitialAd = [[BUNativeExpressInterstitialAd alloc] initWithSlotID:ritStr adSize:CGSizeMake(300, 400)];
            self.expressInterstitialAd.delegate = self;
            if (hasAdMarkup) {
                [self.expressInterstitialAd setMopubAdMarkUp:adMarkup];
            }else{
                [self.expressInterstitialAd loadAdData];
            }
        }else{
            BUSize *imgSize1 = [[BUSize alloc] init];
            imgSize1.width = 1080;
            imgSize1.height = 1920;
            
            BUAdSlot *slot1 = [[BUAdSlot alloc] init];
            slot1.ID = ritStr;
            slot1.AdType = BUAdSlotAdTypeInterstitial;
            slot1.position = BUAdSlotPositionTop;
            slot1.imgSize = imgSize1;
            slot1.isSupportDeepLink = YES;
            slot1.isOriginAd = YES;
            
            BUNativeAd *nad = [[BUNativeAd alloc] initWithSlot:slot1];
            nad.delegate = self;
            self.nativeInterstitialAd = nad;
            if (hasAdMarkup) {
                [nad setMopubAdMarkUp:adMarkup];
            }else{
                [nad loadAdData];
            }
            self.nativeInterstitialVC = [[PangleNativeInterstitialView alloc] init];
        }
    }else if (self.adType == BUAdSlotAdTypeFullscreenVideo){
        self.fullScreenVideo = [[BUFullscreenVideoAd alloc] initWithSlotID:ritStr];
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
            [self.expressInterstitialAd showAdFromRootViewController:rootViewController];
        }else{
            [self.nativeInterstitialVC showAdFromRootViewController:rootViewController delegate:self];
        }
    }else if (self.adType == BUAdSlotAdTypeFullscreenVideo){
        [self.fullScreenVideo showAdFromRootViewController:rootViewController ritSceneDescribe:nil];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - BUNativeAdDelegate
- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd {
    [self.nativeInterstitialVC refreshUIWithAd:nativeAd];
    [self.delegate interstitialCustomEvent:self didLoadAd:self.nativeInterstitialAd];
}

- (void)nativeAd:(BUNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *)view
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    [self.delegate trackClick];
}

- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd
{
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate trackImpression];
    [self.delegate interstitialCustomEventDidAppear:self];
}

#pragma mark PangleNativeInterstitialViewDelegate
- (void)nativeInterstitialAdWillClose:(BUNativeAd *)nativeAd{
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)nativeInterstitialAdDidClose:(BUNativeAd *)nativeAd{
    [self.delegate interstitialCustomEventDidDisappear:self];
}

#pragma mark BUNativeExpresInterstitialAdDelegate
- (void)nativeExpresInterstitialAdDidLoad:(BUNativeExpressInterstitialAd *)interstitialAd {
}

- (void)nativeExpresInterstitialAd:(BUNativeExpressInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeExpresInterstitialAdRenderSuccess:(BUNativeExpressInterstitialAd *)interstitialAd {
    [self.delegate interstitialCustomEvent:self didLoadAd:interstitialAd];
}

- (void)nativeExpresInterstitialAdRenderFail:(BUNativeExpressInterstitialAd *)interstitialAd error:(NSError *)error {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeExpresInterstitialAdWillVisible:(BUNativeExpressInterstitialAd *)interstitialAd {
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate trackImpression];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)nativeExpresInterstitialAdDidClick:(BUNativeExpressInterstitialAd *)interstitialAd {
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    [self.delegate trackClick];
}

- (void)nativeExpresInterstitialAdWillClose:(BUNativeExpressInterstitialAd *)interstitialAd {
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)nativeExpresInterstitialAdDidClose:(BUNativeExpressInterstitialAd *)interstitialAd {
    [self.delegate interstitialCustomEventDidDisappear:self];
}

#pragma mark - BUFullscreenVideoAdDelegate
- (void)fullscreenVideoMaterialMetaAdDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate interstitialCustomEvent:self didLoadAd:fullscreenVideoAd];
}

- (void)fullscreenVideoAdVideoDataDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
}

- (void)fullscreenVideoAdWillVisible:(BUFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate trackImpression];
}

- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)fullscreenVideoAdDidClick:(BUFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    [self.delegate trackClick];
}

- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)fullscreenVideoAdDidPlayFinish:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
}

- (void)fullscreenVideoAdDidClickSkip:(BUFullscreenVideoAd *)fullscreenVideoAd {

}


@end
