//
//  MMCustomEventBanner.h
//  MMAdSDK
//
//  Copyright © 2017 Millennial Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MMCustomEvent.h"

@protocol MMCustomEventBanner;

/**
 * This protocol indicates a communication channel back to the placement, in order to communicate user events and
 * other information that may be important for the display or management of the ad. Any implementers of the
 * `MMCustomEventBanner` protocol should make a best effort to send these messages where appropriate.
 */
@protocol MMCustomEventBannerDelegate <NSObject>
@required

/**
 * This method should be called when an MMCustomEventBanner succeeds in loading ad content.
 *
 * @param   customEventBanner The instance of custom event banner that called the callback.
 */
-(void)customEventBannerLoadSucceeded:(id<MMCustomEventBanner>)customEventBanner;

/**
 * This method should be called when an MMCustomEventBanner fails to load an ad, with an appropriate error
 * message.
 *
 * @param   customEventBanner The instance of custom event banner that called the callback.
 * @param   error   The error which caused the load failure. It is recommended to use the standard error MMSDKErrorCode
 *                  codes when passing an error back to an inline placement.
 */
-(void)customEventBanner:(id<MMCustomEventBanner>)customEventBanner loadFailedWithError:(NSError*)error;

/**
 * This method should be called whenever the content of the ad is tapped. This not only notifies any
 * listeners on the placement, but also records an SDK reporting event, which may help resolve reporting
 * or revenue discrepancies.
 *
 * @param   customEventBanner The instance of custom event banner that called the callback.
 */
-(void)customEventBannerContentTapped:(id<MMCustomEventBanner>)customEventBanner;

/**
 * This method should be called when the ad will present a modal.
 *
 * @param   customEventBanner The instance of custom event banner that called the callback.
 */
-(void)customEventBannerWillPresentModal:(id<MMCustomEventBanner>)customEventBanner;

/**
 * This method should be called when the ad has presented a modal.
 *
 * @param   customEventBanner The instance of custom event banner that called the callback.
 */
-(void)customEventBannerDidPresentModal:(id<MMCustomEventBanner>)customEventBanner;

/**
 * This method should be called when the ad will close a modal.
 *
 * @param   customEventBanner The instance of custom event banner that called the callback.
 */
-(void)customEventBannerWillCloseModal:(id<MMCustomEventBanner>)customEventBanner;

/**
 * This method should be called when the ad has closed a modal.
 *
 * @param   customEventBanner The instance of custom event banner that called the callback.
 */
-(void)customEventBannerDidCloseModal:(id<MMCustomEventBanner>)customEventBanner;

/**
 * This method should be called when the ad content will cause the current application to enter
 * the background.
 *
 * @param   customEventBanner The instance of custom event banner that called the callback.
 */
-(void)customEventBannerWillLeaveApplication:(id<MMCustomEventBanner>)customEventBanner;

/**
 * The actual size of the ad requested by the user. It may be different from a pre-defined
 * ad placement size, or even the size of the ad which is provided. A best effort should be made
 * to provide content which will fit in this size.
 */
@property (nonatomic, readonly) CGSize requestedSize;

/**
 * The transition style that has been requested by the publisher. If at all possible, when displaying a modal,
 * this value should be used.
 */
@property (nonatomic, readonly) UIModalTransitionStyle transitionStyle;

/**
 * The view controller that the publisher has set for presenting modal views.
 */
@property (nonatomic, readonly) UIViewController *presentationViewController;

@end

/**
 * This protocol is implemented by classes which are able to provide content to inline ads.
 */
@protocol MMCustomEventBanner <MMCustomEvent>
@required

/**
 * The view containing the content for the placement.
 */
@property (nonatomic, readonly) UIView* view;

/**
 * The method should return an instance of MMCustomEventBanner.
 *
 * @param delegate          Custom event banner delegate.
 */
+(id<MMCustomEventBanner>)customEventWithDelegate:(id<MMCustomEventBannerDelegate>)delegate;

@optional

/**
 * This method is called when the custom event should immediately attempt to remove all of its associated views, and
 * unload them from memory. If the custom event class is unable to implement this method, it may result in issues if
 * the associated `MMInlineAd` is removed from the view hierarchy while resized or displaying a modal.
 */
-(void)unloadAndRemoveViews;

/**
 * This method is called by the SDK in order to force-close overlays that have been displayed by an inline placement.
 * If the custom event class is unable to implement this method, it may result in issues if the associated `MMInlineAd`
 * is removed from the view hierarchy while resized or displaying a modal.
 */
-(void)closeOverlays;

/**
 * A value indicating whether or not the content is currently displaying an overlay. For the Millennial SDK, an
 * 'overlay' is defined as any content the ad has presented which may be obscuring part of the screen.
 * If the custom event class is unable to implement this method, it may result in issues if the associated `MMInlineAd`
 * is removed from the view hierarchy while resized or displaying a modal.
 */
@property (nonatomic, readonly, getter=isDisplayingOverlay) BOOL displayingOverlay;
@end
