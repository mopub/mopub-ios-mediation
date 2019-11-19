//
//  MintegralNativeCustomEvent.m
//  MoPubSampleApp
//
//  Copyright © 2016年 MoPub. All rights reserved.
//

#import "MintegralNativeCustomEvent.h"
#import "MintegralNativeAdAdapter.h"
#import "MintegralAdapterHelper.h"
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
    NSString *appId = [info objectForKey:@"appId"];
    NSString *appKey = [info objectForKey:@"appKey"];
    NSString *unitId = [info objectForKey:@"unitId"];
    

    NSString *errorMsg = nil;
//    if (!appId) errorMsg = @"Invalid Mintegral appId";
//    if (!appKey) errorMsg = @"Invalid Mintegral appKey";
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
    
    if (![MintegralAdapterHelper isSDKInitialized]) {
        
        [MintegralAdapterHelper setGDPRInfo:info];
        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        [MintegralAdapterHelper sdkInitialized];
    }
    
    self.adm = adMarkup;
    if (self.adm) {
        if (_bidAdManager == nil) {

            _bidAdManager = [[MTGBidNativeAdManager alloc] initWithUnitID:unitId autoCacheImage:NO presentingViewController:nil];
            _bidAdManager.delegate = self;
            [self.bidAdManager loadWithBidToken:self.adm];
        }
    }else{
        _mtgNativeAdManager = [[MTGNativeAdManager alloc] initWithUnitID:unitId fbPlacementId:@"" supportedTemplates:@[[MTGTemplate templateWithType:MTGAD_TEMPLATE_BIG_IMAGE adsNum:1]] autoCacheImage:NO adCategory:0 presentingViewController:nil];

        _mtgNativeAdManager.delegate = self;
        [_mtgNativeAdManager loadAds];
    }
    
}

#pragma mark - nativeAdManager init and delegate

- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds {
    NSLog(@"nativeAdsLoaded");
    MintegralNativeAdAdapter *adAdapter = [[MintegralNativeAdAdapter alloc] initWithNativeAds:nativeAds nativeAdManager:_mtgNativeAdManager withUnitId:self.unitId videoSupport:self.videoEnabled];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error {
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}



- (void)nativeAdDidClick:(nonnull MTGCampaign *)nativeAd;
{

}

- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalUrl
                             error:(nullable NSError *)error{
    
}

@end
