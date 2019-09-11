#import <VerizonAdsInlinePlacement/VerizonAdsInlinePlacement.h>
#import <VerizonAdsStandardEdition/VerizonAdsStandardEdition.h>
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

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPLogInfo(@"Requesting VAS banner with event info %@.", info);
    
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
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
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
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    VASInlineAdSize *requestedSize = [[VASInlineAdSize alloc] initWithWidth:size.width height:size.height];
    
    [VASAds sharedInstance].locationEnabled = [MoPub sharedInstance].locationUpdatesEnabled;
    
    VASRequestMetadataBuilder *metaDataBuilder = [[VASRequestMetadataBuilder alloc] init];
    [metaDataBuilder setAppMediator:VerizonAdapterConfiguration.appMediator];
    self.inlineFactory = [[VASInlineAdFactory alloc] initWithPlacementId:placementId adSizes:@[requestedSize] vasAds:[VASAds sharedInstance] delegate:self];
    [self.inlineFactory setRequestMetadata:metaDataBuilder.build];
    
    VASBid *bid = [MPVerizonBidCache.sharedInstance bidForPlacementId:placementId];
    
    if (bid) {
        [self.inlineFactory loadBid:bid inlineAdDelegate:self];
    } else {
        [self.inlineFactory load:self];
    }
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

- (NSString *) getAdNetworkId {
    return (self.inlineAd) ? self.inlineAd.placementId : @"";
}

#pragma mark - VASInlineAdFactoryDelegate

- (void)inlineAdFactory:(nonnull VASInlineAdFactory *)adFactory cacheLoadedNumRequested:(NSInteger)numRequested numReceived:(NSInteger)numReceived {}

- (void)inlineAdFactory:(nonnull VASInlineAdFactory *)adFactory cacheUpdatedWithCacheSize:(NSInteger)cacheSize {}

- (void)inlineAdFactory:(nonnull VASInlineAdFactory *)adFactory didFailWithError:(nonnull VASErrorInfo *)errorInfo
{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate bannerCustomEvent:strongSelf didFailToLoadAdWithError:errorInfo];
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
            [strongSelf.delegate bannerCustomEvent:strongSelf didLoadAd:inlineAd];
            [strongSelf.delegate trackImpression];
            
            MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
            MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
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
            [strongSelf.delegate bannerCustomEventWillBeginAction:strongSelf];
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
            [strongSelf.delegate bannerCustomEventDidFinishAction:strongSelf];
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
            [strongSelf.delegate bannerCustomEventDidFinishAction:strongSelf];
            
            if (!strongSelf.didTrackClick)
            {
                [strongSelf.delegate trackClick];
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
            [strongSelf.delegate bannerCustomEventWillLeaveApplication:strongSelf];
        }
    });
    
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)inlineAdDidResize:(VASInlineAdView *)inlineAd {}

- (nullable UIViewController *)adPresentingViewController
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)inlineAdEvent:(VASInlineAdView *)inlineAd source:(NSString *)source eventId:(NSString *)eventId arguments:(NSDictionary<NSString *, id> *)arguments {}

- (void)inlineAdDidRefresh:(nonnull VASInlineAdView *)inlineAd {}

#pragma mark - Super Auction

+ (void)requestBidWithPlacementId:(nonnull NSString *)placementId
                          adSizes:(nonnull NSArray<VASInlineAdSize *> *)adSizes
                       completion:(nonnull VASBidRequestCompletionHandler)completion
{
    VASRequestMetadataBuilder *metaDataBuilder = [[VASRequestMetadataBuilder alloc] init];
    [metaDataBuilder setAppMediator:VerizonAdapterConfiguration.appMediator];
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
@implementation MPMillennialBannerCustomEvent
@end
