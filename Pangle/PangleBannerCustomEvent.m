//
//  PangleBannerCustomEvent.m
//  BUAdSDKDemo
//
//  Created by Pangle on 2018/10/24.
//  Copyright © 2018年 Pangle. All rights reserved.
//

#import "PangleBannerCustomEvent.h"
#import <BUAdSDK/BUAdSDK.h>
#import "PangleAdapterConfiguration.h"

#if __has_include("MoPub.h")
#import "MPError.h"
#import "MPLogging.h"
#import "MoPub.h"
#endif

@interface PangleBannerCustomEvent ()<BUNativeExpressBannerViewDelegate,BUNativeAdDelegate>
@property (nonatomic, strong) BUNativeExpressBannerView *expressBannerView;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) PangleNativeBannerView *nativeBannerView;
@property (nonatomic, copy) NSString *adPlacementId;
@end

@implementation PangleBannerCustomEvent
- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    BOOL hasAdMarkup = adMarkup.length > 0;
    NSDictionary *ritDict;
    
    NSString * appId = [info objectForKey:@"app_id"];
    if (appId != nil) {
        [PangleAdapterConfiguration updateInitializationParameters:info];
    }
    self.adPlacementId = [info objectForKey:@"ad_placement_id"];
    if (self.adPlacementId == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:BUErrorCodeAdSlotEmpty userInfo:@{NSLocalizedDescriptionKey: @"Invalid Pangle placement ID. Failing ad request. Ensure the ad placement id is valid on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    ritDict = [BUAdSDKManager AdTypeWithRit:self.adPlacementId];
    
    PangleRenderMethod renderType = [[ritDict objectForKey:@"renderType"] integerValue];
    if (renderType == PangleRenderMethodDynamic) {
        CGSize expressRequestSize = [self sizeForCustomEventInfo:size];
        self.expressBannerView = [[BUNativeExpressBannerView alloc] initWithSlotID:self.adPlacementId rootViewController:self.delegate.viewControllerForPresentingModalView adSize:expressRequestSize IsSupportDeepLink:YES];
        self.expressBannerView.frame = CGRectMake(0, 0, expressRequestSize.width, expressRequestSize.height);
        self.expressBannerView.delegate = self;
        if (hasAdMarkup) {
            [self.expressBannerView setMopubAdMarkUp:adMarkup];
        } else {
            [self.expressBannerView loadAdData];
        }
    } else {
        BUSize *imgSize1 = [[BUSize alloc] init];
        CGSize nativeRequestSize = [self sizeForCustomEventInfo:size];
        imgSize1.width = nativeRequestSize.width;
        imgSize1.height = nativeRequestSize.height;
        
        BUAdSlot *slot1 = [[BUAdSlot alloc] init];
        slot1.ID = self.adPlacementId;
        slot1.AdType = BUAdSlotAdTypeBanner;
        slot1.position = BUAdSlotPositionTop;
        slot1.imgSize = imgSize1;
        slot1.isSupportDeepLink = YES;
        slot1.isOriginAd = YES;
        
        BUNativeAd *nad = [[BUNativeAd alloc] initWithSlot:slot1];
        nad.rootViewController = self.delegate.viewControllerForPresentingModalView;
        nad.delegate = self;
        self.nativeAd = nad;
        self.nativeBannerView = [[PangleNativeBannerView alloc] initWithSize:size];
        if (hasAdMarkup) {
            [self.nativeAd setMopubAdMarkUp:adMarkup];
        }else{
            [self.nativeAd loadAdData];
        }
    }
}

- (NSString *) getAdNetworkId {
    return (self.adPlacementId != nil) ? self.adPlacementId : @"";
}

- (CGSize)sizeForCustomEventInfo:(CGSize)size {
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat renderRatio = height / width;
    if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner600_500].height * 1.0 /
        [BUSize sizeBy:BUProposalSize_Banner600_500].width) {
        return CGSizeMake(width, width *
                          [BUSize sizeBy:BUProposalSize_Banner600_500].height /
                          [BUSize sizeBy:BUProposalSize_Banner600_500].width);//0.83
    } else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner600_400].height * 1.0  /
               [BUSize sizeBy:BUProposalSize_Banner600_400].width) {
        return CGSizeMake(width, width *
                          [BUSize sizeBy:BUProposalSize_Banner600_400].height /
                          [BUSize sizeBy:BUProposalSize_Banner600_400].width);//0.67
    } else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner690_388].height * 1.0  /
               [BUSize sizeBy:BUProposalSize_Banner690_388].width) {
        return CGSizeMake(width, width *
                          [BUSize sizeBy:BUProposalSize_Banner690_388].height /
                          [BUSize sizeBy:BUProposalSize_Banner690_388].width);//0.56
    } else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner600_300].height * 1.0  /
               [BUSize sizeBy:BUProposalSize_Banner600_300].width) {
        return CGSizeMake(width, width *
                          [BUSize sizeBy:BUProposalSize_Banner600_300].height /
                          [BUSize sizeBy:BUProposalSize_Banner600_300].width);//0.5
    } else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner600_260].height * 1.0  /
               [BUSize sizeBy:BUProposalSize_Banner600_260].width) {
        return CGSizeMake(width, width *
                          [BUSize sizeBy:BUProposalSize_Banner600_260].height /
                          [BUSize sizeBy:BUProposalSize_Banner600_260].width);//0.43
    }else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner600_150].height * 1.0  /
              [BUSize sizeBy:BUProposalSize_Banner600_150].width) {
        return CGSizeMake(width, width *
                          [BUSize sizeBy:BUProposalSize_Banner600_150].height /
                          [BUSize sizeBy:BUProposalSize_Banner600_150].width);//0.25
    }else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner640_100].height * 1.0  /
              [BUSize sizeBy:BUProposalSize_Banner640_100].width) {
        return CGSizeMake(width, width *
                          [BUSize sizeBy:BUProposalSize_Banner640_100].height /
                          [BUSize sizeBy:BUProposalSize_Banner640_100].width);//0.16
    }else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner600_90].height * 1.0  /
              [BUSize sizeBy:BUProposalSize_Banner600_90].width) {
        return CGSizeMake(width, width *
                          [BUSize sizeBy:BUProposalSize_Banner600_90].height /
                          [BUSize sizeBy:BUProposalSize_Banner600_90].width);//0.15
    } else {
        return CGSizeMake(width, width *
                          [BUSize sizeBy:BUProposalSize_Banner600_90].height /
                          [BUSize sizeBy:BUProposalSize_Banner600_90].width);//0.15
    }
}


