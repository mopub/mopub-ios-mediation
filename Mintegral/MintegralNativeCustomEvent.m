//
//  MintegralNativeCustomEvent.m


#import "MintegralNativeCustomEvent.h"
#import "MintegralNativeAdAdapter.h"
#import "MintegralAdapterConfiguration.h"
#import <MTGSDK/MTGSDK.h>
#if __has_include(<MoPubSDKFramework/MPNativeAd.h>)
#import <MoPubSDKFramework/MPNativeAd.h>
#else
#import "MPNativeAd.h"
#endif
#if __has_include(<MoPubSDKFramework/MPNativeAdError.h>)
#import <MoPubSDKFramework/MPNativeAdError.h>
#else
#import "MPNativeAdError.h"
#endif

static BOOL mVideoEnabled = NO;

@interface MintegralNativeCustomEvent()<MTGMediaViewDelegate,MTGBidNativeAdManagerDelegate>

@property (nonatomic, readwrite, strong) MTGNativeAdManager *mtgNativeAdManager;
@property (nonatomic, readwrite, copy) NSString *unitId;

@property (nonatomic) BOOL videoEnabled;
@property (nonatomic, strong) MTGBidNativeAdManager *bidAdManager;
@property (nonatomic, copy) NSString *adm;
@end


@implementation MintegralNativeCustomEvent


- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPLogInfo(@"requestAdWithCustomEventInfo for Mintegral");
    NSString *appId = [info objectForKey:@"appId"];
    NSString *appKey = [info objectForKey:@"appKey"];
    NSString *unitId = [info objectForKey:@"unitId"];
    NSString *errorMsg = nil;
    if (!unitId) errorMsg = @"Invalid Mintegral unitId";
    if (errorMsg) {
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(errorMsg)];
        return;
    }
    if ([info objectForKey:kMTGVideoAdsEnabledKey] == nil) {
        self.videoEnabled = mVideoEnabled;
    } else {
        self.videoEnabled = [[info objectForKey:kMTGVideoAdsEnabledKey] boolValue];
    }
    MTGAdTemplateType reqNum = [info objectForKey:@"reqNum"] ?[[info objectForKey:@"reqNum"] integerValue]:1;
    
    self.unitId = unitId;
    
    if (![MintegralAdapterConfiguration isSDKInitialized]) {
        [MintegralAdapterConfiguration setGDPRInfo:info];
        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        [MintegralAdapterConfiguration sdkInitialized];
    }
    
    self.adm = adMarkup;
    if (self.adm) {
        if (_bidAdManager == nil) {

            MPLogInfo(@"Loading Mintegral native ad markup for Advanced Bidding");
            _bidAdManager = [[MTGBidNativeAdManager alloc] initWithUnitID:unitId autoCacheImage:NO presentingViewController:nil];
            _bidAdManager.delegate = self;
            [self.bidAdManager loadWithBidToken:self.adm];
        }
    }else{
        MPLogInfo(@"Loading native ad");
        _mtgNativeAdManager = [[MTGNativeAdManager alloc] initWithUnitID:unitId fbPlacementId:@"" supportedTemplates:@[[MTGTemplate templateWithType:MTGAD_TEMPLATE_BIG_IMAGE adsNum:1]] autoCacheImage:NO adCategory:0 presentingViewController:nil];

        _mtgNativeAdManager.delegate = self;
        [_mtgNativeAdManager loadAds];
    }
    
}

#pragma mark - nativeAdManager init and delegate

- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds {
    MPLogInfo(@"Mintegral nativeAdsLoaded");
    MintegralNativeAdAdapter *adAdapter = [[MintegralNativeAdAdapter alloc] initWithNativeAds:nativeAds nativeAdManager:_mtgNativeAdManager withUnitId:self.unitId videoSupport:self.videoEnabled];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error {
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeAdDidClick:(nonnull MTGCampaign *)nativeAd;
{
    MPLogInfo(@"Mintegral nativeAdDidClick");
}

- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalUrl
                             error:(nullable NSError *)error{
    
}

@end
