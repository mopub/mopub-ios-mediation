//
//  MMNativeAd.h
//  MMAdSDK
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#ifndef MMNativeAd_Header_h
#define MMNativeAd_Header_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MMAd.h"

/* An inline native ad placement. */
extern NSString* __nonnull const MMNativeAdTypeInline;

/* An unknown native ad placement. */
extern NSString* __nonnull const MMNativeAdTypeUnknown;

typedef NS_ENUM(NSInteger, MMNativeComponentTypeID) {
    MMNativeComponentTypeIDUnknown = -1,
    MMNativeComponentTypeIDTitle = 100,
    MMNativeComponentTypeIDBody = 101,
    MMNativeComponentTypeIDIconImage = 102,
    MMNativeComponentTypeIDMainImage = 103,
    MMNativeComponentTypeIDCallToAction = 104,
    MMNativeComponentTypeIDRating = 105,
    MMNativeComponentTypeIDDisclaimer = 106
};

typedef NS_ENUM (NSInteger, MMNativeAdComponent) {
    /** The body text component of the ad. */
    MMNativeAdComponentBody = MMNativeComponentTypeIDBody,
    /** The call-to-action component of the ad. */
    MMNativeAdComponentCallToActionButton = MMNativeComponentTypeIDCallToAction,
    /** The disclaimer text component of the ad. */
    MMNativeAdComponentDisclaimer = MMNativeComponentTypeIDDisclaimer,
    /** The icon image view component of the ad. */
    MMNativeAdComponentIconImageView = MMNativeComponentTypeIDIconImage,
    /** The main image view component of the ad. */
    MMNativeAdComponentMainImageView = MMNativeComponentTypeIDMainImage,
    /** The rating component of the ad. */
    MMNativeAdComponentRating = MMNativeComponentTypeIDRating,
    /** The title text component of the ad. */
    MMNativeAdComponentTitle = MMNativeComponentTypeIDTitle
};

@class MMRequestInfo;
@class MMNativeAd;

NS_ASSUME_NONNULL_BEGIN

@protocol MMNativeAdDelegate <NSObject>
@required
/**
 * The view controller from which views such as landing pages, App Store screens, or other modal views will be presented.
 *
 * @return The view controller used to present modal views.
 */
-(UIViewController*)viewControllerForPresentingModalView;

@optional
/**
 * Callback fired when a native ad request succeeds, and all parameters are ready for access.
 *
 * This method is always called on the main thread.
 *
 * @param ad The native ad placement which was successfully requested.
 */
-(void)nativeAdRequestDidSucceed:(MMNativeAd*)ad;

/**
 * Callback indicating that ad content failed to load or render.
 *
 * This method is always called on the main thread.
 *
 * @param ad The native ad placement for which the request failed.
 * @param error The error indicating the failure.
 */
-(void)nativeAd:(MMNativeAd*)ad requestDidFailWithError:(NSError*)error;

/**
 * Callback indicating that the user has interacted with ad content.
 *
 * This callback should not be used to adjust the contents of your application -- it should be used only for the purposes of reporting.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement which was tapped.
 * @param nativeAdComponent The MMNativeAdComponent which was tapped.
 * @param instance The instance of the component which was tapped.
 */
-(void)nativeAd:(MMNativeAd*)ad tappedComponent:(MMNativeAdComponent)nativeAdComponent instance:(NSInteger)instance;

/**
 * Callback invoked prior to the application going into the background due to a user interaction with an ad.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement.
 */
-(void)nativeAdWillLeaveApplication:(MMNativeAd*)ad;

/**
 * Callback fired when an ad expires.
 *
 * After receiving this message, your app should call -load before attempting to access
 * any components of the native ad.
 *
 * This method is always called on the main thread.
 *
 * @param ad The ad placement which expired.
 */
-(void)nativeAdDidExpire:(MMNativeAd*)ad;

@end

