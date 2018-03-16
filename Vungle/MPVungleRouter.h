//
//  MPVungleRouter.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VungleSDK/VungleSDK.h>

extern NSString *const kVunglePlacementIdKey;
extern NSString *const kVungleFlexViewAutoDismissSeconds;
extern NSString *const kVungleUserId;
extern NSString *const kVungleOrdinal;

@protocol MPVungleRouterDelegate;
@class VungleInstanceMediationSettings;

@interface MPVungleRouter : NSObject <VungleSDKDelegate>

+ (MPVungleRouter *)sharedRouter;

- (void)initializeSdkWithInfo:(NSDictionary *)info;
- (void)requestInterstitialAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<MPVungleRouterDelegate>)delegate;
- (void)requestRewardedVideoAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<MPVungleRouterDelegate>)delegate;
- (BOOL)isAdAvailableForPlacementId:(NSString *)placementId;
- (void)presentInterstitialAdFromViewController:(UIViewController *)viewController options:(NSDictionary *)options forPlacementId:(NSString *)placementId;
- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId settings:(VungleInstanceMediationSettings *)settings forPlacementId:(NSString *)placementId eventInfo:(NSDictionary *)info;
- (void)clearDelegateForPlacementId:(NSString *)placementId;

@end

@protocol MPVungleRouterDelegate <NSObject>

- (void)vungleAdDidLoad;
- (void)vungleAdWillAppear;
- (void)vungleAdWillDisappear;
- (void)vungleAdWasTapped;
- (void)vungleAdDidFailToPlay:(NSError *)error;
- (void)vungleAdDidFailToLoad:(NSError *)error;

@optional

- (void)vungleAdShouldRewardUser;

@end
