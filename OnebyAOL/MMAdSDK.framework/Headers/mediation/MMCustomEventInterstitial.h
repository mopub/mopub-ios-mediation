//
//  MMCustomEventInterstitial.h
//  MMAdSDK
//
//  Copyright © 2017 Millennial Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMCustomEvent.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MMCustomEventInterstitial;

/**
 * This protocol indicates a communication channel back to the placement, in order to communicate user events and
 * other information that may be important for the display or management of the ad. Any implementers of the
 * `MMCustomEventInterstitial` protocol should make a best effort to send these messages where appropriate.
 */
@protocol MMCustomEventInterstitialDelegate <NSObject>
@required

/**
 * This method should be called when an interstitial load succeeds.
 *
 * @param   customEventInterstitial The instance of custom event interstitial that called the callback.
 */
-(void)customEventInterstitialLoadDidSucceed:(id<MMCustomEventInterstitial>)customEventInterstitial;

/**
 * This method should be called when an MMCustomEventInterstitial fails to load an ad, with an appropriate error
 * message.
 *
 * @param   customEventInterstitial The instance of custom event interstitial that called the callback.
 * @param   error   The error which caused the load failure. It is recommended to use the standard error MMSDKErrorCode
 *                  codes when passing an error back to an inline placement.
 */
-(void)customEventInterstitial:(id<MMCustomEventInterstitial>)customEventInterstitial loadDidFailWithError:(NSError*)error;

/**
 * Should be called before an interstitial is displayed.
 *
 * @param   customEventInterstitial The instance of custom event interstitial that called the callback.
 */
-(void)customEventInterstitialWillDisplay:(id<MMCustomEventInterstitial>)customEventInterstitial;

/**
 * Should be called before an interstitial will be dismissed.
 *
 * @param   customEventInterstitial The instance of custom event interstitial that called the callback.
 */
-(void)customEventInterstitialWillDismiss:(id<MMCustomEventInterstitial>)customEventInterstitial;

/**
 * Should be called after an interstitial has dismissed.
 *
 * @param   customEventInterstitial The instance of custom event interstitial that called the callback.
 */
-(void)customEventInterstitialDidDismiss:(id<MMCustomEventInterstitial>)customEventInterstitial;

/**
 * Should be called whenever the content of an interstitial is tapped.
 *
 * @param   customEventInterstitial The instance of custom event interstitial that called the callback.
 */
-(void)customEventInterstitialContentTapped:(id<MMCustomEventInterstitial>)customEventInterstitial;

/**
 * This method should be called when an MMCustomEventInterstitial fails to show an ad, with an appropriate error
 * message.
 *
 * @param   customEventInterstitial The instance of custom event interstitial that called the callback.
 * @param   error   The error which caused the load failure. It is recommended to use the standard error MMSDKErrorCode
 *                  codes when passing an error back to an inline placement.
 */
-(void)customEventInterstitial:(id<MMCustomEventInterstitial>)customEventInterstitial showDidFailWithError:(NSError*)error;

/**
 * This method should be called whenever the interstitial will cause the application to be put into the background.
 *
 * @param   customEventInterstitial The instance of custom event interstitial that called the callback.
 */
-(void)customEventInterstitialWillLeaveApplication:(id<MMCustomEventInterstitial>)customEventInterstitial;

/**
 * This method should be called whenever an interstitial's content expires.
 *
 * @param   customEventInterstitial The instance of custom event interstitial that called the callback.
 */
-(void)customEventInterstitialExpireContent:(id<MMCustomEventInterstitial>)customEventInterstitial;

/**
 * A value indicating whether or not the interstitial is currently displayed to the user.
 */
@property (nonatomic, readonly, getter=isDisplayed) BOOL displayed;

/**
 * The transition style that has been requested by the publisher. If the interstitial is going to display a modal,
 * a best effort should be used to use this value.
 *
 * This value is allowed to be distinct from the `transitionStyle` used to present the interstitial.
 */
@property (nonatomic, readonly) UIModalTransitionStyle transitionStyle;

@end

/**
 * This protocol is implemented by classes which can provide content for interstitial ads.
 */
@protocol MMCustomEventInterstitial <MMCustomEvent>
@required

/**
 * The method should return an instance of MMCustomEventInterstitial.
 *
 * @param delegate  Custom event interstitial delegate.
 */
+(id<MMCustomEventInterstitial>)customEventWithDelegate:(id<MMCustomEventInterstitialDelegate>)delegate;

/**
 * Display the interstitial.
 * This method is deprecated in MMSDK 6.8 in favor of presentFromViewController and will be removed in a
 * future release.
 *
 * @param   controller  The view control the interstitial must be presented from.
 * @param   animated    Whether or not the display should be animated.
 * @param   transitionStyle The style to be used for the presentation.
 * @param   completion  The completion block that should be called upon the interstitial being presented.
 */
- (void)presentFromController:(UIViewController *)controller
                     animated:(BOOL)animated
              transitionStyle:(UIModalTransitionStyle)transitionStyle
                   completion:(void (^)(void))completion __deprecated;

/**
 * Display the interstitial.
 *
 * @param   controller  The view control the interstitial must be presented from.
 * @param   animated    Whether or not the display should be animated.
 * @param   transitionStyle The style to be used for the presentation.
 * @param   completion  The completion block that should be called upon the interstitial being presented.
 */
- (void)presentFromViewController:(UIViewController *)controller
                         animated:(BOOL)animated
                  transitionStyle:(UIModalTransitionStyle)transitionStyle
                       completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

/*
 * Whether or not the interstitial's content is expired. This expiration is independent of the SDK's own
 * interstitial expiry tracking.
 */
@property (nonatomic, readonly, getter=isContentExpired) BOOL contentExpired;

/*
 * Whether or not the adapter's content is ready to be displayed.
 */
@property (nonatomic, readonly, getter=isContentReady) BOOL contentReady;

@end

NS_ASSUME_NONNULL_END
