#import "MintegralInterstitialCustomEvent.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>
#import <MTGSDKInterstitialVideo/MTGBidInterstitialVideoAdManager.h>
#import "MintegralAdapterConfiguration.h"

#if __has_include("MoPub.h")
#import "MoPub.h"
#import "MPError.h"
#import "MPLogging.h"
#endif

@interface MintegralInterstitialCustomEvent()<MTGInterstitialVideoDelegate, MTGBidInterstitialVideoDelegate>

@property (nonatomic, copy) NSString *adm;
@property (nonatomic, copy) NSString *adPlacementId;
@property (nonatomic, copy) NSString *mintegralAdUnitId;
@property (nonatomic, strong) NSTimer *queryTimer;

@property (nonatomic, readwrite, strong) MTGInterstitialVideoAdManager *mtgInterstitialVideoAdManager;
@property (nonatomic,strong) MTGBidInterstitialVideoAdManager *ivBidAdManager;
@end

@implementation MintegralInterstitialCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)hasAdAvailable {
    if (self.adm != nil) {
        return [self.ivBidAdManager isVideoReadyToPlayWithPlacementId:self.adPlacementId
                                                               unitId:self.mintegralAdUnitId];
    }
    
    return [self.mtgInterstitialVideoAdManager isVideoReadyToPlayWithPlacementId:self.adPlacementId
                                                                          unitId:self.mintegralAdUnitId];
}

- (BOOL)isRewardExpected {
    return NO;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    NSString *appId = [info objectForKey:@"appId"];
    NSString *appKey = [info objectForKey:@"appKey"];
    NSString *unitId = [info objectForKey:@"unitId"];
    NSString *placementId = [info objectForKey:@"placementId"];
    
    NSString *errorMsg = nil;
    
    if (!appId) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral appId. Failing ad request. Ensure the app ID is valid on the MoPub dashboard."];
    if (!appKey) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral appKey. Failing ad request. Ensure the app key is valid on the MoPub dashboard."];
    if (!unitId) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral unitId. Failing ad request. Ensure the unit ID is valid on the MoPub dashboard."];
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:kMintegralErrorDomain code:-1500 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        
        return;
    }
    
    self.mintegralAdUnitId = unitId;
    self.adPlacementId = placementId;
    self.adm = adMarkup;
    
    [MintegralAdapterConfiguration initializeMintegral:info setAppID:appId appKey:appKey];
    [MintegralAdapterConfiguration updateInitializationParameters:info];

    if (self.adm) {
        MPLogInfo(@"Loading Mintegral interstitial ad markup for Advanced Bidding");
        
        if (!_ivBidAdManager ) {
            _ivBidAdManager = [[MTGBidInterstitialVideoAdManager alloc] initWithPlacementId:placementId
                                                                                     unitId:unitId
                                                                                   delegate:self];
            _ivBidAdManager.delegate = self;
        }
        
        _ivBidAdManager.playVideoMute = [MintegralAdapterConfiguration isMute];
        [_ivBidAdManager loadAdWithBidToken:self.adm];
    } else {
        MPLogInfo(@"Loading Mintegral interstitial ad");
        
        if (!_mtgInterstitialVideoAdManager) {
            _mtgInterstitialVideoAdManager = [[MTGInterstitialVideoAdManager alloc] initWithPlacementId:placementId
                                                                                                 unitId:unitId
                                                                                               delegate:self];
        }
        
        _mtgInterstitialVideoAdManager.playVideoMute = [MintegralAdapterConfiguration isMute];
        [_mtgInterstitialVideoAdManager loadAd];
    }
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.mintegralAdUnitId);
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
    if (self.adm) {
        _ivBidAdManager.playVideoMute = [MintegralAdapterConfiguration isMute];
        [_ivBidAdManager showFromViewController:viewController];
    } else {
        _mtgInterstitialVideoAdManager.playVideoMute = [MintegralAdapterConfiguration isMute];
        [_mtgInterstitialVideoAdManager showFromViewController:viewController];
    }
    
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);
}

#pragma mark - MVInterstitialVideoAdLoadDelegate
- (void)onInterstitialVideoLoadSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)onInterstitialVideoLoadFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)onInterstitialVideoShowSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);

    [self.delegate fullscreenAdAdapterAdWillPresent:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
}

- (void)onInterstitialVideoShowFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.mintegralAdUnitId);
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
}

- (void)onInterstitialVideoAdClick:(MTGInterstitialVideoAdManager *_Nonnull)adManager{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);
    
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
}

- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);
    
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
}

- (void)onInterstitialVideoAdDidClosed:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.mintegralAdUnitId);
    
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

@end
