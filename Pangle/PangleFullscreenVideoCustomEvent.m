//
//  BUDMopub_FullscreenVideoCustomEvent.m
//  BUAdSDKDemo
//
//  Created by bytedance_yuanhuan on 2018/11/1.
//  Copyright © 2018年 bytedance. All rights reserved.
//

#import "PangleFullscreenVideoCustomEvent.h"
#import <BUAdSDK/BUFullscreenVideoAd.h>
//#import "BUDSlotID.h"

@interface PangleFullscreenVideoCustomEvent ()<BUFullscreenVideoAdDelegate>
@property (strong, nonatomic) BUFullscreenVideoAd *fullScreenVideo;
@end

@implementation PangleFullscreenVideoCustomEvent
- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.fullScreenVideo = [[BUFullscreenVideoAd alloc] initWithSlotID:@""];
    self.fullScreenVideo.delegate = self;
    [self.fullScreenVideo loadAdData];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    [self.fullScreenVideo showAdFromRootViewController:rootViewController ritSceneDescribe:nil];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
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

@synthesize description;

@synthesize hash;

@synthesize superclass;

@end
