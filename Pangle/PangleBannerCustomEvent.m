//
//  BUDMopub_BannerCustomEvent.m
//  BUAdSDKDemo
//
//  Created by bytedance_yuanhuan on 2018/10/24.
//  Copyright © 2018年 bytedance. All rights reserved.
//

#import "PangleBannerCustomEvent.h"
#import <BUAdSDK/BUAdSDK.h>
#import "BUDSlotID.h"

@interface PangleBannerCustomEvent ()<BUBannerAdViewDelegate>
@property (strong, nonatomic) BUBannerAdView *bannerView;
@end

@implementation PangleBannerCustomEvent
- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    BUSize *adSize = [[BUSize alloc] init];
    adSize.width = size.width;
    adSize.height = size.height;
    self.bannerView = [[BUBannerAdView alloc] initWithSlotID:normal_banner_ID size:adSize rootViewController:self.delegate.viewControllerForPresentingModalView];
    self.bannerView.frame = CGRectMake(0, 0, size.width, size.height);
    self.bannerView.delegate = self;
    [self.bannerView loadAdData];
}

#pragma mark - BUBannerAdViewDelegate
- (void)bannerAdViewDidLoad:(BUBannerAdView *)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)nativeAd {
    [self.delegate bannerCustomEvent:self didLoadAd:bannerAdView];
    
}

- (void)bannerAdView:(BUBannerAdView *)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
    
}

- (void)bannerAdViewDidBecomVisible:(BUBannerAdView *)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)nativeAd {
    [self.delegate trackImpression];
    
}

- (void)bannerAdViewDidClick:(BUBannerAdView *)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)nativeAd {
    [self.delegate bannerCustomEventWillBeginAction:self];
    [self.delegate trackClick];
    
}

- (void)bannerAdView:(BUBannerAdView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
    [bannerAdView removeFromSuperview];
    
}

- (void)bannerAdViewDidCloseOtherController:(BUBannerAdView *)bannerAdView interactionType:(BUInteractionType)interactionType {
    [self.delegate bannerCustomEventDidFinishAction:self];
    
}


@end
