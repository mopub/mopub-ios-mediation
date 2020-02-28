#import "MintegralNativeCustomEvent.h"
#import "MintegralNativeAdAdapter.h"
#import "MintegralAdapterConfiguration.h"
#import <MTGSDK/MTGSDK.h>
#if __has_include("MoPub.h")
    #import "MPNativeAd.h"
    #import "MPNativeAdError.h"
    #import "MPLogging.h"
#endif

@interface MintegralNativeCustomEvent()<MTGNativeAdManagerDelegate, MTGMediaViewDelegate, MTGBidNativeAdManagerDelegate>

@property (nonatomic, readwrite, strong) MTGNativeAdManager *mtgNativeAdManager;
@property (nonatomic, readwrite, copy) NSString *adUnitId;

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
    
    if (!appId) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral appId. Failing ad request. Ensure the app ID is valid on the MoPub dashboard."];
    if (!appKey) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral appKey. Failing ad request. Ensure the app key is valid on the MoPub dashboard."];
    if (!unitId) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral unitId. Failing ad request. Ensure the unit ID is valid on the MoPub dashboard."];
    
    if (errorMsg) {
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:MPNativeAdNSErrorForInvalidAdServerResponse(errorMsg)], self.adUnitId);
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(errorMsg)];
        
        return;
    }
    
    MTGAdTemplateType reqNum = [info objectForKey:@"reqNum"] ?[[info objectForKey:@"reqNum"] integerValue]:1;
    
    self.adm = adMarkup;
    self.adUnitId = unitId;
    
    [MintegralAdapterConfiguration initializeMintegral:info setAppID:appId appKey:appKey];
    
    if (self.adm) {
        if (_bidAdManager == nil) {
            MPLogInfo(@"Loading Mintegral native ad markup for Advanced Bidding");
            
            _bidAdManager = [[MTGBidNativeAdManager alloc] initWithUnitID:unitId autoCacheImage:NO presentingViewController:nil];
            _bidAdManager.delegate = self;
            
            [self.bidAdManager loadWithBidToken:self.adm];
            MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.adUnitId);
        }
    } else {
        MPLogInfo(@"Loading Mintegral native ad");
        
        _mtgNativeAdManager = [[MTGNativeAdManager alloc] initWithUnitID:unitId fbPlacementId:@"" supportedTemplates:@[[MTGTemplate templateWithType:MTGAD_TEMPLATE_BIG_IMAGE adsNum:1]] autoCacheImage:NO adCategory:0 presentingViewController:nil];
        
        _mtgNativeAdManager.delegate = self;
        [_mtgNativeAdManager loadAds];
        
        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.adUnitId);
    }
}

#pragma mark - nativeAdManager init and delegate

- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds {
    MPLogInfo(@"Mintegral traditional nativeAdsLoaded");
    MintegralNativeAdAdapter *adAdapter = [[MintegralNativeAdAdapter alloc] initWithNativeAds:nativeAds nativeAdManager:_mtgNativeAdManager bidAdManager:nil withUnitId:self.adUnitId];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.adUnitId);
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:MPNativeAdNSErrorForInvalidAdServerResponse(error.localizedDescription)], self.adUnitId);
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)nativeAdsLoaded:(NSArray *)nativeAds bidNativeManager:(MTGBidNativeAdManager *)bidNativeManager{
    
    MPLogInfo(@"Mintegral bidding nativeAdsLoaded");
    MintegralNativeAdAdapter *adAdapter = [[MintegralNativeAdAdapter alloc] initWithNativeAds:nativeAds nativeAdManager:nil bidAdManager:_bidAdManager withUnitId:self.adUnitId];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.adUnitId);
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

- (void)nativeAdsFailedToLoadWithError:(NSError *)error bidNativeManager:(MTGBidNativeAdManager *)bidNativeManager{
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:MPNativeAdNSErrorForInvalidAdServerResponse(error.localizedDescription)], self.adUnitId);
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

@end
