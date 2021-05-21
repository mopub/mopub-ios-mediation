#import <VerizonAdsInlinePlacement/VerizonAdsInlinePlacement.h>
#import "MPVerizonBannerCustomEvent.h"
#if __has_include("MoPub.h")
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#endif
#import "VerizonAdapterConfiguration.h"
#import "MPVerizonBidCache.h"

@interface MPVerizonBannerCustomEvent ()<VASInlineAdFactoryDelegate, VASInlineAdViewDelegate>
@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, strong) VASInlineAdView *inlineAd;
@property (nonatomic, strong) VASInlineAdFactory *inlineFactory;

@end

@implementation MPVerizonBannerCustomEvent
@dynamic delegate;
@dynamic localExtras;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (id)init
{
    if([[UIDevice currentDevice] systemVersion].floatValue < 8.0)
    {
        return nil;
    }
    self = [super init];
    return self;
}

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPLogInfo(@"Requesting VAS banner with event info %@.", info);
    
    NSString *siteId = info[kMoPubVASAdapterSiteId];
    NSString *placementId = info[kMoPubVASAdapterPlacementId];
    
    if (siteId.length == 0 || placementId.length == 0)
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"Error occurred while fetching content for requestor [%@]", NSStringFromClass([self class])]
                                            underlying:nil];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
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
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    [VerizonAdapterConfiguration setCachedInitializationParameters:info];
    VASInlineAdSize *requestedSize = [[VASInlineAdSize alloc] initWithWidth:size.width height:size.height];
    
    self.inlineFactory = [[VASInlineAdFactory alloc] initWithPlacementId:placementId adSizes:@[requestedSize] vasAds:[VASAds sharedInstance] delegate:self];
    
    VASBid *bid = [MPVerizonBidCache.sharedInstance bidForPlacementId:placementId];
    
    if (bid) {
        [self.inlineFactory loadBid:bid inlineAdDelegate:self];
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
        
        [self.inlineFactory setRequestMetadata:metadataBuilder.build];
        [self.inlineFactory load:self];
    }
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

- (NSString *) getAdNetworkId {
    return (self.inlineAd) ? self.inlineAd.placementId : @"";
}

#pragma mark - VASInlineAdFactoryDelegate

- (void)inlineAdFactory:(nonnull VASInlineAdFactory *)adFactory didFailWithError:(nonnull VASErrorInfo *)errorInfo
{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate inlineAdAdapter:strongSelf didFailToLoadAdWithError:errorInfo];
        }
    });
    
    MPLogInfo(@"VAS ad factory %@ failed inline loading with error (%ld) %@", adFactory, (long)errorInfo.code, errorInfo.description);
}

- (void)inlineAdFactory:(nonnull VASInlineAdFactory *)adFactory didLoadInlineAd:(nonnull VASInlineAdView *)inlineAd
{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            self.inlineAd = inlineAd;
            
            inlineAd.frame = CGRectMake(0, 0, inlineAd.adSize.width, inlineAd.adSize.height);
            [strongSelf.delegate inlineAdAdapter:strongSelf didLoadAdWithAdView:inlineAd];
            
            MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        }
    });
    
    MPLogInfo(@"VAS banner %@ did load, creative ID %@", inlineAd, inlineAd.creativeInfo.creativeId);
}

#pragma mark - VASInlineAdViewDelegate

- (void)inlineAdDidFail:(VASInlineAdView *)inlineAd withError:(VASErrorInfo *)errorInfo {}

- (void)inlineAdDidExpand:(VASInlineAdView *)inlineAd
{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate inlineAdAdapterWillBeginUserAction:strongSelf];
        }
    });
    
    MPLogInfo(@"VAS banner %@ will present modal.", inlineAd);
}

- (void)inlineAdDidCollapse:(VASInlineAdView *)inlineAd
{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate inlineAdAdapterDidEndUserAction:strongSelf];
        }
    });
    
    MPLogInfo(@"VAS banner %@ did dismiss modal.", inlineAd);
}

- (void)inlineAdClicked:(VASInlineAdView *)inlineAd
{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate inlineAdAdapterDidEndUserAction:strongSelf];
            
            if (!strongSelf.didTrackClick)
            {
                [strongSelf.delegate inlineAdAdapterDidTrackClick:strongSelf];
                strongSelf.didTrackClick = YES;
            }
        }
    });
    
    MPLogInfo(@"VAS banner %@ was clicked.", inlineAd);
}

- (void)inlineAdDidLeaveApplication:(VASInlineAdView *)inlineAd
{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate inlineAdAdapterWillLeaveApplication:strongSelf];
        }
    });
    
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)inlineAdDidResize:(VASInlineAdView *)inlineAd {}

- (nullable UIViewController *)inlineAdPresentingViewController
{
    return [self.delegate inlineAdAdapterViewControllerForPresentingModalView:self];
}

- (void)inlineAd:(nonnull VASInlineAdView *)inlineAd event:(nonnull NSString *)eventId source:(nonnull NSString *)source arguments:(nonnull NSDictionary<NSString *,id> *)arguments
{
    MPLogTrace(@"VAS inlineAdEvent: %@, source: %@, eventId: %@, arguments: %@", inlineAd, source, eventId, arguments);
    if ([eventId isEqualToString:kMoPubVASAdImpressionEventId]) {
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof__(self) strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf.delegate inlineAdAdapterDidTrackImpression:strongSelf];
                MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(strongSelf.class)], [strongSelf getAdNetworkId]);
                MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(strongSelf.class)], [strongSelf getAdNetworkId]);
            }
        });
    }
}

- (void)inlineAdDidRefresh:(nonnull VASInlineAdView *)inlineAd {}

#pragma mark - Super Auction

+ (void)requestBidWithPlacementId:(nonnull NSString *)placementId
                          adSizes:(nonnull NSArray<VASInlineAdSize *> *)adSizes
                       completion:(nonnull VASBidRequestCompletionHandler)completion
{
    VASRequestMetadataBuilder *metaDataBuilder = [[VASRequestMetadataBuilder alloc] init];
    metaDataBuilder.mediator = VerizonAdapterConfiguration.mediator;
    
    [VASInlineAdFactory requestBidForPlacementId:placementId
                                         adSizes:adSizes
                                 requestMetadata:metaDataBuilder.build
                                          vasAds:[VASAds sharedInstance]
                                      completion:^(VASBid * _Nullable bid, VASErrorInfo * _Nullable errorInfo) {
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
