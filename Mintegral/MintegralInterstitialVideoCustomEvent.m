//
//  MintegralInterstitialVideoCustomEvent.m
//  MoPubSampleApp
//
//  Copyright © 2017年 MoPub. All rights reserved.
//

#import "MintegralInterstitialVideoCustomEvent.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>
#import <MTGSDKInterstitialVideo/MTGBidInterstitialVideoAdManager.h>
#import "MintegralAdapterHelper.h"

#if __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif

@interface MintegralInterstitialVideoCustomEvent()<MTGInterstitialVideoDelegate, MTGBidInterstitialVideoDelegate>

@property (nonatomic, copy) NSString *adUnit;
@property (nonatomic,strong) NSTimer  *queryTimer;
@property (nonatomic, copy) NSString *adm;

@property (nonatomic, readwrite, strong) MTGInterstitialVideoAdManager *mtgInterstitialVideoAdManager;
@property (nonatomic,strong)  MTGBidInterstitialVideoAdManager *ivBidAdManager;
@end


@implementation MintegralInterstitialVideoCustomEvent


- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    NSString *appId = [info objectForKey:@"appId"];
    NSString *appKey = [info objectForKey:@"appKey"];
    NSString *unitId = [info objectForKey:@"unitId"];
    
    NSString *errorMsg = nil;
//    if (!appId) errorMsg = @"Invalid Mintegral appId";
//    if (!appKey) errorMsg = @"Invalid Mintegral appKey";
    if (!unitId) errorMsg = @"Invalid Mintegral unitId";
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:kMintegralErrorDomain code:-1500 userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];

        return;
    } 
    
    
    if (![MintegralAdapterHelper isSDKInitialized]) {
        
        [MintegralAdapterHelper setGDPRInfo:info];
        [[MTGSDK sharedInstance] setAppID:appId ApiKey:appKey];
        [MintegralAdapterHelper sdkInitialized];
    }
    
    self.adUnit = unitId;
    
    self.adm = adMarkup;
    if (self.adm) {
        
        if (!_ivBidAdManager ) {
               _ivBidAdManager  = [[MTGBidInterstitialVideoAdManager alloc] initWithUnitID:self.adUnit delegate:self];
            _ivBidAdManager.delegate = self;
        }
        [_ivBidAdManager loadAdWithBidToken:self.adm];
            
    }else{
    
        if (!_mtgInterstitialVideoAdManager) {
            _mtgInterstitialVideoAdManager = [[MTGInterstitialVideoAdManager alloc] initWithUnitID:self.adUnit delegate:self];
        }
    
        [_mtgInterstitialVideoAdManager loadAd];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    // Subclasses may override this method to return NO to perform impression and click tracking
    // manually.
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


/**
 *  Called when the ad is successfully load , and is ready to be displayed
 *
 *  @param unitId - the unitId string of the Ad that was loaded.
 */
- (void)onInterstitialVideoLoadSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEvent: didLoadAd:)]) {
        [self.delegate interstitialCustomEvent:self didLoadAd:nil];
    }
}

/**
 *  Called when there was an error loading the ad.
 *
 *  @param unitId      - the unitId string of the Ad that failed to load.
 *  @param error       - error object that describes the exact error encountered when loading the ad.
 */
- (void)onInterstitialVideoLoadFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{

    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEvent: didFailToLoadAdWithError:)]) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}
/**
 *  Called when the ad display success
 *
 *  @param unitId - the unitId string of the Ad that display success.
 */
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

/**
 *  Called when the ad failed to display for some reason
 *
 *  @param unitId      - the unitId string of the Ad that failed to be displayed.
 *  @param error       - error object that describes the exact error encountered when showing the ad.
 */
- (void)onInterstitialVideoShowFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    //do nothing
}

/**
 *  Called when the ad is clicked
 *
 *  @param unitId - the unitId string of the Ad clicked.
 */
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
