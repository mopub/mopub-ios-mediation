//
//  MintegralInterstitialCustomEvent.m


#import "MintegralInterstitialCustomEvent.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>
#import <MTGSDKInterstitialVideo/MTGBidInterstitialVideoAdManager.h>
#import "MintegralAdapterConfiguration.h"
#if __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif

@interface MintegralInterstitialCustomEvent()<MTGInterstitialVideoDelegate, MTGBidInterstitialVideoDelegate>

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic,strong) NSTimer  *queryTimer;
@property (nonatomic, copy) NSString *adm;

@property (nonatomic, readwrite, strong) MTGInterstitialVideoAdManager *mtgInterstitialVideoAdManager;
@property (nonatomic,strong)  MTGBidInterstitialVideoAdManager *ivBidAdManager;
@end

@implementation MintegralInterstitialCustomEvent

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPLogInfo(@"requestInterstitialWithCustomEventInfo for Mintegral");
    NSString *appId = [info objectForKey:@"appId"];
    NSString *appKey = [info objectForKey:@"appKey"];
    NSString *unitId = [info objectForKey:@"unitId"];
    
    NSString *errorMsg = nil;

    if (!unitId) errorMsg = @"Invalid Mintegral unitId";
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:kMintegralErrorDomain code:-1500 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    if (![MintegralAdapterConfiguration isSDKInitialized]) {
        [MintegralAdapterConfiguration setGDPRInfo:info];
        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        [MintegralAdapterConfiguration sdkInitialized];
    }
    
    self.adUnitId = unitId;
    
    self.adm = adMarkup;
    if (self.adm) {
        MPLogInfo(@"Loading Mintegral Interstitial ad markup for Advanced Bidding");
        if (!_ivBidAdManager ) {
               _ivBidAdManager  = [[MTGBidInterstitialVideoAdManager alloc] initWithUnitID:self.adUnitId delegate:self];
            _ivBidAdManager.delegate = self;
        }
        [_ivBidAdManager loadAdWithBidToken:self.adm];
    }else{
        MPLogInfo(@"Loading Mintegral Interstitial ad");
        if (!_mtgInterstitialVideoAdManager) {
            _mtgInterstitialVideoAdManager = [[MTGInterstitialVideoAdManager alloc] initWithUnitID:self.adUnitId delegate:self];
        }
        [_mtgInterstitialVideoAdManager loadAd];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if (self.adm) {
        [_ivBidAdManager showFromViewController:rootViewController];
    }else{
        [_mtgInterstitialVideoAdManager showFromViewController:rootViewController];
    }
}

#pragma mark - MVInterstitialVideoAdLoadDelegate
- (void)onInterstitialVideoLoadSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEvent: didLoadAd:)]) {
        [self.delegate interstitialCustomEvent:self didLoadAd:nil];
    }
}

- (void)onInterstitialVideoLoadFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEvent: didFailToLoadAdWithError:)]) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)onInterstitialVideoShowSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventWillAppear:)]) {
        [self.delegate interstitialCustomEventWillAppear:self ];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventDidAppear:)]) {
        [self.delegate interstitialCustomEventDidAppear:self ];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(trackImpression)]) {
        [self.delegate trackImpression];
    }
}

- (void)onInterstitialVideoShowFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    
}

- (void)onInterstitialVideoAdClick:(MTGInterstitialVideoAdManager *_Nonnull)adManager{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventDidReceiveTapEvent:)]) {
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self ];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(trackClick)]) {
        [self.delegate trackClick];
    }
}

- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventWillDisappear:)]) {
        [self.delegate interstitialCustomEventWillDisappear:self ];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventDidDisappear:)]) {
        [self.delegate interstitialCustomEventDidDisappear:self ];
    }
}

@end