/**
 * The class representing a native advertisement, its content, and the associated actions.
 *
 * When presenting a native advertisement, you are allowed to style the content
 * as you see fit, but should not mix your native app elements with native advertising
 * elements to avoid confusion.
 */
@interface MMNativeAd : MMAd

/**
 * Initializes a native ad placement.
 *
 * @param placementId The identifier of the placement that is used by the server for selecting ad content.
 * @param nativeAdType An NSString object which corresponds to a defined native type, for example, MMNativeAdTypeInline.
 * @return The MMNativeAd object.
 */
-(nullable instancetype)initWithPlacementId:(NSString*)placementId adType:(NSString*)nativeAdType;

/**
 * Initializes a native ad placement.
 *
 * @param placementId The identifier of the placement that is used by the server for selecting ad content.
 * @param types An array of `NSString` objects, each of which corresponds to a defined native type, for example, MMNativeAdTypeInline.
 * @return The MMNativeAd object.
 */
-(nullable instancetype)initWithPlacementId:(NSString*)placementId supportedTypes:(NSArray*)types;

/**
 * Requests a native ad, asynchronously.
 *
 * @param requestInfo Additional targeting information relevant to this individual request.
 */
-(void)load:(nullable MMRequestInfo*)requestInfo;

/**
 * Notify the MMNativeAd that the user has tapped in the app's native ad presentation.
 *
 * Use this method to invoke the default action for taps anywhere in the native ad container view controlled by the app.
 */
-(void)invokeDefaultAction;

/**
 * Notify the MMNativeAd that the app's native ad container view has been presented on screen and is viewable.
 *
 * To ensure accurate reporting, is important to invoke this method when a valid impression has taken place.
 *
 * MMAdSDK validates that required components have been accessed by the ad container, an error is logged otherwise.
 *
 * Supported OpenRTB tracking:
 *
 * MMNativeAdTypeInline fires the OpenRTB imptrackers if present in the native response.
 * Note: jstracker is not supported because there is no webView associated with MMNativeAdTypeInline.
 */
-(void)fireImpression;

/**
 * Load the current native ad into a pre-defined layout, loaded from the specified bundle.
 * This method must be invoked from the main thread.
 *
 * Once a given ad is loaded into a layout, you should not access, display, or modify any of the views of the
 * native ad. Impression firing is also handled by the layout, which may have additional logic associated with it
 * by the layout designer.
 *
 * @param bundle A bundle object containing nibs for layout, along with a `layouts.plist` descriptor. See the full
 *               documentation on constructing a layout bundle for details.
 *
 * @return An instance of the view loaded from the bundle, with its contents populated with the native ad, or `nil` if
 *         a view could not be loaded.
 */
-(nullable UIView*)loadIntoLayoutFromBundle:(NSBundle*)bundle;

/**
 * The native ad's delegate.
 */
@property(nonatomic, weak, nullable) id<MMNativeAdDelegate> delegate;

/**
 * The state of the native ad components.
 *
 * The value will be `YES` when all components are loaded, ready to use, and have not expired, `NO` otherwise.
 * Be sure to test isValid before retrieving native ad content to ensure it has not expired.
 */
@property(nonatomic, readonly) BOOL isValid;

/**
 * The type of the native ad.
 */
@property(nonatomic, readonly, nullable) NSString* type;

/**
 * The disclaimer text marking a visual element as an advertisement.
 * 
 * The text value must be displayed and should not be altered. Example disclosure language includes: "Sponsored by [brand]"  or "Presented by [brand]"
 *
 * Default attributes which may be may be altered by the user:
 *
 * length - recommended maximum length of 25 characters for these defaults.
 * width - set by sizeWithAttributes: for the default font
 * font - systemFontOfSize: 8.0
 *
 * Returns nil if this component is not available.
 */
@property (nonatomic, readonly, nullable) UILabel* disclaimer;

