//
//  MintegralBannerCustomEvent.m

#import "MintegralBannerCustomEvent.h"
#import <MTGSDK/MTGSDK.h>
#import "MintegralAdapterConfiguration.h"
#import <MTGSDKBanner/MTGBannerAdView.h>
#import <MTGSDKBanner/MTGBannerAdViewDelegate.h>
#if __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif
#if __has_include(<MoPubSDKFramework/MPLogging.h>)
#import <MoPubSDKFramework/MPLogging.h>
#else
#import "MPLogging.h"
#endif

typedef enum {
    MintegralErrorBannerParaUnresolveable = 19,
    MintegralErrorBannerCamPaignListEmpty,
}MintegralBannerErrorCode;

@interface MintegralBannerCustomEvent() <MTGBannerAdViewDelegate>

@property(nonatomic,strong) MTGBannerAdView *bannerAdView;
@property (nonatomic, strong) NSString * adUnitId;
@property (nonatomic, assign) CGSize currentSize;
@property (nonatomic, copy) NSString *adm;
@end

@implementation MintegralBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup{
    MPLogInfo(@"requestAdWithSize for Mintegral");
    NSString *appId = [info objectForKey:@"appId"];
    NSString *appKey = [info objectForKey:@"appKey"];
    NSString *unitId = [info objectForKey:@"unitId"];
    
    NSString *errorMsg = nil;

    if (!unitId) errorMsg = @"Invalid Mintegral unitId";
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:kMintegralErrorDomain code:MintegralErrorBannerParaUnresolveable userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        if ([self.description respondsToSelector:@selector(bannerCustomEvent: didFailToLoadAdWithError:)]) {
            [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        }
        return;
    }
    
    if (![MintegralAdapterConfiguration isSDKInitialized]) {
        [MintegralAdapterConfiguration setGDPRInfo:info];
        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        [MintegralAdapterConfiguration sdkInitialized];
    }
    _adUnitId = unitId;
    _currentSize = size;
    
    UIViewController * vc =  [UIApplication sharedApplication].keyWindow.rootViewController;
    _bannerAdView = [[MTGBannerAdView alloc] initBannerAdViewWithAdSize:size unitId:unitId rootViewController:vc];
    _bannerAdView.delegate = self;

    self.adm = adMarkup;
    if (self.adm) {
        MPLogInfo(@"Loading Mintegral Banner ad markup for Advanced Bidding");
        [_bannerAdView loadBannerAdWithBidToken:self.adm];
    }else{
        MPLogInfo(@"Loading Mintegral native ad");
        [_bannerAdView loadBannerAd];
    }
}

#pragma mark -- MTGBannerAdViewDelegate
- (void)adViewLoadSuccess:(MTGBannerAdView *)adView {
    if ([self.delegate respondsToSelector:@selector(bannerCustomEvent: didLoadAd:)]) {
        [self.delegate bannerCustomEvent:self didLoadAd:adView];
    }
}

- (void)adViewLoadFailedWithError:(NSError *)error adView:(MTGBannerAdView *)adView {
    if ([self.delegate respondsToSelector:@selector(bannerCustomEvent: didFailToLoadAdWithError:)]) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)adViewWillLogImpression:(MTGBannerAdView *)adView{
    if ([self.delegate respondsToSelector:@selector(trackImpression)]) {
        [self.delegate trackImpression];
    }
}

- (void)adViewDidClicked:(MTGBannerAdView *)adView {
    if ([self.delegate respondsToSelector:@selector(trackClick)]) {
        [self.delegate trackClick];
    }
}

- (void)adViewWillLeaveApplication:(MTGBannerAdView *)adView {
    if ([self.delegate respondsToSelector:@selector(bannerCustomEventWillLeaveApplication:)]) {
        [self.delegate bannerCustomEventWillLeaveApplication:self];
    }
}

- (void)adViewWillOpenFullScreen:(MTGBannerAdView *)adView {
    
}

- (void)adViewCloseFullScreen:(MTGBannerAdView *)adView {
}


#pragma mark - Turn off auto impression and click
- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

@end


