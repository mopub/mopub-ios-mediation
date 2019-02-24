///
///  @file
///  @brief Implementation for MPVerizonBannerCustomEvent
///
///  @copyright Copyright (c) 2019 Verizon. All rights reserved.
///

#import <VerizonAdsInlinePlacement/VerizonAdsInlinePlacement.h>
#import <VerizonAdsStandardEdition/VerizonAdsStandardEdition.h>
#import "MPVerizonBannerCustomEvent.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "VerizonAdapterConfiguration.h"
#import "VerizonBidCache.h"

@interface MPVerizonBannerCustomEvent ()<VASInlineAdFactoryDelegate, VASInlineAdViewDelegate>
@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, strong) VASInlineAdView *inlineAd;
@property (nonatomic, strong) VASInlineAdFactory *inlineFactory;

@end

@implementation MPVerizonBannerCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (id)init {
    if([[UIDevice currentDevice] systemVersion].floatValue < 8.0) {
        return nil;
    }
    self = [super init];
    return self;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
    MPLogDebug(@"Requesting VAS banner with event info %@.", info);
    
    __strong __typeof__(self.delegate) delegate = self.delegate;

    NSString *dcn = info[kMoPubVASAdapterDCN];
    NSString *placementId = info[kMoPubVASAdapterAdUnit];
    
    if (dcn.length == 0 || placementId.length == 0) {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"Error occurred while fetching content for requestor [%@]", NSStringFromClass([self class])]
                                            underlying:nil];
        MPLogError(@"%@", [error localizedDescription]);
        [delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    if (![VASAds sharedInstance].initialized &&
        ![VerizonAdsStandardEdition initializeWithSiteId:dcn]) {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"VAS adapter not properly intialized yet."]
                                            underlying:nil];
        MPLogError(@"%@", [error localizedDescription]);
        [delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    VASInlineAdSize *requestedSize = [[VASInlineAdSize alloc] initWithWidth:size.width height:size.height];

    VASRequestMetadataBuilder *metaDataBuilder = [[VASRequestMetadataBuilder alloc] init];
    [metaDataBuilder setAppMediator:VerizonAdapterConfiguration.appMediator];
    self.inlineFactory = [[VASInlineAdFactory alloc] initWithPlacementId:placementId adSizes:@[requestedSize] requestMetadata:metaDataBuilder.build vasAds:[VASAds sharedInstance] delegate:self];
    
    VASBid *bid = [VerizonBidCache.sharedInstance bidForPlacementId:placementId];
    if (bid) {
        [self.inlineFactory loadBid:bid inlineAdDelegate:self];
    } else {
        [self.inlineFactory load:self];
    }
    
}


#pragma mark - VASInlineAdFactoryDelegate

- (void)adFactory:(nonnull VASInlineAdFactory *)adFactory cacheLoadedNumRequested:(NSInteger)numRequested numReceived:(NSInteger)numReceived {}

- (void)adFactory:(nonnull VASInlineAdFactory *)adFactory cacheUpdatedWithCacheSize:(NSInteger)cacheSize {}

- (void)adFactory:(nonnull VASInlineAdFactory *)adFactory didFailWithError:(nonnull VASErrorInfo *)errorInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MPLogWarn(@"VAS ad factory %@ failed inline loading with error (%ld) %@", adFactory, (long)errorInfo.code, errorInfo.description);
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:errorInfo];
    });
}

- (void)adFactory:(nonnull VASInlineAdFactory *)adFactory didLoadInlineAd:(nonnull VASInlineAdView *)inlineAd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MPLogDebug(@"VAS banner %@ did load, creative ID %@", inlineAd, inlineAd.creativeInfo.creativeId);
        
        self.inlineAd = inlineAd;
        
        __strong __typeof__(self.delegate) delegate = self.delegate;
        inlineAd.frame = CGRectMake(0, 0, inlineAd.adSize.width, inlineAd.adSize.height);
        [delegate bannerCustomEvent:self didLoadAd:inlineAd];
        [delegate trackImpression];
    });
}

#pragma mark - VASInlineAdViewDelegate

- (void)adDidFail:(VASInlineAdView *)inlineAd withError:(VASErrorInfo *)errorInfo {}

- (void)adDidExpand:(VASInlineAdView *)inlineAd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MPLogDebug(@"VAS banner %@ will present modal.", inlineAd);
        [self.delegate bannerCustomEventWillBeginAction:self];
    });
}

- (void)adDidCollapse:(VASInlineAdView *)inlineAd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MPLogDebug(@"VAS banner %@ did dismiss modal.", inlineAd);
        [self.delegate bannerCustomEventDidFinishAction:self];
    });
}

- (void)adClicked:(VASInlineAdView *)inlineAd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.didTrackClick) {
            MPLogDebug(@"VAS banner %@ was clicked.", inlineAd);
            [self.delegate trackClick];
            self.didTrackClick = YES;
        }
    });
}

- (void)adDidLeaveApplication:(VASInlineAdView *)inlineAd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MPLogDebug(@"VAS banner %@ will leave application", inlineAd);
        [self.delegate bannerCustomEventWillLeaveApplication:self];
    });
}

- (void)adDidResize:(VASInlineAdView *)inlineAd {}

- (nullable UIViewController *)adPresentingViewController
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adEvent:(VASInlineAdView *)inlineAd source:(NSString *)source eventId:(NSString *)eventId arguments:(NSDictionary<NSString *, id> *)arguments {}

- (void)adDidRefresh:(nonnull VASInlineAdView *)inlineAd {}


#pragma mark - Super Auction

+ (void)requestBidWithPlacementId:(nonnull NSString *)placementId
                          adSizes:(nonnull NSArray<VASInlineAdSize *> *)adSizes
                       completion:(nonnull VASBidRequestCompletionHandler)completion {
    VASRequestMetadataBuilder *metaDataBuilder = [[VASRequestMetadataBuilder alloc] init];
    [metaDataBuilder setAppMediator:VerizonAdapterConfiguration.appMediator];
    [VASInlineAdFactory requestBidForPlacementId:placementId
                                         adSizes:adSizes
                                 requestMetadata:metaDataBuilder.build
                                          vasAds:[VASAds sharedInstance]
                                      completion:^(VASBid * _Nullable bid, VASErrorInfo * _Nullable errorInfo) {
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

@implementation MPMillennialBannerCustomEvent
@end