/**
 * The disclaimer text marking a visual element as an advertisement.
 *
 * The text value must be displayed and should not be altered. Example disclosure language includes: "Sponsored by [brand]"  or "Presented by [brand]"
 *
 * Default attributes which may be may be modified by the user:
 *
 * length - recommended maximum length of 25 characters for these defaults.
 * width - set by sizeWithAttributes: for the default font
 * font - systemFontOfSize: 8.0
 *
 * @param instanceId represents which disclaimer instance to retrieve, starting from 1
 * @return The disclaimer label for the ad, or nil if there is no disclaimer available.
 */
-(nullable UILabel *)disclaimer:(NSInteger)instanceId;

/**
 * An imageView containing the icon image for the ad, with an associated gesture recognizer that invokes
 * the associated action when the element is tapped.
 *
 * None of the content associated with this view or its actions should be altered in any way.
 *
 * Default attributes which may be may be modified by the user:
 *
 * size - The imageView size defaults to the size of the asset resource.
 *        The recommended approach is to set the frame of the imageView to the bounds of its superView,
 *        which has autoresizesSubviews=YES:  nativeAd.iconImageView.frame = self.nativeAdContainer.iconImageView.bounds;
 *
 * Returns nil if this component is not available.
 *
 */
@property (nonatomic, readonly, nullable) UIImageView* iconImageView;

/**
 * An imageView containing the icon image for the ad, with an associated gesture recognizer that invokes
 * the associated action when the element is tapped.
 *
 * None of the content associated with this view or its actions should be altered in any way.
 *
 * Default attributes which may be may be modified by the user:
 *
 * size - The imageView size defaults to the size of the asset resource.
 *        The recommended approach is to set the frame of the imageView to the bounds of its superView,
 *        which has autoresizesSubviews=YES:  nativeAd.iconImageView.frame = self.nativeAdContainer.iconImageView.bounds;
 *
 * Returns nil if this component is not available.
 *
 * @param instanceId represents which iconImageView instance to retrieve, starting from 1
 * @return The icon imageView for the ad, or nil if there is no imageView available.
 */
-(nullable UIImageView *)iconImageView:(NSInteger)instanceId;

/**
 * An imageView containing the main image for the ad, with an associated gesture recognizer that invokes
 * the associated action when the element is tapped.
 *
 * None of the content associated with this view or its actions should be altered in any way.
 *
 * Default attributes which may be may be modified by the user:
 *
 * size - The imageView size defaults to the size of the asset resource.
 *        The recommended approach is to set the frame of the imageView to the bounds of its superView,
 *        which has autoresizesSubviews=YES:  nativeAd.mainImageView.frame = self.nativeAdContainer.mainImageView.bounds;
 *
 * Returns nil if this component is not available.
 */
@property (nonatomic, readonly, nullable) UIImageView* mainImageView;

/**
 * An imageView containing the main image for the ad, with an associated gesture recognizer that invokes
 * the associated action when the element is tapped.
 *
 * None of the content associated with this view or its actions should be altered in any way.
 *
 * Default attributes which may be may be modified by the user:
 *
 * size - The imageView size defaults to the size of the asset resource.
 *        The recommended approach is to set the frame of the imageView to the bounds of its superView,
 *        which has autoresizesSubviews=YES:  nativeAd.mainImageView.frame = self.nativeAdContainer.mainImageView.bounds;
 *
 * Returns nil if this component is not available.
 *
 * @param instance represents which mainImageView instance to retrieve, starting from 1
 * @return The main imageView for the ad, or nil if there is no imageView available.
 */
-(nullable UIImageView *)mainImageView:(NSInteger)instance;

/**
 * Descriptive text for the ad.
 *
 * The text value must be displayed and should not be altered.
 *
 * Default attributes which may be may be modified by the user:
 *
 * length - recommended maximum length of 200 characters for these defaults.
 * size - default body label size is (200.0, 60.0)
 * font - systemFontOfSize: 9.0
 * number of lines - 5
 *
 * Returns nil if this component is not available.
 */
