//
//  PangleInterstitialCustomEvent.m
//  BUAdSDKDemo
//
//  Created by Pangle on 2018/10/25.
//  Copyright © 2018年 Pangle. All rights reserved.
//

#import "PangleInterstitialCustomEvent.h"
#import <BUAdSDK/BUAdSDK.h>
#import "BUDMopubNativeInterstitialVC.h"

@interface PangleInterstitialCustomEvent () <BUNativeAdDelegate,BUNativeExpresInterstitialAdDelegate,BUFullscreenVideoAdDelegate>
@property (nonatomic, strong) BUNativeAd *nativeInterstitialAd;
@property (nonatomic, strong) BUDMopubNativeInterstitialVC *nativeInterstitialVC;
@property (nonatomic, strong) BUNativeExpressInterstitialAd *expressInterstitialAd;
@property (strong, nonatomic) BUFullscreenVideoAd *fullScreenVideo;
@end

@implementation PangleInterstitialCustomEvent
- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    BOOL hasAdMarkup = adMarkup.length > 0;
    NSDictionary *ritDict;
    NSString *ritStr;
    if (adMarkup != nil) {
        ritDict = [BUAdSDKManager AdTypeWithAdMarkUp:adMarkup];
        ritStr = [ritDict objectForKey:@"adSlotID"];
    }else{
        ritStr = [info objectForKey:@"rit"];
        ritDict = [BUAdSDKManager AdTypeWithRit:ritStr];
    }
    BUAdSlotAdType adType = [[ritDict objectForKey:@"adSlotType"] integerValue];
    //showType: @"1" express AD   @"2" native AD
    NSInteger showType = [[ritDict objectForKey:@"showType"] integerValue];
    if (adType == BUAdSlotAdTypeInterstitial) {
        if (showType == 1) {
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
            self.nativeInterstitialVC = [[BUDMopubNativeInterstitialVC alloc] init];
        }
    }else if (adType == BUAdSlotAdTypeFullscreenVideo){
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
    // 0:Normal Interstitial 1:Express Interstitial 2:Normal Fullscreen
    NSInteger slotType = [[self.localExtras objectForKey:@"slotType"] integerValue];
    if (slotType == 1) {
        [self.expressInterstitialAd showAdFromRootViewController:rootViewController];
    }else {
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

#pragma mark BUDMopubNativeInterstitialVCDelegate
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
