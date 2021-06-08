#import "MPVerizonRewardedVideoCustomEvent.h"
#import "MPVerizonInterstitialCustomEvent.h"
#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif
#import <VerizonAdsInterstitialPlacement/VASInterstitialAd.h>
#import <VerizonAdsInterstitialPlacement/VASInterstitialAdFactory.h>
#import "VerizonAdapterConfiguration.h"
#import "MPVerizonBidCache.h"

static NSString *const kMoPubVASAdapterAdUnit = @"adUnitID";
static NSString *const kMoPubVASAdapterDCN = @"dcn";
static NSString *const kMoPubVASAdapterVideoCompleteEventId = @"onVideoComplete";

@interface MPVerizonRewardedVideoCustomEvent () <VASInterstitialAdDelegate, VASInterstitialAdFactoryDelegate>
@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, assign) BOOL adReady;
@property (nonatomic, strong, nullable) VASInterstitialAdFactory *interstitialAdFactory;
@property (nonatomic, strong, nullable) VASInterstitialAd *interstitialAd;
@property (nonatomic, assign) BOOL isVideoCompletionEventCalled;
@end

@implementation MPVerizonRewardedVideoCustomEvent

@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (id)init
{
    if (self = [super init])
    {
        if ([[UIDevice currentDevice] systemVersion].floatValue < 8.0) {
            self = nil; // No support below minimum OS.
        }
    }
    return self;
}

- (BOOL)isRewardExpected
{
    return YES;
}

- (BOOL)hasAdAvailable
{
    return self.adReady;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.siteId);
    
    MPLogDebug(@"Requesting VAS rewarded video with event info %@.", info);
    
    self.adReady = NO;
    self.isVideoCompletionEventCalled = NO;
    self.siteId = info[kMoPubVASAdapterSiteId];
    NSString *placementId = info[kMoPubVASAdapterPlacementId];
    
    if (self.siteId.length == 0 || placementId.length == 0)
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"Error occurred while fetching content for requestor [%@]", NSStringFromClass([self class])]
                                            underlying:nil];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.siteId);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    if (![VASAds sharedInstance].initialized &&
        ![VASAds initializeWithSiteId:self.siteId])
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"VAS adapter not properly intialized yet."]
                                            underlying:nil];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.siteId);
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
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
    if([self hasAdAvailable])
    {
        [self.interstitialAd setImmersiveEnabled:YES];
        [self.interstitialAd showFromViewController:viewController];
        
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.siteId);
        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.siteId);
        
        [self.delegate fullscreenAdAdapterAdWillPresent:self];
    }
    else
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"No video available for playback."]
                                            underlying:nil];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.siteId);
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
        return;
    }
}

- (void)handleDidInvalidateAd
{
    [self.interstitialAd destroy];
    self.interstitialAd = nil;
}

- (void)handleDidPlayAd
{
    // If we no longer have an ad available, report back up to the application that this ad expired.
    if (![self hasAdAvailable]) {
        MPLogDebug(@"Ad expired.");
        
        [self.delegate fullscreenAdAdapterDidExpire:self];
    }
}

- (VASCreativeInfo *)creativeInfo
{
    return self.interstitialAd.creativeInfo;
}

- (NSString *)version
{
    return VerizonAdapterConfiguration.mediator;
}

- (void)interstitialAdClicked:(nonnull VASInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.siteId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fullscreenAdAdapterDidTrackClick:self];
        [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    });
}

- (void)interstitialAdDidClose:(nonnull VASInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.siteId);
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.siteId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fullscreenAdAdapterAdWillDismiss:self];
        [self.delegate fullscreenAdAdapterAdWillDisappear:self];
        [self.delegate fullscreenAdAdapterAdDidDisappear:self];
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
        
        self.interstitialAd = nil;
    });
}

- (void)interstitialAdDidFail:(nonnull VASInterstitialAd *)interstitialAd withError:(nonnull VASErrorInfo *)errorInfo
{
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:errorInfo], self.siteId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:errorInfo];
    });
}

- (void)interstitialAdDidLeaveApplication:(nonnull VASInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.siteId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
    });
}

- (void)interstitialAdDidShow:(nonnull VASInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.siteId);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.siteId);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.siteId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fullscreenAdAdapterAdDidPresent:self];
    });
}

- (void)interstitialAdEvent:(nonnull VASInterstitialAd *)interstitialAdEvent source:(nonnull NSString *)source eventId:(nonnull NSString *)eventId arguments:(nullable NSDictionary<NSString *,id> *)arguments
{
    MPLogTrace(@"VAS interstitialAdEvent: %@, source: %@, eventId: %@, arguments: %@", interstitialAdEvent, source, eventId, arguments);
    
    if ([eventId isEqualToString:kMoPubVASAdapterVideoCompleteEventId]
        && !self.isVideoCompletionEventCalled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MPReward *reward = [[MPReward alloc] initWithCurrencyAmount:@1];
            [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
            self.isVideoCompletionEventCalled = YES;
        });
    }
    else if ([eventId isEqualToString:kMoPubVASAdImpressionEventId]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate fullscreenAdAdapterDidTrackImpression:self];
        });
    }
}

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory didFailWithError:(nonnull VASErrorInfo *)errorInfo
{
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:errorInfo], self.siteId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:errorInfo];
    });
}

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory didLoadInterstitialAd:(nonnull VASInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.siteId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.interstitialAd = interstitialAd;
        self.adReady = YES;
        [self.delegate fullscreenAdAdapterDidLoadAd:self];
    });
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
