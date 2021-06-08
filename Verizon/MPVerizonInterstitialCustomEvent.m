#import <VerizonAdsInterstitialPlacement/VerizonAdsInterstitialPlacement.h>
#import "MPVerizonInterstitialCustomEvent.h"
#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif
#import "VerizonAdapterConfiguration.h"
#import "MPVerizonBidCache.h"

@interface MPVerizonInterstitialCustomEvent () <VASInterstitialAdFactoryDelegate, VASInterstitialAdDelegate>

@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, strong) VASInterstitialAdFactory *interstitialAdFactory;
@property (nonatomic, strong) VASInterstitialAd *interstitialAd;

@end

@implementation MPVerizonInterstitialCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

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
    self.interstitialAd = nil;
}

- (BOOL)hasAdAvailable {
    return (self.interstitialAd != nil);
}

- (BOOL)isRewardExpected {
    return NO;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPLogInfo(@"Requesting VAS interstitial with event info %@.", info);
    
    NSString *siteId = info[kMoPubVASAdapterSiteId];
    NSString *placementId = info[kMoPubVASAdapterPlacementId];
    
    if (siteId.length == 0 || placementId.length == 0)
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"Error occurred while fetching content for requestor [%@]", NSStringFromClass([self class])]
                                            underlying:nil];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    if (![VASAds sharedInstance].initialized &&
        ![VASAds initializeWithSiteId:siteId])
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"VAS adapter not properly intialized yet."]
                                            underlying:nil];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }

    [VerizonAdapterConfiguration setCachedInitializationParameters:info];
    
    self.interstitialAdFactory = [[VASInterstitialAdFactory alloc] initWithPlacementId:placementId vasAds:[VASAds sharedInstance] delegate:self];
    
    VASBid *bid = [MPVerizonBidCache.sharedInstance bidForPlacementId:placementId];
    if (bid) {
        [self.interstitialAdFactory loadBid:bid interstitialAdDelegate:self];
    } else {
        VASRequestMetadataBuilder *metadataBuilder = [[VASRequestMetadataBuilder alloc] initWithRequestMetadata:[VASAds sharedInstance].requestMetadata];
        metadataBuilder.mediator = VerizonAdapterConfiguration.mediator;
        
        MPLogInfo(@"%@: %@", kMoPubRequestMetadataAdContent, adMarkup);
        
        if (adMarkup.length > 0) {
            NSMutableDictionary<NSString *, id> *placementData =
            [NSMutableDictionary dictionaryWithDictionary:
             @{
                 kMoPubRequestMetadataAdContent : adMarkup,
                 @"overrideWaterfallProvider"  : @"waterfallprovider/sideloading"
             }
             ];
            
            [metadataBuilder setPlacementData:placementData];
        }
        
        [self.interstitialAdFactory setRequestMetadata:metadataBuilder.build];
        [self.interstitialAdFactory load:self];
    }
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
    [self.interstitialAd setImmersiveEnabled:YES];
    [self.interstitialAd showFromViewController:viewController];
    
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (NSString *) getAdNetworkId {
    return (self.interstitialAd) ? self.interstitialAd.placementId : @"";
}

#pragma mark - VASInterstitialAdFactoryDelegate

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory didFailWithError:(nonnull VASErrorInfo *)errorInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:errorInfo];
    });
    
    MPLogInfo(@"VAS interstitial failed with error %@.", errorInfo.description);
}

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory didLoadInterstitialAd:(nonnull VASInterstitialAd *)interstitialAd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.interstitialAd = interstitialAd;
        [self.delegate fullscreenAdAdapterDidLoadAd:self];
            
        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    });
    
    MPLogInfo(@"VAS interstitial %@ did load, creative ID %@.", interstitialAd, interstitialAd.creativeInfo.creativeId);
}

#pragma mark - VASInterstitialAdViewDelegate

- (void)interstitialAdClicked:(nonnull VASInterstitialAd *)interstitialAd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.didTrackClick)  {
            MPLogInfo(@"VAS interstitial %@ tracking click.", interstitialAd);
            [self.delegate fullscreenAdAdapterDidReceiveTap:self];
            [self.delegate fullscreenAdAdapterDidTrackClick:self];
            self.didTrackClick = YES;
            MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        }
        else {
            MPLogInfo(@"VAS interstitial %@ ignoring duplicate click.", interstitialAd);
        }
    });
}

- (void)interstitialAdDidFail:(nonnull VASInterstitialAd *)interstitialAd withError:(nonnull VASErrorInfo *)errorInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fullscreenAdAdapterDidExpire:self];
        [self invalidate];
    });
    
    MPLogInfo(@"VAS interstitial %@ has expired.", interstitialAd);
}

- (void)interstitialAdDidLeaveApplication:(nonnull VASInterstitialAd *)interstitialAd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
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
            MPLogInfo(@"VAS interstial %@ will present.", interstitialAd);
            [self.delegate fullscreenAdAdapterAdWillPresent:self];
            MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            
            MPLogInfo(@"VAS interstitial %@ did present.", interstitialAd);
            [self.delegate fullscreenAdAdapterAdDidPresent:self];
            MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        }
    });
}

- (void)interstitialAdDidClose:(nonnull VASInterstitialAd *)interstitialAd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MPLogInfo(@"VAS interstitial %@ will dismiss.", interstitialAd);
        MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapterAdWillDismiss:self];
        [self.delegate fullscreenAdAdapterAdWillDisappear:self];
        
        MPLogInfo(@"VAS interstitial %@ did dismiss.", interstitialAd);
        MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        
        [self.delegate fullscreenAdAdapterAdDidDisappear:self];
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
        
        [self invalidate];
    });
}

- (void)interstitialAdEvent:(nonnull VASInterstitialAd *)interstitialAd source:(nonnull NSString *)source eventId:(nonnull NSString *)eventId arguments:(nullable NSDictionary<NSString *,id> *)arguments
{
    MPLogTrace(@"VAS interstitialAdEvent: %@, source: %@, eventId: %@, arguments: %@", interstitialAd, source, eventId, arguments);
    if ([eventId isEqualToString:kMoPubVASAdImpressionEventId]) {
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof__(self) strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf.delegate fullscreenAdAdapterDidTrackImpression:strongSelf];
            }
        });
    }
}

#pragma mark - Super Auction

+ (void)requestBidWithPlacementId:(nonnull NSString *)placementId
                       completion:(nonnull VASBidRequestCompletionHandler)completion
{
    VASRequestMetadataBuilder *metaDataBuilder = [[VASRequestMetadataBuilder alloc] init];
    metaDataBuilder.mediator = VerizonAdapterConfiguration.mediator;
    [VASInterstitialAdFactory requestBidForPlacementId:placementId requestMetadata:metaDataBuilder.build vasAds:[VASAds sharedInstance] completionHandler:^(VASBid * _Nullable bid, VASErrorInfo * _Nullable errorInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bid) {
                [MPVerizonBidCache.sharedInstance storeBid:bid
                                            forPlacementId:placementId
                                                 untilDate:[NSDate dateWithTimeIntervalSinceNow:kMoPubVASAdapterSATimeoutInterval]];
            }
            completion(bid,errorInfo);
        });
    }];
}

@end
