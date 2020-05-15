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
    size = [self sizeForCustomEventInfo:size];
    BOOL hasAdMarkup = adMarkup.length > 0;
    NSDictionary *ritDict;
    
    NSString * appId = [info objectForKey:@"app_id"];
    if (appId != nil) {
        [PangleAdapterConfiguration updateInitializationParameters:info];
    }
    self.adPlacementId = [info objectForKey:@"ad_placement_id"];
    if (self.adPlacementId == nil) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey: @"Invalid Pangle placement ID. Failing ad request. Ensure the ad placement id is valid on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    ritDict = [BUAdSDKManager AdTypeWithRit:self.adPlacementId];
    
    //renderType: @"1" express AD   @"2" native AD
    NSInteger renderType = [[ritDict objectForKey:@"renderType"] integerValue];

    BUSize *adSize = [[BUSize alloc] init];
    adSize.width = size.width;
    adSize.height = size.height;
    if (renderType == 1) {
        CGSize expressRequestSize = [self sizeForCustomEventInfo:size];
        self.expressBannerView = [[BUNativeExpressBannerView alloc] initWithSlotID:self.adPlacementId rootViewController:self.delegate.viewControllerForPresentingModalView adSize:expressRequestSize IsSupportDeepLink:YES];
        self.expressBannerView.frame = CGRectMake(0, 0, size.width, size.height);
        self.expressBannerView.delegate = self;
        if (hasAdMarkup) {
            [self.expressBannerView setMopubAdMarkUp:adMarkup];
        } else {
            [self.expressBannerView loadAdData];
        }
    } else {
        BUSize *imgSize1 = [[BUSize alloc] init];
        imgSize1.width = size.width * [[UIScreen mainScreen] scale];
        imgSize1.height = size.height * [[UIScreen mainScreen] scale];
        
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
    if (height >= [BUSize sizeBy:BUProposalSize_Banner600_500].height &&
        width >= [BUSize sizeBy:BUProposalSize_Banner600_500].width) {
        return CGSizeMake([BUSize sizeBy:BUProposalSize_Banner600_500].width,
                          [BUSize sizeBy:BUProposalSize_Banner600_500].height);
    } else if (height >= [BUSize sizeBy:BUProposalSize_Banner600_400].height
               && width >= [BUSize sizeBy:BUProposalSize_Banner600_400].width) {
        return CGSizeMake([BUSize sizeBy:BUProposalSize_Banner600_400].width,
                          [BUSize sizeBy:BUProposalSize_Banner600_400].height);
    } else if (height >= [BUSize sizeBy:BUProposalSize_Banner600_388].height &&
               width >= [BUSize sizeBy:BUProposalSize_Banner600_388].width) {
        return CGSizeMake([BUSize sizeBy:BUProposalSize_Banner600_388].width,
                          [BUSize sizeBy:BUProposalSize_Banner600_388].height);
    } else if (height >= [BUSize sizeBy:BUProposalSize_Banner600_300].height &&
               width >= [BUSize sizeBy:BUProposalSize_Banner600_300].width) {
        return CGSizeMake([BUSize sizeBy:BUProposalSize_Banner600_300].width,
                          [BUSize sizeBy:BUProposalSize_Banner600_300].height);
    } else if (height >= [BUSize sizeBy:BUProposalSize_Banner600_286].height &&
               width >= [BUSize sizeBy:BUProposalSize_Banner600_286].width) {
        return CGSizeMake([BUSize sizeBy:BUProposalSize_Banner600_286].width,
                          [BUSize sizeBy:BUProposalSize_Banner600_286].height);
    } else if (height >= [BUSize sizeBy:BUProposalSize_Banner600_260].height &&
               width >= [BUSize sizeBy:BUProposalSize_Banner600_260].width) {
        return CGSizeMake([BUSize sizeBy:BUProposalSize_Banner600_260].width,
                          [BUSize sizeBy:BUProposalSize_Banner600_260].height);
    }else if (height >= [BUSize sizeBy:BUProposalSize_Banner600_150].height &&
               width >= [BUSize sizeBy:BUProposalSize_Banner600_150].width) {
        return CGSizeMake([BUSize sizeBy:BUProposalSize_Banner600_150].width,
                          [BUSize sizeBy:BUProposalSize_Banner600_150].height);
    }else if (height >= [BUSize sizeBy:BUProposalSize_Banner600_100].height &&
               width >= [BUSize sizeBy:BUProposalSize_Banner600_100].width) {
        return CGSizeMake([BUSize sizeBy:BUProposalSize_Banner600_100].width,
                          [BUSize sizeBy:BUProposalSize_Banner600_100].height);
    }else if (height >= [BUSize sizeBy:BUProposalSize_Banner600_90].height &&
               width >= [BUSize sizeBy:BUProposalSize_Banner600_90].width) {
        return CGSizeMake([BUSize sizeBy:BUProposalSize_Banner600_90].width,
                          [BUSize sizeBy:BUProposalSize_Banner600_90].height);
    } else {
        return CGSizeMake([BUSize sizeBy:BUProposalSize_Banner600_90].width,
                          [BUSize sizeBy:BUProposalSize_Banner600_90].height);
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
    [self.delegate trackClick];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
    [bannerAdView removeFromSuperview];
}

#pragma mark - BUNativeAdDelegate
- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd {
    if (!nativeAd.data || !(nativeAd == self.nativeAd)){
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey: @"Invalid Pangle Data. Failing ad request."}];
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
    [self.delegate trackClick];
}

- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd {
    [self.delegate trackImpression];
}

- (void)nativeAd:(BUNativeAd *)nativeAd  dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    [self.nativeBannerView removeFromSuperview];
}

@end