@property (nonatomic, readonly, nullable) UILabel* body;

/**
 * Descriptive body text for the ad. 
 *
 * The text value must be displayed and should not be altered.
 *
 * Default attributes which may be may be modified by the user:
 *
 * length - recommended maximum length of 200 characters for these defaults.
 * size - default body label size is (200.0, 60.0)
 * font - systemFontOfSize: 9.0
 * number of lines - 5
 *
 * Returns nil if this component is not available.
 *
 * @param instanceId represents which body instance to retrieve, starting from 1
 * @return The body label for the ad, or nil if there is no body label available.
 */
-(nullable UILabel*)body:(NSInteger)instanceId;

/**
 * The title label of the ad. 
 * 
 * The text value must be displayed and should not be altered.
 *
 * Default attributes which may be may be modified by the user:
 *
 * length - recommended maximum length of 15 characters for these defaults.
 * width - set by sizeWithAttributes: for the default font
 * font - systemFontOfSize: 16.0
 *
 * Returns nil if this component is not available.
 */
@property (nonatomic, readonly, nullable) UILabel* title;

/**
 * The title label of the ad. 
 *
 * The text value must be displayed and should not be altered.
 *
 * Default attributes which may be may be modified by the user:
 *
 * length - recommended maximum length of 15 characters for these defaults.
 * width - set by sizeWithAttributes: for the default font
 * font - systemFontOfSize: 16.0
 *
 * Returns nil if this component is not available.
 *
 * @param instanceId represents which title instance to retrieve, starting from 1
 * @return The title label for the ad, or nil if there is no title label available.
 */
-(nullable UILabel*)title:(NSInteger)instanceId;

/**
 * The call to action button which invokes the associated main action for an ad.
 *
 * None of the content associated with this button or its actions should be altered.
 *
 * Default attributes which may be may be modified by the user:
 *
 * length - recommended maximum length of 5 characters for these defaults.
 * width - set by sizeWithAttributes: for the default font
 * font - systemFontOfSize: 10.0
 *
 * Returns nil if this component is not available.
 */
@property (nonatomic, readonly, nullable) UIButton* callToActionButton;

/**
 * The call-to-action button which invokes the associated main action for an ad.
 *
 * None of the content associated with this button or its actions should be altered.
 *
 * Default attributes which may be may be modified by the user:
 *
 * length - recommended maximum length of 5 characters for these defaults.
 * width - set by sizeWithAttributes: for the default font
 * font - systemFontOfSize: 10.0
 *
 * Returns nil if this component is not available.
 *
 * @param instance represents which call-to-action button instance to retrieve, starting from 1
 * @return The call-to-action label for the ad, or nil if there is no call-to-action button available.
 */
-(nullable UIButton *)callToActionButton:(NSInteger)instance;

/**
 * The rating label for the native ad.
 * 
 * The text value must be displayed and should not be altered.
 *
 * Default attributes which may be may be modified by the user:
 *
 * length - recommended maximum length of 15 characters for these defaults.
 * width - set by sizeWithAttributes: for the default font
 * font - systemFontOfSize: 10.0
 *
 * Returns nil if this component is not available.
 */
@property (nonatomic, readonly, nullable) UILabel* rating;

/**
 * The rating label of the ad. The text value must be displayed and should not be altered.
 *
 * The text value must be displayed and should not be altered.
 *
 * Default attributes which may be may be modified by the user:
 *
 * length - recommended maximum length of 15 characters for these defaults.
 * width - set by sizeWithAttributes: for the default font
 * font - systemFontOfSize: 10.0
 *
 * Returns nil if this component is not available.
 *
 * @param instance The instance to retrieve, indexed from 1.
 * @return The rating label for the ad, or nil if there is no rating label available.
 */
-(nullable UILabel *)rating:(NSInteger)instance;

@end

NS_ASSUME_NONNULL_END

#endif
