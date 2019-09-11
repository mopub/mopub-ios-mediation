#import "MPVerizonRewardedVideoCustomEvent.h"
#import "MPVerizonInterstitialCustomEvent.h"
#import "MPLogging.h"
#import <VerizonAdsStandardEdition/VerizonAdsStandardEdition.h>
#import <VerizonAdsInterstitialPlacement/VASInterstitialAd.h>
#import <VerizonAdsInterstitialPlacement/VASInterstitialAdFactory.h>
#import "VerizonAdapterConfiguration.h"

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

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary<NSString *, id> *)info
{
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.siteId);
    
    MPLogDebug(@"Requesting VAS rewarded video with event info %@.", info);
    
    self.adReady = NO;
    self.isVideoCompletionEventCalled = NO;
    
    __strong __typeof__(self.delegate) delegate = self.delegate;
    
    self.siteId = info[kMoPubVASAdapterSiteId];
    if (self.siteId.length == 0)
    {
        self.siteId = info[kMoPubMillennialAdapterSiteId];
    }
    
    NSString *placementId = info[kMoPubVASAdapterPlacementId];
    if (placementId.length == 0)
    {
        placementId = info[kMoPubMillennialAdapterPlacementId];
    }
    
    if (self.siteId.length == 0 || placementId.length == 0)
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"Error occurred while fetching content for requestor [%@]", NSStringFromClass([self class])]
                                            underlying:nil];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.siteId);
        [delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        return;
    }
    
    if (![VASAds sharedInstance].initialized &&
        ![VASStandardEdition initializeWithSiteId:self.siteId])
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"VAS adapter not properly intialized yet."]
                                            underlying:nil];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.siteId);
        [delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        return;
    }
    
    [VASAds sharedInstance].locationEnabled = [MoPub sharedInstance].locationUpdatesEnabled;
    
    VASRequestMetadataBuilder *metaDataBuilder = [[VASRequestMetadataBuilder alloc] init];
    [metaDataBuilder setAppMediator:VerizonAdapterConfiguration.appMediator];
    self.interstitialAdFactory = [[VASInterstitialAdFactory alloc] initWithPlacementId:placementId vasAds:[VASAds sharedInstance] delegate:self];
    [self.interstitialAdFactory setRequestMetadata:metaDataBuilder.build];
    
    [self.interstitialAdFactory load:self];
}

- (BOOL)hasAdAvailable
{
    return self.adReady;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if([self hasAdAvailable])
    {
        [self.interstitialAd setImmersiveEnabled:YES];
        [self.interstitialAd showFromViewController:viewController];
        
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.siteId);
        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.siteId);
        
        [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    }
    else
    {
        NSError *error = [VASErrorInfo errorWithDomain:kMoPubVASAdapterErrorDomain
                                                  code:VASCoreErrorAdFetchFailure
                                                   who:kMoPubVASAdapterErrorWho
                                           description:[NSString stringWithFormat:@"No video available for playback."]
                                            underlying:nil];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.siteId);
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
        return;
    }
}

- (void)handleCustomEventInvalidated
{
    [self.interstitialAd destroy];
    self.interstitialAd = nil;
    self.delegate = nil;
}

- (void)handleAdPlayedForCustomEventNetwork
{
    // If we no longer have an ad available, report back up to the application that this ad expired.
    if (![self hasAdAvailable]) {
        MPLogDebug(@"Ad expired.");
        
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }
}

- (VASCreativeInfo *)creativeInfo
{
    return self.interstitialAd.creativeInfo;
}

- (NSString *)version
{
    return VerizonAdapterConfiguration.appMediator;
}

- (void)interstitialAdClicked:(nonnull VASInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.siteId);
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate rewardedVideoDidReceiveTapEventForCustomEvent:strongSelf];
            [strongSelf.delegate trackClick];
        }
    });
}

- (void)interstitialAdDidClose:(nonnull VASInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.siteId);
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.siteId);
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate rewardedVideoWillDisappearForCustomEvent:strongSelf];
            [strongSelf.delegate rewardedVideoDidDisappearForCustomEvent:strongSelf];
            strongSelf.interstitialAd = nil;
            strongSelf.delegate = nil;
        }
    });
}

- (void)interstitialAdDidFail:(nonnull VASInterstitialAd *)interstitialAd withError:(nonnull VASErrorInfo *)errorInfo
{
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:errorInfo], self.siteId);
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate rewardedVideoDidFailToPlayForCustomEvent:strongSelf error:errorInfo];
        }
    });
}

- (void)interstitialAdDidLeaveApplication:(nonnull VASInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], self.siteId);
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate rewardedVideoWillLeaveApplicationForCustomEvent:strongSelf];
        }
    });
}

- (void)interstitialAdDidShow:(nonnull VASInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.siteId);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.siteId);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.siteId);
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate rewardedVideoDidAppearForCustomEvent:strongSelf];
            [strongSelf.delegate trackImpression];
        }
    });
}

- (void)interstitialAdEvent:(nonnull VASInterstitialAd *)interstitialAdEvent source:(nonnull NSString *)source eventId:(nonnull NSString *)eventId arguments:(nullable NSDictionary<NSString *,id> *)arguments
{
    MPLogTrace(@"VAS interstitialAdEvent: %@, source: %@, eventId: %@, arguments: %@", interstitialAdEvent, source, eventId, arguments);
    
    if ([eventId isEqualToString:kMoPubVASAdapterVideoCompleteEventId]
        && !self.isVideoCompletionEventCalled
        ) {
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof__(self) strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyAmount:@1];
                [strongSelf.delegate rewardedVideoShouldRewardUserForCustomEvent:strongSelf reward:reward];
                strongSelf.isVideoCompletionEventCalled = YES;
            }
        });
    }
}

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory cacheLoadedNumRequested:(NSInteger)numRequested numReceived:(NSInteger)numReceived
{
    MPLogDebug(@"VAS interstitial factory cache loaded with requested: %lu", (unsigned long)numRequested);
}

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory cacheUpdatedWithCacheSize:(NSInteger)cacheSize
{
    MPLogDebug(@"VAS interstitial factory cache updated with size: %lu", (unsigned long)cacheSize);
}

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory didFailWithError:(nonnull VASErrorInfo *)errorInfo
{
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:errorInfo], self.siteId);
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.delegate rewardedVideoDidFailToLoadAdForCustomEvent:strongSelf error:errorInfo];
        }
    });
}

- (void)interstitialAdFactory:(nonnull VASInterstitialAdFactory *)adFactory didLoadInterstitialAd:(nonnull VASInterstitialAd *)interstitialAd
{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.siteId);
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf.interstitialAd = interstitialAd;
            strongSelf.adReady = YES;
            [strongSelf.delegate rewardedVideoDidLoadAdForCustomEvent:strongSelf];
        }
    });
}

@end
