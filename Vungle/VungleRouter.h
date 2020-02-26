//
//  VungleRouter.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VungleSDK/VungleSDK.h>
#import <VungleSDK/VungleSDKNativeAds.h>

extern NSString *const kVungleAppIdKey;
extern NSString *const kVunglePlacementIdKey;
extern NSString *const kVungleFlexViewAutoDismissSeconds;
extern NSString *const kVungleUserId;
extern NSString *const kVungleOrdinal;
extern NSString *const kVungleStartMuted;
extern NSString *const kVungleSupportedOrientations;
extern NSString *const kVungleSDKCollectDevice;
extern NSString *const kVungleSDKMinSpaceForInit;
extern NSString *const kVungleSDKMinSpaceForAdRequest;
extern NSString *const kVungleSDKMinSpaceForAssetLoad;

extern const CGSize kVNGMRECSize;
extern const CGSize kVNGBannerSize;
extern const CGSize kVNGShortBannerSize;
extern const CGSize kVNGLeaderboardBannerSize;

@protocol VungleRouterDelegate;
@class VungleInstanceMediationSettings;

@interface VungleRouter : NSObject <VungleSDKDelegate, VungleSDKNativeAds>

+ (VungleRouter *)sharedRouter;

- (void)initializeSdkWithInfo:(NSDictionary *)info;
- (void)setShouldCollectDeviceId:(BOOL)shouldCollectDeviceId;
- (void)setSDKOptions:(NSDictionary *)sdkOptions;
- (void)requestInterstitialAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<VungleRouterDelegate>)delegate;
- (void)requestRewardedVideoAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<VungleRouterDelegate>)delegate;
- (void)requestBannerAdWithCustomEventInfo:(NSDictionary *)info size:(CGSize)size delegate:(id<VungleRouterDelegate>)delegate;
- (BOOL)isAdAvailableForPlacementId:(NSString *)placementId;
- (void)presentInterstitialAdFromViewController:(UIViewController *)viewController options:(NSDictionary *)options forPlacementId:(NSString *)placementId;
- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId settings:(VungleInstanceMediationSettings *)settings forPlacementId:(NSString *)placementId;
- (UIView *)renderBannerAdInView:(UIView *)bannerView options:(NSDictionary *)options forPlacementID:(NSString *)placementID size:(CGSize)size;
- (void)completeBannerAdViewForPlacementID:(NSString *)placementID;
- (void)invalidateBannerAdViewForPlacementID:(NSString *)placementID delegate:(id<VungleRouterDelegate>)delegate;
- (void)updateConsentStatus:(VungleConsentStatus)status;
- (VungleConsentStatus) getCurrentConsentStatus;
- (void)clearDelegateForPlacementId:(NSString *)placementId;
- (void)clearDelegateForRequestingBanner;

@end

@protocol VungleRouterDelegate <NSObject>

- (void)vungleAdDidLoad;
- (void)vungleAdWillAppear;
- (void)vungleAdDidAppear;
- (void)vungleAdWillDisappear;
- (void)vungleAdDidDisappear;
- (void)vungleAdWasTapped;
- (void)vungleAdDidFailToPlay:(NSError *)error;
- (void)vungleAdDidFailToLoad:(NSError *)error;
- (NSString *)getPlacementID;

@optional

- (void)vungleAdShouldRewardUser;

// @note This should only be used with banner ads
- (void)vungleAdWillLeaveApplication;

- (void)vungleBannerAdDidLoadInView:(UIView *)view;

- (CGSize)getBannerSize;

@end
