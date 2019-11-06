

#import "AdColonyBannerCustomEvent.h"
#import <AdColony/AdColony.h>
#import "AdColonyAdapterConfiguration.h"
#import "AdColonyController.h"
#import "AdColonyAdapterUtility.h"
#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif

@interface AdColonyBannerCustomEvent () <AdColonyAdViewDelegate>

@property (nonatomic, retain) AdColonyAdView *adView;
@property (nonatomic, copy) NSString *zoneId;

@end

@implementation AdColonyBannerCustomEvent

#pragma mark - MPBannerCustomEvent Overridden Methods

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
    NSString *appId = info[ADC_APPLICATION_ID_KEY];
    NSArray *allZoneIds = info[ADC_ALL_ZONE_IDS_KEY];
    self.zoneId = info[ADC_ZONE_ID_KEY];
    NSError *error = [AdColonyAdapterUtility validateAppId:appId zonesList:allZoneIds andZone:self.zoneId];
    if (error) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    // Cache the initialization parameters
    [AdColonyAdapterConfiguration updateInitializationParameters:info];
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId allZoneIds:allZoneIds userId:nil callback:^(NSError *error){
        if (error) {
            [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        }else{
            AdColonyAdSize adSize = AdColonyAdSizeFromCGSize(size);
            UIViewController *viewController = [self.delegate viewControllerForPresentingModalView];
            [AdColony requestAdViewInZone:self.zoneId withSize:adSize viewController:viewController andDelegate:self];
        }
    }];
}

#pragma mark - Banner Delegate
- (void)adColonyAdViewDidLoad:(AdColonyAdView *)adView{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.zoneId);
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)adColonyAdViewDidFailToLoad:(AdColonyAdRequestError *)error{
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.zoneId);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adColonyAdViewWillLeaveApplication:(AdColonyAdView *)adView{
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.zoneId);
    [self.delegate bannerCustomEventWillLeaveApplication:self ];
}

- (void)adColonyAdViewWillOpen:(AdColonyAdView *)adView{
    MPLogAdEvent([MPLogEvent adWillPresentModalForAdapter:NSStringFromClass(self.class)], self.zoneId);
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adColonyAdViewDidClose:(AdColonyAdView *)adView{
    MPLogAdEvent([MPLogEvent adDidDismissModalForAdapter:NSStringFromClass(self.class)], self.zoneId);
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adColonyAdViewDidReceiveClick:(AdColonyAdView *)adView{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.zoneId);
}
@end
