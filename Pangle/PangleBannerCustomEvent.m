//
//  PangleBannerCustomEvent.m
//  BUAdSDKDemo
//
//  Created by Pangle on 2018/10/24.
//  Copyright © 2018年 Pangle. All rights reserved.
//

#import "PangleBannerCustomEvent.h"
#import <BUAdSDK/BUAdSDK.h>
#import "PangleNativeBannerView.h"

@interface PangleBannerCustomEvent ()<BUNativeExpressBannerViewDelegate,BUNativeAdDelegate>
@property (nonatomic, strong) BUNativeExpressBannerView *expressBannerView;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) PangleNativeBannerView *nativeBannerView;
@end

@implementation PangleBannerCustomEvent
- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
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
    //showType: @"1" express AD   @"2" native AD
    NSInteger showType = [[ritDict objectForKey:@"showType"] integerValue];

    BUSize *adSize = [[BUSize alloc] init];
    adSize.width = size.width;
    adSize.height = size.height;
    if (showType == 1) {
        self.expressBannerView = [[BUNativeExpressBannerView alloc] initWithSlotID:ritStr rootViewController:self.delegate.viewControllerForPresentingModalView adSize:size IsSupportDeepLink:YES];
        self.expressBannerView.frame = CGRectMake(0, 0, size.width, size.height);
        self.expressBannerView.delegate = self;
        if (hasAdMarkup) {
            [self.expressBannerView setMopubAdMarkUp:adMarkup];
        }else{
            [self.expressBannerView loadAdData];
        }
    } else {
        if (!self.nativeAd) {
            BUSize *imgSize1 = [[BUSize alloc] init];
            imgSize1.width = 1080;
            imgSize1.height = 1920;
            
            BUAdSlot *slot1 = [[BUAdSlot alloc] init];
            slot1.ID = ritStr;
            slot1.AdType = BUAdSlotAdTypeBanner;
            slot1.position = BUAdSlotPositionTop;
            slot1.imgSize = imgSize1;
            slot1.isSupportDeepLink = YES;
            slot1.isOriginAd = YES;
            
            BUNativeAd *nad = [[BUNativeAd alloc] initWithSlot:slot1];
            nad.rootViewController = self.delegate.viewControllerForPresentingModalView;
            nad.delegate = self;
            self.nativeAd = nad;
        }
        self.nativeBannerView = [[PangleNativeBannerView alloc] initWithSize:size];
        if (hasAdMarkup) {
            [self.nativeAd setMopubAdMarkUp:adMarkup];
        }else{
            [self.nativeAd loadAdData];
        }
    }
}

#pragma mark - BUNativeExpressBannerViewDelegate
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    [self.delegate bannerCustomEvent:self didLoadAd:bannerAdView];
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError * __nullable)error {
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    [self.delegate trackImpression];
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    [self.delegate trackClick];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
    [bannerAdView removeFromSuperview];
}

#pragma mark - BUNativeAdDelegate
- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd {
    if (!nativeAd.data) { return; }
    if (!(nativeAd == self.nativeAd)) { return; }
    self.nativeAd = nil;
    [self.nativeBannerView refreshUIWithAd:nativeAd];
    [self.delegate bannerCustomEvent:self didLoadAd:self.nativeBannerView];
}

- (void)nativeAd:(BUNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error {
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *)view {
    [self.delegate trackClick];
}

- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd {
    [self.delegate trackImpression];
}

- (void)nativeAd:(BUNativeAd *)nativeAd  dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    [self.nativeBannerView removeFromSuperview];
}

@end
