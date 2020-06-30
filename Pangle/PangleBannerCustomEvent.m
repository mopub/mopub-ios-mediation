#import "PangleBannerCustomEvent.h"
#import <BUAdSDK/BUAdSDK.h>
#import "PangleAdapterConfiguration.h"

#if __has_include("MoPub.h")
    #import "MPError.h"
    #import "MPLogging.h"
    #import "MoPub.h"
#endif

@interface PangleBannerCustomEvent () <BUNativeExpressBannerViewDelegate, BUNativeAdDelegate>
@property (nonatomic, strong) BUNativeExpressBannerView *expressBannerView;
@property (nonatomic, copy) NSString *adPlacementId;
@property (nonatomic, copy) NSString *appId;
@end

@implementation PangleBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    BOOL hasAdMarkup = adMarkup.length > 0;
    NSDictionary *renderInfo;
    
    if (info.count == 0) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey:
                                                        @"Incorrect or missing Pangle App ID or Placement ID on the network UI. Ensure the App ID and Placement ID is correct on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError: error];
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
        
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError: error];
        return;
    }
    
    NSError *error = nil;
    renderInfo = [BUAdSDKManager AdTypeWithRit:self.adPlacementId error:&error];
    if (error) {
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError: error];
        return;
    }

    if ([[renderInfo objectForKey:@"renderType"] integerValue] != BUAdSlotAdTypeBanner) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                                    code:BUErrorCodeAdSlotEmpty
                                                userInfo:@{NSLocalizedDescriptionKey:
                                                               @"Mismatched Pangle placement ID. Please make sure the ad placement ID corresponds to Express format in Pangle UI"}];
               MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
               [self.delegate inlineAdAdapter:self didFailToLoadAdWithError: error];
               return;
    }

    CGSize expressRequestSize = [self sizeForAdapterInfo:size];
    self.expressBannerView = [[BUNativeExpressBannerView alloc] initWithSlotID:self.adPlacementId
                                                            rootViewController:[self.delegate inlineAdAdapterViewControllerForPresentingModalView:self] adSize:expressRequestSize IsSupportDeepLink:YES];
    self.expressBannerView.frame = CGRectMake(0, 0, expressRequestSize.width, expressRequestSize.height);
    self.expressBannerView.delegate = self;
    if (hasAdMarkup) {
        MPLogInfo(@"Loading Pangle express banner ad markup for Advanced Bidding");
        
        [self.expressBannerView setMopubAdMarkUp:adMarkup];
    } else {
        MPLogInfo(@"Loading Pangle express banner ad");
        
        [self.expressBannerView loadAdData];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (NSString *) getAdNetworkId {
    return (BUCheckValidString(self.adPlacementId)) ? self.adPlacementId : @"";
}

- (CGSize)sizeForAdapterInfo:(CGSize)size {
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat renderRatio = height * 1.0 / width;
    
    if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner600_500].height * 1.0 /
        [BUSize sizeBy:BUProposalSize_Banner600_500].width) {
        return CGSizeMake(width,
                          width * [BUSize sizeBy:BUProposalSize_Banner600_500].height / [BUSize sizeBy:BUProposalSize_Banner600_500].width); //0.83
    } else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner600_400].height * 1.0  /
               [BUSize sizeBy:BUProposalSize_Banner600_400].width) {
        return CGSizeMake(width,
                          width * [BUSize sizeBy:BUProposalSize_Banner600_400].height / [BUSize sizeBy:BUProposalSize_Banner600_400].width); //0.67
    } else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner690_388].height * 1.0  /
               [BUSize sizeBy:BUProposalSize_Banner690_388].width) {
        return CGSizeMake(width,
                          width * [BUSize sizeBy:BUProposalSize_Banner690_388].height / [BUSize sizeBy:BUProposalSize_Banner690_388].width); //0.56
    } else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner600_300].height * 1.0  /
               [BUSize sizeBy:BUProposalSize_Banner600_300].width) {
        return CGSizeMake(width,
                          width * [BUSize sizeBy:BUProposalSize_Banner600_300].height / [BUSize sizeBy:BUProposalSize_Banner600_300].width); //0.5
    } else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner600_260].height * 1.0  /
               [BUSize sizeBy:BUProposalSize_Banner600_260].width) {
        return CGSizeMake(width,
                          width * [BUSize sizeBy:BUProposalSize_Banner600_260].height / [BUSize sizeBy:BUProposalSize_Banner600_260].width); //0.43
    } else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner600_150].height * 1.0  /
              [BUSize sizeBy:BUProposalSize_Banner600_150].width) {
        return CGSizeMake(width,
                          width * [BUSize sizeBy:BUProposalSize_Banner600_150].height / [BUSize sizeBy:BUProposalSize_Banner600_150].width); //0.25
    } else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner640_100].height * 1.0  /
              [BUSize sizeBy:BUProposalSize_Banner640_100].width) {
        return CGSizeMake(width,
                          width * [BUSize sizeBy:BUProposalSize_Banner640_100].height / [BUSize sizeBy:BUProposalSize_Banner640_100].width); //0.16
    } else if (renderRatio >= [BUSize sizeBy:BUProposalSize_Banner600_90].height * 1.0  /
              [BUSize sizeBy:BUProposalSize_Banner600_90].width) {
        return CGSizeMake(width,
                          width * [BUSize sizeBy:BUProposalSize_Banner600_90].height / [BUSize sizeBy:BUProposalSize_Banner600_90].width); //0.15
    } else {
        return CGSizeMake(width,
                          width * [BUSize sizeBy:BUProposalSize_Banner600_90].height / [BUSize sizeBy:BUProposalSize_Banner600_90].width);//0.15
    }
}

- (void)updateAppId{
    [BUAdSDKManager setAppID:self.appId];
}

#pragma mark - BUNativeExpressBannerViewDelegate - Express Banner

- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    // no-op
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError: error];
    if (BUCheckValidString(self.appId) && error.code == BUUnionAppSiteRelError) {
        [self updateAppId];
    }
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:bannerAdView];
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError * __nullable)error {
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError: error];
    if (BUCheckValidString(self.appId) && error.code == BUUnionAppSiteRelError) {
        [self updateAppId];
    }
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate inlineAdAdapterDidTrackImpression:self];
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate inlineAdAdapterDidTrackClick:self];
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
}

- (void)nativeExpressBannerAdViewDidCloseOtherController:(BUNativeExpressBannerView *)bannerAdView interactionType:(BUInteractionType)interactionType {
    [self.delegate inlineAdAdapterDidEndUserAction:self];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
    [bannerAdView removeFromSuperview];
}

@end
