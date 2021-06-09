#import "PangleBannerCustomEvent.h"
#import <BUAdSDK/BUAdSDK.h>
#import "PangleAdapterConfiguration.h"

#if __has_include("MoPub.h")
    #import "MPError.h"
    #import "MPLogging.h"
    #import "MoPub.h"
#endif

@interface PangleBannerCustomEvent () <BUNativeExpressBannerViewDelegate>
@property (nonatomic, strong) BUNativeExpressBannerView *expressBannerView;
@property (nonatomic, copy) NSString *adPlacementId;
@property (nonatomic, copy) NSString *appId;
@end

@implementation PangleBannerCustomEvent
@dynamic delegate;
@dynamic localExtras;

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    BOOL hasAdMarkup = adMarkup.length > 0;

    if (info.count == 0) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey:
                                                        @"Incorrect or missing Pangle App ID or Placement ID on the network UI. Ensure the App ID and Placement ID is correct on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError: error];
        return;
    }
    
    NSString *appIdString = [info objectForKey:kPangleAppIdKey];
    self.appId = appIdString;
    
    if (appIdString && [appIdString isKindOfClass:[NSString class]] && appIdString.length > 0) {
        [PangleAdapterConfiguration pangleSDKInitWithAppId:appIdString];
        [PangleAdapterConfiguration updateInitializationParameters:info];
    }
    
    NSString *adPlacementId = [info objectForKey:kPanglePlacementIdKey];
    self.adPlacementId = adPlacementId;
    
    if (!(adPlacementId && [adPlacementId isKindOfClass:[NSString class]] && adPlacementId.length > 0)) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:BUErrorCodeAdSlotEmpty
                                         userInfo:@{NSLocalizedDescriptionKey:
                                                        @"Incorrect or missing Pangle placement ID. Failing ad request. Ensure the ad placement ID is correct on the MoPub dashboard."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError: error];
        return;
    }
    
    CGSize expressRequestSize = [self sizeForAdapterInfo:size];
    self.expressBannerView = [[BUNativeExpressBannerView alloc] initWithSlotID:self.adPlacementId
                                                            rootViewController:[self.delegate inlineAdAdapterViewControllerForPresentingModalView:self] adSize:expressRequestSize];
    self.expressBannerView.frame = CGRectMake(0, 0, expressRequestSize.width, expressRequestSize.height);
    self.expressBannerView.delegate = self;
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
    
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
    NSString *adPlacementId = self.adPlacementId;
    return (adPlacementId && [adPlacementId isKindOfClass:[NSString class]]) ? adPlacementId : @"";
}

/**
Banner size mapping according to the incoming size in adapter and selected size on Pangle platform. Pangle will return the banner ads with appropriate size.
*/
- (CGSize)sizeForAdapterInfo:(CGSize)size {
    CGFloat width = size.width;
    CGFloat height = size.height;
    if (height >= floor(width * 450.0 / 600.0)) {
        // Banner 600*500
        if (width / height > 600 / 500) {
            return CGSizeMake(height / 5 * 6, height);
        }
        else {
            return CGSizeMake(width, width / 6 * 5);
        }
    } else {
        // Banner 600*150
        if (width / height > 640 / 100) {
            return CGSizeMake(height / 100 * 640, height);
        }
        else {
            return CGSizeMake(width, width / 640 * 100);
        }
    }
}

#pragma mark - BUNativeExpressBannerViewDelegate - Express Banner

- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    // no-op
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError: error];
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:bannerAdView];
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError * __nullable)error {
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError: error];
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
    /** Pangle provided a dislike callback, it is an optional callback method when user click they dislike the ad.
     *  Please reach out to Pangle team if you want to implement it.
     */
    MPLogInfo(@"%@ Pangle DislikeInteractionCalback",[self getAdNetworkId]);
}

@end
