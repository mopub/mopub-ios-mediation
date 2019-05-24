//
//  UnityRouter.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UnityAds/UnityAds.h>
#import <UnityAds/UnityAdsExtended.h>
#import <UnityAds/UADSBanner.h>

@protocol UnityRouterDelegate;
@class UnityAdsInstanceMediationSettings;

@interface UnityRouter : NSObject <UnityAdsExtendedDelegate, UnityAdsBannerDelegate>

@property NSString* currentPlacementId;

+ (UnityRouter *)sharedRouter;

- (void)initializeWithGameId:(NSString *)gameId;
- (void)requestVideoAdWithGameId:(NSString *)gameId placementId:(NSString *)placementId delegate:(id<UnityRouterDelegate>)delegate;
- (void)requestBannerAdWithGameId:(NSString *)gameId placementId:(NSString *)placementId delegate:(id<UnityAdsBannerDelegate>)delegate;
- (BOOL)isAdAvailableForPlacementId:(NSString *)placementId;
- (void)presentVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId placementId:(NSString *)placementId settings:(UnityAdsInstanceMediationSettings *)settings delegate:(id<UnityRouterDelegate>)delegate;
- (void)clearDelegate:(id<UnityRouterDelegate>)delegate;

@end

@protocol UnityRouterDelegate <NSObject>

- (void)unityAdsReady:(NSString *)placementId;
- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message;
- (void)unityAdsDidStart:(NSString *)placementId;
- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state;
- (void)unityAdsDidClick:(NSString *)placementId;
- (void)unityAdsDidFailWithError:(NSError *)error;

@optional
- (void)unityAdsPlacementStateChanged:(NSString*)placementId oldState:(UnityAdsPlacementState)oldState newState:(UnityAdsPlacementState)newState;

@end
