#import "MPVerizonNativeCustomEvent.h"
#if __has_include("MoPub.h")
#import "MPNativeAdError.h"
#import "MPLogging.h"
#endif
#import "MPVerizonNativeAdAdapter.h"
#import "MPVerizonBidCache.h"
#import "VerizonAdapterConfiguration.h"
#import <VerizonAdsNativePlacement/VerizonAdsNativePlacement.h>

@interface MPVerizonNativeCustomEvent() <VASNativeAdFactoryDelegate>

@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, strong) VASNativeAdFactory *nativeAdFactory;
@property (nonatomic, strong) MPVerizonNativeAdAdapter *nativeAdapter;
@property (nonatomic, assign) BOOL didTrackClick;

@end

#pragma mark - MPVerizonNativeCustomEvent

@implementation MPVerizonNativeCustomEvent

- (id)init
{
    if ([[UIDevice currentDevice] systemVersion].floatValue < 8.0)
    {
        return nil;
    }
    self = [super init];
    return self;
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPLogInfo(@"Requesting VAS native with event info %@.", info);
    
    self.siteId = info[kMoPubVASAdapterSiteId];
    NSString *placementId = info[kMoPubVASAdapterPlacementId];
    
    if (self.siteId.length == 0 || placementId.length == 0)
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:MoPubVASAdapterErrorInvalidConfig
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"Invalid configuration while initializing [%@]", NSStringFromClass([self class])]
                                            underlying:nil];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.siteId);
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    if (![VASAds sharedInstance].initialized &&
        ![VASAds initializeWithSiteId:self.siteId])
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:MoPubVASAdapterErrorNotInitialized
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"VAS adapter not properly intialized yet."]
                                            underlying:nil];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.siteId);
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }

    if (adMarkup.length > 0) {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:MoPubVASAdapterErrorNotInitialized
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"Advanced Bidding for native placements is not supported at this time. serverExtras key \" %@ \" should have no value.", kMoPubServerExtrasAdContent]
                                            underlying:nil];

        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.siteId);
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    [VerizonAdapterConfiguration setCachedInitializationParameters:info];
    
    self.nativeAdFactory = [[VASNativeAdFactory alloc] initWithPlacementId:placementId adTypes:@[@"100", @"simpleImage", @"simpleVideo"] vasAds:[VASAds sharedInstance] delegate:self];
    self.nativeAdapter = [[MPVerizonNativeAdAdapter alloc] initWithSiteId:self.siteId];

    VASBid *bid = [MPVerizonBidCache.sharedInstance bidForPlacementId:placementId];
    if (bid) {
        [self.nativeAdFactory loadBid:bid nativeAdDelegate:self.nativeAdapter];
    } else {
        [self.nativeAdFactory load:self.nativeAdapter];
    }
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.siteId);
}

- (NSString *)version
{
    return VerizonAdapterConfiguration.mediator;
}

#pragma mark - VASInlineAdFactoryDelegate

- (void)nativeAdFactory:(nonnull VASNativeAdFactory *)adFactory didFailWithError:(nullable VASErrorInfo *)errorInfo
{
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:errorInfo], self.siteId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:errorInfo];
    });
}

- (void)nativeAdFactory:(nonnull VASNativeAdFactory *)adFactory didLoadNativeAd:(nonnull VASNativeAd *)nativeAd
{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.siteId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.nativeAdapter setupWithVASNativeAd:nativeAd];
        [self.delegate nativeCustomEvent:self didLoadAd:[[MPNativeAd alloc] initWithAdAdapter:self.nativeAdapter]];
    });
}

@end
