

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

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    [self requestAdWithSize: size customEventInfo: info adMarkup: nil];
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup{
    NSString *appId = info[@"appId"];
    NSArray *allZoneIds = info[@"allZoneIds"];
    NSError *error = [AdColonyAdapterUtility validateAppId:appId andZoneIds:allZoneIds];
    if (error) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.zoneId = info[@"zoneId"];
    if (self.zoneId.length == 0) {
        self.zoneId = allZoneIds[0];
    }
    
    
    // Cache the initialization parameters
    [AdColonyAdapterConfiguration updateInitializationParameters:info];
    NSString *userId = [info objectForKey:@"userId"];
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId allZoneIds:allZoneIds userId:userId callback:^(NSError *error){
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