#pragma mark - BUNativeExpressBannerViewDelegate
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate bannerCustomEvent:self didLoadAd:bannerAdView];
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError * __nullable)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    [self.delegate trackImpression];
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate trackClick];
    [self.delegate bannerCustomEventWillLeaveApplication:self];
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)nativeExpressBannerAdViewDidCloseOtherController:(BUNativeExpressBannerView *)bannerAdView interactionType:(BUInteractionType)interactionType {
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
    [bannerAdView removeFromSuperview];
}

#pragma mark - BUNativeAdDelegate
- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd {
    if (!nativeAd.data || !(nativeAd == self.nativeAd)){
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:BUErrorCodeNOAdError userInfo:@{NSLocalizedDescriptionKey: @"Invalid Pangle Data. Failing ad request."}];
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    self.nativeAd = nil;
    [self.nativeBannerView refreshUIWithAd:nativeAd];
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate bannerCustomEvent:self didLoadAd:self.nativeBannerView];
}

- (void)nativeAd:(BUNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *)view {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate trackClick];
    [self.delegate bannerCustomEventWillLeaveApplication:self];
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd {
    [self.delegate trackImpression];
}

- (void)nativeAdDidCloseOtherController:(BUNativeAd *)nativeAd interactionType:(BUInteractionType)interactionType {
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)nativeAd:(BUNativeAd *)nativeAd  dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    [self.nativeBannerView removeFromSuperview];
}

@end
