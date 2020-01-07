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
} MintegralBannerErrorCode;

@interface MintegralBannerCustomEvent() <MTGBannerAdViewDelegate>

@property(nonatomic,strong) MTGBannerAdView *bannerAdView;
@property (nonatomic, strong) NSString *adUnitId;
@property (nonatomic, copy) NSString *adm;
@end

@implementation MintegralBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    MPLogInfo(@"requestAdWithSize for Mintegral");
    
    NSString *appId = [info objectForKey:@"appId"];
    NSString *appKey = [info objectForKey:@"appKey"];
    NSString *unitId = [info objectForKey:@"unitId"];
    
    NSString *errorMsg = nil;
    
    if (!appId) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral appId. Failing ad request. Ensure the app ID is valid on the MoPub dashboard."];
    if (!appKey) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral appKey. Failing ad request. Ensure the app key is valid on the MoPub dashboard."];
    if (!unitId) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral unitId. Failing ad request. Ensure the unit ID is valid on the MoPub dashboard."];
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:kMintegralErrorDomain code:MintegralErrorBannerParaUnresolveable userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        
        if ([self.description respondsToSelector:@selector(bannerCustomEvent: didFailToLoadAdWithError:)]) {
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
            [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        }
        return;
    }
    
    self.adm = adMarkup;
    _adUnitId = unitId;
    
    [MintegralAdapterConfiguration initializeMintegral:info setAppID:appId appKey:appKey];
    
    UIViewController *vc =  [UIApplication sharedApplication].keyWindow.rootViewController;
    _bannerAdView = [[MTGBannerAdView alloc] initBannerAdViewWithAdSize:size unitId:unitId rootViewController:vc];
    _bannerAdView.delegate = self;
    
    if (self.adm) {
        MPLogInfo(@"Loading Mintegral banner ad markup for Advanced Bidding");
        [_bannerAdView loadBannerAdWithBidToken:self.adm];
    } else {
        MPLogInfo(@"Loading Mintegral banner ad");
        [_bannerAdView loadBannerAd];
    }
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.adUnitId);
}

#pragma mark -- MTGBannerAdViewDelegate
- (void)adViewLoadSuccess:(MTGBannerAdView *)adView {
    if ([self.delegate respondsToSelector:@selector(bannerCustomEvent: didLoadAd:)]) {
        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.adUnitId);
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.adUnitId);
        MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.adUnitId);
        [self.delegate bannerCustomEvent:self didLoadAd:adView];
    }
}

- (void)adViewLoadFailedWithError:(NSError *)error adView:(MTGBannerAdView *)adView {
    if ([self.delegate respondsToSelector:@selector(bannerCustomEvent: didFailToLoadAdWithError:)]) {
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)adViewWillLogImpression:(MTGBannerAdView *)adView {
    if ([self.delegate respondsToSelector:@selector(trackImpression)]) {
        [self.delegate trackImpression];
    }
}

- (void)adViewDidClicked:(MTGBannerAdView *)adView {
    if ([self.delegate respondsToSelector:@selector(trackClick)]) {
        MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.adUnitId);
        [self.delegate trackClick];
        [self.delegate bannerCustomEventWillBeginAction:self];
    }
}

- (void)adViewWillLeaveApplication:(MTGBannerAdView *)adView {
    if ([self.delegate respondsToSelector:@selector(bannerCustomEventWillLeaveApplication:)]) {
        MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.adUnitId);
        [self.delegate bannerCustomEventWillLeaveApplication:self];
    }
}

- (void)adViewWillOpenFullScreen:(MTGBannerAdView *)adView {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.adUnitId);
}

- (void)adViewCloseFullScreen:(MTGBannerAdView *)adView {
    MPLogAdEvent([MPLogEvent adDidDismissModalForAdapter:NSStringFromClass(self.class)], self.adUnitId);
}

#pragma mark - Turn off auto impression and click
- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

@end


