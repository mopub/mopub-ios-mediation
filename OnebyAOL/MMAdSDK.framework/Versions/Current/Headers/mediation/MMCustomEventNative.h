//
//  MMCustomEventNative.h
//  MMAdSDK
//
//  Copyright © 2017 Millennial Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMCustomEvent.h"
#import "MMNativeAsset.h"
#import "MMNativeWrapper.h"

@protocol MMCustomEventNative;

/**
 * This protocol indicates a communication channel back to the placement, in order to communicate user events and
 * other information that may be important for the display or management of the ad. Any implementers of the
 * `MMCustomEventNative` protocol should make a best effort to send these messages where appropriate.
 */
@protocol MMCustomEventNativeDelegate <NSObject>
@required

/**
 * This method should be called when an MMCustomEventNative succeeds in loading ad content.
 *
 * @param   customEventNative The instance of custom event native that called the callback.
 */
-(void)customEventNativeLoadSucceeded:(id<MMCustomEventNative>)customEventNative;

/**
 * This method should be called when an MMCustomEventNative fails to load an ad, with an appropriate error
 * message.
 *
 * @param   customEventNative The instance of custom event native that called the callback.
 * @param   error   The error which caused the load failure. It is recommended to use the standard error MMSDKErrorCode
 *                  codes when passing an error back to an inline placement.
 */
-(void)customEventNative:(id<MMCustomEventNative>)customEventNative loadFailedWithError:(NSError*)error;

/**
 * This method should be called whenever the native will cause the application to be put into the background.
 *
 * @param   customEventNative The instance of custom event native that called the callback.
 */
-(void)customEventNativeWillLeaveApplication:(id<MMCustomEventNative>)customEventNative;

/**
 * The view controller that the publisher has set for presenting modal views.
 *
 * @param   customEventNative The instance of custom event native that called the callback.
 */
-(UIViewController*)customEventNativePresentationViewController:(id<MMCustomEventNative>)customEventNative;
@end

/**
 * This protocol is implemented by classes which can provide content for native ads.
 */
@protocol MMCustomEventNative <MMCustomEvent>
@required

/**
 * The method should return an instance of MMCustomEventNative.
 *
 * @param delegate  Custom event native delegate.
 */
+(id<MMCustomEventNative>)customEventWithDelegate:(id<MMCustomEventNativeDelegate>)delegate;

/**
 * Performs an action for the provided asset.
 *
 * @param   asset   The asset to perform the action for.
 */
-(void)performActionForAsset:(MMNativeAsset*)asset;

/**
 * Performs the native ad's "default" action.
 */
-(void)performDefaultAction;

/**
 * The `MMNativeComponentTypeID`s of the available components for the native ad.
 */
@property (nonatomic, readonly) NSArray<NSNumber*>* availableComponents;

/**
 * An object containing the data for the native ad.
 */
@property (nonatomic, readonly) id<MMNativeWrapper> nativeWrapper;

@optional

/**
 * Allows the custom event to register a view for the purpose of detecting and tracking user interactions. If
 * the custom event implements this method, it __must__ also implement `trackingComponentType`.
 *
 * @param   view    The view to use for tracking interactions. The custom event should be able to treat any
 *                  user interaction with this view in a manner appropriate for its internal content.
 */
-(void)registerViewForInteractions:(UIView*)view;

/**
 * If the custom event has a specific component which should be used for tracking interactions, this method should
 * be implemented. If the custom event implements this method, it __must__ also implement `registerViewForInteractions:`.
 */
-(NSInteger)interactionComponentType;

/**
 * Fires any impression trackers associated with the custom event's content.
 */
-(void)fireImpressionTrackers;

@end
