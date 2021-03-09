//
//  VungleRouter.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

extern NSString *const kVungleAppIdKey;
extern NSString *const kVunglePlacementIdKey;
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
typedef NS_ENUM(NSInteger, VungleConsentStatus);

@interface VungleRouter : NSObject

+ (VungleRouter *)sharedRouter;

- (void)initializeSdkWithInfo:(NSDictionary *)info;
- (void)setShouldCollectDeviceId:(BOOL)shouldCollectDeviceId;
- (void)setSDKOptions:(NSDictionary *)sdkOptions;
- (void)requestInterstitialAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<VungleRouterDelegate>)delegate;
- (void)requestRewardedVideoAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<VungleRouterDelegate>)delegate;
- (void)requestBannerAdWithCustomEventInfo:(NSDictionary *)info size:(CGSize)size delegate:(id<VungleRouterDelegate>)delegate;
- (BOOL)isAdAvailableForDelegate:(id<VungleRouterDelegate>)delegate;
- (NSString *)currentSuperToken;
- (void)presentInterstitialAdFromViewController:(UIViewController *)viewController options:(NSDictionary *)options delegate:(id<VungleRouterDelegate>)delegate;
- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId settings:(VungleInstanceMediationSettings *)settings delegate:(id<VungleRouterDelegate>)delegate;
- (UIView *)renderBannerAdInView:(UIView *)bannerView
                        delegate:(id<VungleRouterDelegate>)delegate
                         options:(NSDictionary *)options
                  forPlacementID:(NSString *)placementID
                            size:(CGSize)size;
- (void)completeBannerAdViewForDelegate:(id<VungleRouterDelegate>)delegate;
- (void)updateConsentStatus:(VungleConsentStatus)status;
- (VungleConsentStatus) getCurrentConsentStatus;
- (void)cleanupFullScreenDelegate:(id<VungleRouterDelegate>)delegate;
- (void)clearDelegateForRequestingBanner;
@end

typedef NS_ENUM(NSUInteger, BannerRouterDelegateState) {
    BannerRouterDelegateStateRequesting,
    BannerRouterDelegateStateCached,
    BannerRouterDelegateStatePlaying,
    BannerRouterDelegateStateClosing,
    BannerRouterDelegateStateClosed,
    BannerRouterDelegateStateUnknown
};

@protocol VungleRouterDelegate <NSObject>

- (void)vungleAdDidLoad;
- (void)vungleAdWillAppear;
- (void)vungleAdDidAppear;
- (void)vungleAdViewed;
- (void)vungleAdWillDisappear;
- (void)vungleAdDidDisappear;
- (void)vungleAdTrackClick;
- (void)vungleAdWillLeaveApplication;
- (void)vungleAdDidFailToPlay:(NSError *)error;
- (void)vungleAdDidFailToLoad:(NSError *)error;
- (NSString *)getPlacementID;
- (NSString *)getAdMarkup;

@optional

- (void)vungleAdRewardUser;

- (void)vungleBannerAdDidLoadInView:(UIView *)view;

- (CGSize)getBannerSize;

@property(nonatomic) BannerRouterDelegateState bannerState;

@end
