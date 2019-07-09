#import <VerizonAdsInterstitialPlacement/VerizonAdsInterstitialPlacement.h>
#import <VerizonAdsStandardEdition/VerizonAdsStandardEdition.h>
#import "MPVerizonInterstitialCustomEvent.h"
#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif
#import "VerizonAdapterConfiguration.h"
#import "VerizonBidCache.h"

@interface MPVerizonInterstitialCustomEvent () <VASInterstitialAdFactoryDelegate, VASInterstitialAdDelegate>

@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, strong) VASInterstitialAdFactory *interstitialAdFactory;
@property (nonatomic, strong) VASInterstitialAd *interstitialAd;

@end

@implementation MPVerizonInterstitialCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (id)init
{
    if ([[UIDevice currentDevice] systemVersion].floatValue < 8.0)
    {
        return nil;
    }
    self = [super init];
    return self;
}

- (void)invalidate
{
    self.delegate = nil;
    self.interstitialAd = nil;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPLogInfo(@"Requesting VAS interstitial with event info %@.", info);
    
    NSString *siteId = info[kMoPubVASAdapterSiteId];
    if (siteId.length == 0)
    {
        siteId = info[kMoPubMillennialAdapterSiteId];
    }
    NSString *placementId = info[kMoPubVASAdapterPlacementId];
    if (placementId.length == 0)
    {
        placementId = info[kMoPubMillennialAdapterPlacementId];
    }
    if (siteId.length == 0 || placementId.length == 0)
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"Error occurred while fetching content for requestor [%@]", NSStringFromClass([self class])]
                                            underlying:nil];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    if (![VASAds sharedInstance].initialized &&
        ![VASStandardEdition initializeWithSiteId:siteId])
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"VAS adapter not properly intialized yet."]
                                            underlying:nil];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
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
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitialAd setImmersiveEnabled:YES];
    [self.interstitialAd showFromViewController:rootViewController];
    
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (NSString *) getAdNetworkId {
    return (self.interstitialAd) ? self.interstitialAd.placementId : @"";
}

#pragma mark - VASInterstitialAdFactoryDelegate

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory cacheLoadedNumRequested:(NSInteger)numRequested numReceived:(NSInteger)numReceived {}

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory cacheUpdatedWithCacheSize:(NSInteger)cacheSize {}


- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory didFailWithError:(nonnull VASErrorInfo *)errorInfo
{
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate interstitialCustomEvent:strongSelf didFailToLoadAdWithError:errorInfo];
        }
    });
    
    MPLogInfo(@"VAS interstitial failed with error %@.", errorInfo.description);
}

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory didLoadInterstitialAd:(nonnull VASInterstitialAd *)interstitialAd
{
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf.interstitialAd = interstitialAd;
            [strongSelf.delegate interstitialCustomEvent:strongSelf didLoadAd:interstitialAd];
            
            MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        }
    });
    
    MPLogInfo(@"VAS interstitial %@ did load, creative ID %@.", interstitialAd, interstitialAd.creativeInfo.creativeId);
}

#pragma mark - VASInterstitialAdViewDelegate

- (void)interstitialAdClicked:(nonnull VASInterstitialAd *)interstitialAd
{
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (!strongSelf.didTrackClick)
            {
                MPLogInfo(@"VAS interstitial %@ tracking click.", interstitialAd);
                [strongSelf.delegate trackClick];
                strongSelf.didTrackClick = YES;
                [strongSelf.delegate interstitialCustomEventDidReceiveTapEvent:strongSelf];
                
                MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            } else
            {
                MPLogInfo(@"VAS interstitial %@ ignoring duplicate click.", interstitialAd);
            }
        }
    });
}

- (void)interstitialAdDidFail:(nonnull VASInterstitialAd *)interstitialAd withError:(nonnull VASErrorInfo *)errorInfo
{
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate interstitialCustomEventDidExpire:strongSelf];
            [strongSelf invalidate];
        }
    });
    
    MPLogInfo(@"VAS interstitial %@ has expired.", interstitialAd);
}

- (void)interstitialAdDidLeaveApplication:(nonnull VASInterstitialAd *)interstitialAd
{
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate interstitialCustomEventWillLeaveApplication:strongSelf];
        }
    });
    
    MPLogInfo(@"VAS interstitial %@ leaving app.", interstitialAd);
}

- (void)interstitialAdDidShow:(nonnull VASInterstitialAd *)interstitialAd
{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            MPLogInfo(@"VAS interstial %@ will display.", interstitialAd);
            [strongSelf.delegate interstitialCustomEventWillAppear:strongSelf];
            MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            
            MPLogInfo(@"VAS interstitial %@ did appear.", interstitialAd);
            [strongSelf.delegate interstitialCustomEventDidAppear:strongSelf];
            MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            
            [strongSelf.delegate trackImpression];
            MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        }
    });
}

- (void)interstitialAdDidClose:(nonnull VASInterstitialAd *)interstitialAd
{
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            MPLogInfo(@"VAS interstitial %@ will dismiss.", interstitialAd);
            MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            
            [strongSelf.delegate interstitialCustomEventWillDisappear:strongSelf];
            
            MPLogInfo(@"VAS interstitial %@ did dismiss.", interstitialAd);
            MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            
            [strongSelf.delegate interstitialCustomEventDidDisappear:strongSelf];
            [strongSelf invalidate];
        }
    });
}

- (void)interstitialAdEvent:(nonnull VASInterstitialAd *)interstitialAd source:(nonnull NSString *)source eventId:(nonnull NSString *)eventId arguments:(nullable NSDictionary<NSString *,id> *)arguments {}

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
