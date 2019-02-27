///
///  @file
///  @brief Implementation for MPVerizonInterstitialCustomEvent
///
///  @copyright Copyright (c) 2019 Verizon. All rights reserved.
///

#import <VerizonAdsInterstitialPlacement/VerizonAdsInterstitialPlacement.h>
#import <VerizonAdsStandardEdition/VerizonAdsStandardEdition.h>
#import "MPVerizonInterstitialCustomEvent.h"
#import "MPLogging.h"
#import "VerizonAdapterConfiguration.h"
#import "VerizonBidCache.h"

@interface MPVerizonInterstitialCustomEvent () <VASInterstitialAdFactoryDelegate, VASInterstitialAdDelegate>

@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, strong) VASInterstitialAdFactory *interstitialAdFactory;
@property (nonatomic, strong) VASInterstitialAd *interstitialAd;

@end

@implementation MPVerizonInterstitialCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (id)init {
    if ([[UIDevice currentDevice] systemVersion].floatValue < 8.0) {
        return nil;
    }
    self = [super init];
    return self;
}

- (void)invalidate {
    self.delegate = nil;
    self.interstitialAd = nil;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary<NSString *, id> *)info {
    MPLogDebug(@"Requesting VAS interstitial with event info %@.", info);

    __strong __typeof__(self.delegate) delegate = self.delegate;
    
    NSString *siteId = info[kMoPubVASAdapterSiteId];
    if (siteId.length == 0) {
        siteId = info[kMoPubMillennialAdapterSiteId];
    }
    NSString *placementId = info[kMoPubVASAdapterPlacementId];
    if (placementId.length == 0) {
        placementId = info[kMoPubMillennialAdapterPlacementId];
    }
    if (siteId.length == 0 || placementId.length == 0) {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"Error occurred while fetching content for requestor [%@]", NSStringFromClass([self class])]
                                            underlying:nil];
        MPLogError(@"%@", [error localizedDescription]);
        [delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    if (![VASAds sharedInstance].initialized &&
        ![VASStandardEdition initializeWithSiteId:siteId]) {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"VAS adapter not properly intialized yet."]
                                            underlying:nil];
        MPLogError(@"%@", [error localizedDescription]);
        [delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }

    VASRequestMetadataBuilder *metaDataBuilder = [[VASRequestMetadataBuilder alloc] init];
    [metaDataBuilder setAppMediator:VerizonAdapterConfiguration.appMediator];
    self.interstitialAdFactory = [[VASInterstitialAdFactory alloc] initWithPlacementId:placementId vasAds:[VASAds sharedInstance] delegate:self];
    [self.interstitialAdFactory setRequestMetadata:metaDataBuilder.build];
    
    VASBid *bid = [VerizonBidCache.sharedInstance bidForPlacementId:placementId];
    if (bid) {
        [self.interstitialAdFactory loadBid:bid interstitialAdDelegate:self];
    } else {
        [self.interstitialAdFactory load:self];
    }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitialAd setImmersiveEnabled:YES];
    [self.interstitialAd showFromViewController:rootViewController];
}

#pragma mark - VASInterstitialAdFactoryDelegate

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory cacheLoadedNumRequested:(NSInteger)numRequested numReceived:(NSInteger)numReceived {}

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory cacheUpdatedWithCacheSize:(NSInteger)cacheSize {}


- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory didFailWithError:(nonnull VASErrorInfo *)errorInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self.delegate) delegate = self.delegate;
        MPLogWarn(@"VAS interstitial failed with error %@.", errorInfo.description);
        [delegate interstitialCustomEvent:self didFailToLoadAdWithError:errorInfo];
    });
}

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory didLoadInterstitialAd:(nonnull VASInterstitialAd *)interstitialAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        MPLogDebug(@"VAS interstitial %@ did load, creative ID %@.", interstitialAd, interstitialAd.creativeInfo.creativeId);
        self.interstitialAd = interstitialAd;
        [self.delegate interstitialCustomEvent:self didLoadAd:interstitialAd];
    });
}

#pragma mark - VASInterstitialAdViewDelegate

- (void)interstitialAdClicked:(nonnull VASInterstitialAd *)interstitialAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self.delegate) delegate = self.delegate;
        if (!self.didTrackClick) {
            MPLogDebug(@"VAS interstitial %@ tracking click.", interstitialAd);
            [delegate trackClick];
            self.didTrackClick = YES;
            [delegate interstitialCustomEventDidReceiveTapEvent:self];
        } else {
            MPLogDebug(@"VAS interstitial %@ ignoring duplicate click.", interstitialAd);
        }
    });
}

- (void)interstitialAdDidFail:(nonnull VASInterstitialAd *)interstitialAd withError:(nonnull VASErrorInfo *)errorInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        MPLogWarn(@"VAS interstitial %@ has expired.", interstitialAd);
        [self.delegate interstitialCustomEventDidExpire:self];
        [self invalidate];
    });
}

- (void)interstitialAdDidLeaveApplication:(nonnull VASInterstitialAd *)interstitialAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        MPLogDebug(@"VAS interstitial %@ leaving app.", interstitialAd);
        [self.delegate interstitialCustomEventWillLeaveApplication:self];
    });
}

- (void)interstitialAdDidShow:(nonnull VASInterstitialAd *)interstitialAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self.delegate) delegate = self.delegate;
        
        MPLogDebug(@"VAS interstial %@ will display.", interstitialAd);
        [self.delegate interstitialCustomEventWillAppear:self];
        
        MPLogDebug(@"VAS interstitial %@ did appear.", interstitialAd);
        [delegate interstitialCustomEventDidAppear:self];
        [delegate trackImpression];
    });
}

- (void)interstitialAdDidClose:(nonnull VASInterstitialAd *)interstitialAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self.delegate) delegate = self.delegate;
        
        MPLogDebug(@"VAS interstitial %@ will dismiss.", interstitialAd);
        [self.delegate interstitialCustomEventWillDisappear:self];
        
        MPLogDebug(@"VAS interstitial %@ did dismiss.", interstitialAd);
        [delegate interstitialCustomEventDidDisappear:self];
        [self invalidate];
    });

}

- (void)interstitialAdEvent:(nonnull VASInterstitialAd *)interstitialAd source:(nonnull NSString *)source eventId:(nonnull NSString *)eventId arguments:(nonnull NSDictionary<NSString *,id> *)arguments {}

#pragma mark - Super Auction

+ (void)requestBidWithPlacementId:(nonnull NSString *)placementId
                       completion:(nonnull VASBidRequestCompletionHandler)completion {
    VASRequestMetadataBuilder *metaDataBuilder = [[VASRequestMetadataBuilder alloc] init];
    [metaDataBuilder setAppMediator:VerizonAdapterConfiguration.appMediator];
    [VASInterstitialAdFactory requestBidForPlacementId:placementId requestMetadata:metaDataBuilder.build vasAds:[VASAds sharedInstance] completionHandler:^(VASBid * _Nullable bid, VASErrorInfo * _Nullable errorInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bid) {
                [VerizonBidCache.sharedInstance storeBid:bid
                                          forPlacementId:placementId
                                               untilDate:[NSDate dateWithTimeIntervalSinceNow:kMoPubVASAdapterSATimeoutInterval]];
            }
            completion(bid,errorInfo);
        });
    }];
}

@end

@implementation MPMillennialInterstitialCustomEvent
@end
