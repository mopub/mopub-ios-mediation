

#import "AdColonyBannerCustomEvent.h"
#import <AdColony/AdColony.h>
#import "AdColonyAdapterConfiguration.h"
#import "AdColonyController.h"
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
    [self requestAdWithSize: size customEventInfo: info adMarkup: nil];
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString * const appId      = info[APPLICATION_ID_KEY];
    NSString * const zoneId     = info[ZONE_ID_KEY];
    NSArray  * const allZoneIds = info[ALL_ZONE_IDS_KEY];
    
    NSError *appIdError = [AdColonyAdapterConfiguration validateParameter:appId forOperation:@"banner ad request"];
    if (appIdError) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:appIdError];
        return;
    }
    
    NSError *zoneIdError = [AdColonyAdapterConfiguration validateParameter:zoneId forOperation:@"banner ad request"];
    if (zoneIdError) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:zoneIdError];
        return;
    }
    self.zoneId = zoneId;
    
    NSError *allZoneIdsError = [AdColonyAdapterConfiguration validateZoneIds:allZoneIds forOperation:@"banner ad request"];
    if (allZoneIdsError) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:allZoneIdsError];
        return;
    }
    
    AdColonyAdSize adSize = [self standardizeAdSize:size];
    if (adSize.height == 0 && adSize.width == 0) {
        NSError *invalidSizeError = [AdColonyAdapterConfiguration createErrorWith:@"Aborting AdColony banner ad request"
                                                                        andReason:@"Requested banner ad size is not supported by AdColony"
                                                                    andSuggestion:@"Ensure requested banner ad size is supported by AdColony."];
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:invalidSizeError];
        return;
    }
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class)
                                       dspCreativeId:nil
                                             dspName:nil], self.zoneId);
    [AdColonyAdapterConfiguration updateInitializationParameters:info];
    [AdColonyController initializeAdColonyCustomEventWithAppId:appId
                                                    allZoneIds:allZoneIds
                                                        userId:nil
                                                      callback:^(NSError *error) {
        if (error) {
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.zoneId);
            [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        } else {
            MPLogInfo(@"Requesting AdColony banner ad with width: %.0f and height: %.0f", adSize.width, adSize.height);
            UIViewController *viewController = [self.delegate viewControllerForPresentingModalView];
            [AdColony requestAdViewInZone:self.zoneId
                                 withSize:adSize
                           viewController:viewController
                              andDelegate:self];
        }
    }];
}

- (AdColonyAdSize)standardizeAdSize:(CGSize)size {
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    if (width, height) {
        if (height >= kAdColonyAdSizeSkyscraper.height && width >= kAdColonyAdSizeSkyscraper.width) {
            return kAdColonyAdSizeSkyscraper;
        } else if (height >= kAdColonyAdSizeMediumRectangle.height && width >= kAdColonyAdSizeMediumRectangle.width) {
            return kAdColonyAdSizeMediumRectangle;
        } else if (height >= kAdColonyAdSizeLeaderboard.height && width >= kAdColonyAdSizeLeaderboard.width) {
            return kAdColonyAdSizeLeaderboard;
        } else if (height >= kAdColonyAdSizeBanner.height && width >= kAdColonyAdSizeBanner.width) {
            return kAdColonyAdSizeBanner;
        }
    }
    // Unsupported or invalid ad size requested. Returning return zero size to abort the request.
    return AdColonyAdSizeMake(0,0);
}

#pragma mark - Banner Delegate
- (void)adColonyAdViewDidLoad:(AdColonyAdView *)adView {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.zoneId);
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)adColonyAdViewDidFailToLoad:(AdColonyAdRequestError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.zoneId);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adColonyAdViewWillLeaveApplication:(AdColonyAdView *)adView {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.zoneId);
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

- (void)adColonyAdViewWillOpen:(AdColonyAdView *)adView {
    MPLogAdEvent([MPLogEvent adWillPresentModalForAdapter:NSStringFromClass(self.class)], self.zoneId);
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adColonyAdViewDidClose:(AdColonyAdView *)adView {
    MPLogAdEvent([MPLogEvent adDidDismissModalForAdapter:NSStringFromClass(self.class)], self.zoneId);
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adColonyAdViewDidReceiveClick:(AdColonyAdView *)adView {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.zoneId);
}
@end
